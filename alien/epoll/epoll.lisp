(in-package :aio.alien.epoll)

;; TODO: move to other package
(defmacro unix-return (exp &key on-success)
  (let ((ret (gensym)))
    `(let ((,ret ,exp))
       (if (= -1 ,ret)
           (values nil (aio.e:errno))
         (values ,(typecase on-success
                    (null ret)
                    (t    on-success))
                 aio.e:SUCCESS)))))

(defun create (&key cloexec)
  (let ((flags (if cloexec +CLOEXEC+ 0)))
    (unix-return (%create1 flags))))

(defun close (fd)
  (unix-return (%close fd) :on-success t))


;;
(defmacro def-event-accessor (name constant)
  `(progn 
     (defun ,name (flag) 
       (ldb-test (byte 1 ,(1- (integer-length (symbol-value constant)))) flag))

     (define-setf-expander ,name (flag &environment env)
       (multiple-value-bind (temps vals _1 setter getter)
                            (get-setf-expansion flag env)
         (declare (ignore _1))
         (let ((on? (gensym)))
           (values temps
                   vals
                   `(,on?)
                   `(progn (setf (ldb (byte 1 ,,(1- (integer-length (symbol-value constant))))
                                      ,getter)
                                 (if ,on? 1 0))
                           ,on?)
                   `(,',name ,setter)))))))

(def-event-accessor event-in +IN+)
(def-event-accessor event-out +OUT+)
(def-event-accessor event-pri +PRI+)
(def-event-accessor event-err +ERR+)
(def-event-accessor event-hup +HUP+)
(def-event-accessor event-rdhup +RDHUP+)
(def-event-accessor event-et +ET+)
(def-event-accessor event-oneshot +ONESHOT+)

(defun ctl (epfd op fd &key in out pri err hup rdhup et oneshot)
  (let ((flag 0))
    (setf (event-in flag) in
          (event-out flag) out
          (event-pri flag) pri
          (event-err flag) err
          (event-hup flag) hup
          (event-rdhup flag) rdhup
          (event-et flag) et
          (event-oneshot flag) oneshot)

    (with-alien ((e epoll_event))
      (setf (epoll_event.events e) flag
            (epoll_data.fd (epoll_event.data e)) fd)
      (unix-return (%ctl epfd op fd (addr e)) :on-success t))))

(defun ctl-add (epfd fd &key in out pri err hup rdhup et oneshot)
  (ctl epfd +CTL_ADD+ fd 
       :in in :out out :pri pri :err err :hup hup :rdhup rdhup :et et :oneshot oneshot))

(defun ctl-mod (epfd fd &key in out pri err hup rdhup et oneshot)
  (ctl epfd +CTL_MOD+ fd 
       :in in :out out :pri pri :err err :hup hup :rdhup rdhup :et et :oneshot oneshot))

(defun ctl-del (epfd fd)
  (ctl epfd +CTL_DEL+ fd))

(defun wait (epfd *events size &key (timeout 0))
  (unix-return (%wait epfd *events size timeout)))

(declaim (inline do-event-impl))
(defun do-event-impl (fn epfd *events timeout limit)
  (multiple-value-bind (ready-event-num err)
                       (wait epfd *events limit :timeout timeout)
    (if ready-event-num
        (dotimes (i ready-event-num (values ready-event-num err))
          (let* ((e (deref *events i) )
                 (events (epoll_event.events e))
                 (fd (epoll_data.fd (epoll_event.data e))))
            (funcall fn fd events)))
      (values nil err))))

(defmacro do-event ((fd events) 
                    (epfd &key timeout
                               buffer-size
                               limit)
                    &body body)
  (let ((buf (gensym)))
    `(with-alien ((,buf (array epoll_event ,buffer-size)))
       (do-event-impl 
        (lambda (,fd ,events)
          ,@body)
        ,epfd (addr (deref ,buf 0)) ,timeout (min ,limit (1+ ,buffer-size))))))
