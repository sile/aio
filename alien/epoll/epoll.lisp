(in-package :aio.alien.epoll)

;; TODO: move to other package
(defmacro unix-return (exp &key bool)
  (let ((ret (gensym)))
    `(let ((,ret ,exp))
       (if (= -1 ,ret)
           (values nil (aio.e:errno))
         (values ,(if bool t ret) aio.e:SUCCESS)))))

(defun create (&key cloexec)
  (let ((flags (if cloexec +CLOEXEC+ 0)))
    (unix-return (%create1 flags))))

(defun close (fd)
  (unix-return (%close fd) :bool t))

#|
(defun %close (fd)
  (multiple-value-bind (ok err) (sb-unix:unix-close fd)
    (if ok
        (values t t)
      (values nil (errsym err)))))

(deftype epoll-event () '(member :in :out :rdhup :pri :err :hup :et :oneshot))

(defun %epoll-ctl (epfd op fd events) ; TODO: keyword 
  (let* ((events-n (loop FOR (e bool) ON events BY #'cddr
                         WHEN bool
                         SUM (ecase e
                               (:in +EPOLLIN+)
                               (:out +EPOLLOUT+)
                               (:rdhup +EPOLLRDHUP+)
                               (:pri +EPOLLPRI+) ; TODO:
                               (:err +EPOLLERR+)
                               (:hup +EPOLLHUP+)
                               (:et  +EPOLLET+)
                               (:oneshot +EPOLLONESHOT+)))))
    (with-alien ((event epoll_event))
      (setf (slot event 'events) events-n
            (slot (slot event 'data) 'fd) fd)
      (if (/= -1 (epoll_ctl epfd op fd (addr event)))
          (values t t)
        (values nil (errsym))))))

(defun %epoll-ctl-add (epfd fd &rest events)
  (%epoll-ctl epfd +EPOLL_CTL_ADD+ fd events))

(defun %epoll-ctl-mod (epfd fd &rest events)
  (%epoll-ctl epfd +EPOLL_CTL_MOD+ fd events))

(defun %epoll-ctl-del (epfd fd &rest events)
  (%epoll-ctl epfd +EPOLL_CTL_DEL+ fd events))

(defun %epoll-wait (epfd events &key (timeout 0))
  (with-slots (head size) (the events events)
    (let ((n (epoll_wait epfd (alien-sap head) size timeout)))
      (if (/= -1 n)
          (values n t)
        (values nil (errsym))))))
|#