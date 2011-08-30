(in-package :aio.alien)

(declaim (inline io_submit fill-by-0 memset))

(define-alien-routine memset void (ptr (* t)) (c int) (n size_t))
(define-alien-routine io_setup int (maxevents int) (ctxp (* io_context_t)))
(define-alien-routine io_destroy int (ctx io_context_t))
(define-alien-routine io_submit long (ctx io_context_t) 
                                     (nr long)
                                     (iocbpp (* (* iocb))))

(define-alien-routine fcntl int (fildes int) (cmd int) (option int))

(defun o-direct (fd)
  (let ((ret (fcntl fd +F_GETFL+ 0)))
    (if (= -1 ret)
        (values (get-errno) nil)
      (values (/= 0 (logand +O_DIRECT+ ret)) t))))

(defun (setf o-direct) (direct? fd)
  (let ((opts (fcntl fd +F_GETFL+ 0))) ; TODO: 整理
    (if (= -1 opts)
        (values (get-errno) nil) 
      (let ((ret (if direct?
                     (fcntl fd +F_SETFL+ (logior opts +O_DIRECT+))
                   (fcntl fd +F_SETFL+ (logxor opts +O_DIRECT+)))))
        (if (= -1 ret)
            (values (get-errno) nil)
          (values direct? t))))))

;fcntl(__aiocbp->aio_fildes, F_SETFL, fd_arg | O_DIRECT);

(defun fill-by-0 (ptr size)
  (declare ((alien (* t)) ptr))
  (memset ptr 0 size))

(defmacro init-iocb (iocb* request)
  `(progn
    (fill-by-0 ,iocb* iocb.size)
    (with-slots (op priority fd buf nbytes offset flags resfd) ,request
      (setf (iocb.lio_opcode ,iocb*) (op-value op)
            (iocb.reqprio ,iocb*) priority
            (iocb.fildes ,iocb*) fd
            (iocb.buf ,iocb*) (buffer-ptr buf)
            (iocb.nbytes ,iocb*) nbytes
            (iocb.offset ,iocb*) offset
            (iocb.flags ,iocb*) flags
            (iocb.resfd ,iocb*) resfd))))

(defun io-setup (maxevents)
  (let ((ctxp (make-alien io_context_t)))
    (fill-by-0 ctxp io_context_t.size)
    (case (- (io_setup maxevents ctxp))
      (0          (values (io-context-t.new ctxp) t))
      (#.+EAGAIN+ (values nil :EAGAIN))
      (#.+EFAULT+ (values nil :EFAULT))
      (#.+EINVAL+ (values nil :EINVAL))
      (#.+ENOMEM+ (values nil :ENOMEM))
      (#.+ENOSYS+ (values nil :ENOSYS))
      (otherwise  (values nil :UNKNOWN)))))

(defun io-destroy (context)
  (with-slots (ptr) (the io-context-t context)
    (case (- (io_destroy (deref ptr)))
      (0          (values t t))
      (#.+EFAULT+ (values nil :EFAULT))
      (#.+EINVAL+ (values nil :EINVAL))
      (#.+ENOSYS+ (values nil :ENOSYS))
      (otherwise  (values nil :UNKNOWN)))))

(defmacro io_submit_wrap (ctx nr iocb**)
  `(case (- (io_submit ,ctx ,nr ,iocb**))
     (0 (values t t))
     (#.+EFAULT+ (values nil :EFAULT))
     (#.+EINVAL+ (values nil :EINVAL))
     (#.+EBADF+  (values nil :EBADF))
     (#.+EAGAIN+ (values nil :EAGAIN))
     (#.+ENOSYS+ (values nil :ENOSYS))
     (otherwise  (values nil :UNKNOWN))))

(defun io-submit-1 (context request)
  (declare (ignorable request))
  (with-slots (ptr) (the io-context-t context)
    (with-alien ((iocb iocb)
                 (iocb* (* iocb)))
      (setf iocb* (addr iocb))
      (init-iocb iocb* request)
      (io_submit_wrap (deref ptr) 1 (addr iocb*)))))
      
(defun io-submit (context &rest requests &aux (size (length requests)))
  (case size
    (0 (values t t))
    (1 (io-submit-1 context (first requests)))
    (t :TODO)))

