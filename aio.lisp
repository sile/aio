(in-package :aio)

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
