(in-package :aio.alien)

(define-alien-routine memset void (ptr (* t)) (c int) (n size_t))
(define-alien-routine io_setup int (maxevents int) (ctxp (* io_context_t)))
(define-alien-routine io_destroy int (ctx io_context_t))
(define-alien-routine io_submit long (ctx io_context_t) 
                                     (nr long)
                                     (iocbpp (* (* iocb))))

(defun fill-by-0 (ptr size)
  (declare ((alien (* t)) ptr))
  (memset ptr 0 size))

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

(defun io-submit-1 (context request)
  (with-slots (ptr) (the io-context-t context)
    (with-alien ((iocb iocb)
                 (iocbp (* iocb)))
      (setf iocbp (addr iocb))
      (io_submit (deref ptr) 1 (addr iocbp)))))
      
(defun io-submit (context &rest requests &aux (size (length requests)))
  (case size
    (0 (values t t))
    (1 (io-submit-1 context (first requests)))
    (t :TODO)))



