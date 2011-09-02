(in-package :aio)

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

;; XXX:
(defun nonblock-read (fd bytes size &aux (ptr (sb-alien:alien-sap bytes)))
  (multiple-value-bind (ret ok)
                       (aio.alien:o-nonblock fd)
    (if (not ok)
        (values nil ret)
      (if ret
          (values (sb-unix:unix-read fd ptr size)
                  (aio.alien::errsym))
        (progn  ; XXX: check
          (setf (aio.alien:o-nonblock fd) t)
          (multiple-value-prog1 (values (sb-unix:unix-read fd ptr size) (aio.alien::errsym))
            (setf (aio.alien:o-nonblock fd) nil)))))))

;; TODO: native-ioパッケージを用意？ (fcntl, read, write)
(defun nonblock-write (fd bytes size &aux (ptr (sb-alien:alien-sap bytes)))
  (multiple-value-bind (ret ok)
                       (aio.alien:o-nonblock fd)
    (if (not ok)
        (values nil ret)
      (if ret
          (values (sb-unix:unix-write fd ptr 0 size)
                  (aio.alien::errsym))
        (progn  ; XXX: check
          (setf (aio.alien:o-nonblock fd) t)
          (multiple-value-prog1 (values (sb-unix:unix-write fd ptr 0 size) (aio.alien::errsym))
            (setf (aio.alien:o-nonblock fd) nil)))))))

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
    (format stream "~{~S~^ ~}" 
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
