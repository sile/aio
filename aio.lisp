(in-package :aio) ;; filename: aio_event.lisp

#|
(defparameter *fd->handler* (make-hash-table))
(defun get-handler(fd)
  (gethash fd *fd->handler*))

(defun (setf get-handler) (new-handler fd)
  (setf (gethash fd *fd->handler*) new-handler))

(defun rem-handler (fd)
  (remhash fd *fd->handler*))

(defun set-handler (fd on-event &key (context *default-epoll*)
                                     read write)
  (multiple-value-bind (ok err)
                       (aio.alien:%epoll-ctl-add context fd :et t :in read :out write)
    (if ok
        (progn (setf (get-handler fd) on-event) t)
      (if (eq err :EEXIST)
          (multiple-value-bind (ok err)
                               (aio.alien:%epoll-ctl-mod context fd :et t :in read :out write)
            (if ok
                (progn (setf (get-handler fd) on-event) t)
              (values nil err)))))))

(defun wait (&key (timeout 0) (context *default-epoll*))
  (multiple-value-bind (n err)
                       (aio.alien:%epoll-wait context *default-event-buffer* :timeout timeout)
    (if (null n)
        (values nil err)
      (dotimes (i n (values n t))
        (multiple-value-bind (events fd)
                             (aio.alien::event-ref *default-event-buffer* i)
          (declare (ignore events))
          (aio.alien:%epoll-ctl-del context fd) ; XXX: check
          (let ((handler (get-handler fd)))
            (rem-handler fd)
            (funcall handler)))))))

(defun alloc-bytes (size &key auto-free)
  (aio.alien:alloc-bytes size :auto-free auto-free))

(defun free-bytes (bytes)
  (aio.alien:free-bytes bytes))

