(in-package :aio.alien)

(define-alien-routine memset void (ptr (* t)) (c int) (n size_t))
(define-alien-routine io_setup int (maxevents int) (ctxp (* io_context_t)))
(define-alien-routine io_destroy int (ctx io_context_t))

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