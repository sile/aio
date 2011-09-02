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
(defun create-context ()
  ;; TODO: 生のFDではなく、structでラップする
  (aio.alien.epoll:create :cloexec t))

(defun destroy-context (context)
  (aio.alien.epoll:close context))

;; TODO: (set-event fd flag) = (set-event fd (aio.event :in :out))
(defun set-event (fd &key (context *default-context*)
                          (modify-if-exists t)
                          in out pri err hup rdhup et oneshot)
  (multiple-value-bind (ret err)
                       (aio.alien.epoll:ctl-add context fd
                                                :in in :out out :pri pri 
                                                :err err :hup hup :rdhup rdhup 
                                                :et et :oneshot oneshot)
    (if (= aio.e:SUCCESS err)
        (values ret t)
      (if (or (not modify-if-exists)
              (/= aio.e:EXIST err))
          (values nil err)
        (aio.alien.epoll:ctl-mod context fd
                                 :in in :out out :pri pri 
                                 :err err :hup hup :rdhup rdhup 
                                 :et et :oneshot oneshot)))))

(defun del-event (fd &key (context *default-context*))
  (aio.alien.epoll:ctl-del context fd))

(defconstant +MAX_EVENTS_PER_WAIT+ 32)
#|
(defmacro do-event ((fd events &key (context *default-context*)
                                    (timeout 0)
                                    (limit (1+ +MAX_EVENTS_PER_WAIT+)))
                    &body body)
  ;(do-event-impl ...)
  (with-alien ((es (array aio.alien.epoll::epoll_event) #.+MAX_EVENTS_PER_WAIT+))
    es))
|#