(defun to-lisp-string (bytes size)
  (sb-ext:octets-to-string
   (coerce (loop FOR i FROM 0 BELOW size
                 COLLECT (sb-alien:deref bytes i))
           '(vector (unsigned-byte 8)))
   :external-format '(:utf-8 :replacement #\?)))
|#

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defstruct context 
  (fd 0 :type fixnum)) ; TODO: file-descriptor-t)

(defmethod print-object ((o context) stream)
  (print-unreadable-object (o stream :identity t :type t)))

(defun create-context ()
  (multiple-value-bind (fd err)
                       (aio.alien.epoll:create :cloexec t)
    (if (null fd)
        (values nil err)
      (values (sb-ext:finalize (make-context :fd fd)
                               (lambda () (aio.alien.epoll:close fd)))
              0))))

;; TODO: 適切な場所に移動
(defvar *default-context* (create-context))

(defun watch (fd event &key (context *default-context*))
  (let ((epfd (context-fd context)))
    (multiple-value-bind (ret err)
                         (aio.alien.epoll:ctl-add epfd fd (event-flags event))
      (if (= aio.e:SUCCESS err)
          (values ret t)
        (if (/= aio.e:EXIST err)
            (values nil err)
          (aio.alien.epoll:ctl-mod epfd fd (event-flags event)))))))
  
(defun unwatch (fd &key (context *default-context*))
  (aio.alien.epoll:ctl-del (context-fd context) fd))


(eval-when (:compile-toplevel :load-toplevel)
  (defconstant +MAX_EVENTS_PER_WAIT+ 32))

(defstruct event
  (flags 0 :type fixnum)) ; TODO:

(defun event-in (event) (aio.alien.epoll:event-in (event-flags event)))
(defun event-out (event) (aio.alien.epoll:event-out (event-flags event)))
(defun event-pri (event) (aio.alien.epoll:event-pri (event-flags event)))
(defun event-err (event) (aio.alien.epoll:event-err (event-flags event)))
(defun event-hup (event) (aio.alien.epoll:event-hup (event-flags event)))
(defun event-rdhup (event) (aio.alien.epoll:event-rdhup (event-flags event)))
(defun event-et (event) (aio.alien.epoll:event-et (event-flags event)))
(defun event-oneshot (event) (aio.alien.epoll:event-oneshot (event-flags event)))

(defun event (&rest events)
  (make-event :flags
  (loop FOR e IN (remove-duplicates events)
        SUM (ecase e
              (:in aio.alien.epoll::+IN+)
              (:out aio.alien.epoll::+OUT+)
              (:pri aio.alien.epoll::+PRI+)
              (:err aio.alien.epoll::+ERR+)
              (:hup aio.alien.epoll::+HUP+)
              (:rdhup aio.alien.epoll::+RDHUP+)
              (:et aio.alien.epoll::+ET+)
              (:oneshot aio.alien.epoll::+ONESHOT+)))))
  
(defmethod print-object ((o event) stream)
  (print-unreadable-object (o stream :type t)
    (format stream "~{~S ~}" 
            (loop FOR (name getter) IN `((:in ,#'event-in) (:out ,#'event-out)
                                         (:pri ,#'event-pri) (:err ,#'event-err)
                                         (:hup ,#'event-hup) (:rdhup ,#'event-rdhup)
                                         (:et ,#'event-et) (:oneshot ,#'event-oneshot))
                  WHEN (funcall getter o)
                  COLLECT name))))

(defmacro do-event ((fd event &key (context *default-context*)
                                   (timeout 0)
                                   (limit #.(1+ +MAX_EVENTS_PER_WAIT+)))
                    &body body &aux (flags (gensym)))
  `(aio.alien.epoll:do-event (,fd ,flags)
                             ((context-fd ,context) :timeout ,timeout 
                                                    :buffer-size #.+MAX_EVENTS_PER_WAIT+
                                                    :limit ,limit)
     (let ((,event (make-event :flags ,flags)))
       ,@body)))

(defmacro event-case (event &rest clauses)
  (let ((e (gensym))
        (matched (gensym))
        (default (cdr (assoc t clauses))))
    `(let ((,e ,event)
           (,matched nil))
       ,@(loop FOR (key . body) IN clauses
               WHEN (member key '(:in :out :pri :err :hup :rdhup :et :oneshot))
           COLLECT
           (case key
             (:in `(when (event-in ,e) #1=(setf ,matched t) ,@body))
             (:out `(when (event-out ,e) #1# ,@body))
             (:pri `(when (event-pri ,e) #1# ,@body))
             (:err `(when (event-err ,e) #1# ,@body))
             (:hup `(when (event-hup ,e) #1# ,@body))
             (:rdhup `(when (event-rdhup ,e) #1# ,@body))
             (:et `(when (event-et ,e) #1# ,@body))
             (:oneshot `(when (event-oneshot ,e) #1# ,@body))))
       ,(when default
          `(unless ,matched
             ,@default))
       t)))
          
;;;;;;;;;;;;;;;
(defun read (fd bytes size &key force-nonblock)
  (aio.alien.io:read fd bytes size :force-nonblock force-nonblock))

(defun write (fd bytes size &key force-nonblock)
  (aio.alien.io:write fd bytes size :force-nonblock force-nonblock))

(defmacro ensure-nonblock ((fd) &body body)
  `(aio.alien.io:ensure-nonblock (,fd)
     ,@body))

;;;;;;;;;;;;;;;
(defun make-bytes (size)
  (aio.alien.bytes:alloc-bytes size))

(defun to-bytes (lisp-bytes)
  (aio.alien.bytes:to-bytes lisp-bytes))

(defun from-bytes (bytes)
  (aio.alien.bytes:from-bytes bytes))

(defun subbytes (bytes start &optional end)
  (aio.alien.bytes:subbytes bytes start end))

(defun byte-ref (bytes index)
  (aio.alien.bytes:ref bytes index))

(defun bytes-size (bytes)
  (aio.alien.bytes:size bytes))
