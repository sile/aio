(in-package :aio.alien)

(define-alien-type size_t (unsigned 64))

(define-alien-type io_context_t (unsigned 64)) ; TODO: (opaque 8)
(define-symbol-macro io_context_t.size (alien-size io_context_t :bytes))

(defstruct io-context-t
  (ptr nil :type (alien (* io_context_t))))

(defmethod print-object ((o io-context-t) stream)
  (print-unreadable-object (o stream :identity t :type t)))

(defun io-context-t.new (io_context_t*)
  (let ((o (make-io-context-t :ptr io_context_t*)))
    (sb-ext:finalize o (lambda () (free-alien io_context_t*)))))

(define-alien-type iocb
  (struct nil
    ;; these are internal to the kernel/libc
    (__data_for_kernel (unsigned 128))
    
    ;; common fields
    (lio_opcode (unsigned 16)) ; see IOCB_CMD_XXX
    (reqprio    (signed   16))
    (fildes     (unsigned 32))
    
    (buf    (* t)) ;(unsigned 64))
    (nbytes (unsigned 64))
    (offset (signed   64))

    ;; extra prameters
    (__reserved (unsigned 64))

    ;; flags for the "struct iocb"
    (flags (unsigned 32))

    ;; if the IOCB_FLAG_RESFD flag of "flags" is set,
    ;; this is an evetfd to signal AIO readiness to
    (resfd (unsigned 32))))

(define-symbol-macro iocb.size (alien-size iocb :bytes))

(eval-when (:compile-toplevel :load-toplevel)
  (defun symb (&rest args)
    (intern (format nil "~{~a~}" args))))

(defmacro defaccessor (type field)
  (let ((name (symb type "." field)))
    `(defmacro ,name (o) `(slot ,o ',',field))))

(defaccessor iocb lio_opcode)
(defaccessor iocb reqprio)
(defaccessor iocb fildes)
(defaccessor iocb buf)
(defaccessor iocb nbytes)
(defaccessor iocb offset)
(defaccessor iocb flags)
(defaccessor iocb resfd)

(defstruct buffer
  (ptr nil :type (alien (* (unsigned 1))))
  (size 0  :type (alien int)))

(defun allocate-buffer (size &key auto-free)
  (let ((o (make-buffer :size size
                        :ptr (make-alien (unsigned 1) size))))
    (if (null auto-free)
        o
      (sb-ext:finalize o (lambda () (free-buffer o))))))

(defun free-buffer (buffer)
  (free-alien (buffer-ptr buffer)))


(deftype iocb-cmd () '(member :pread :pwrite :fsync :fdsync :preadx :poll :noop :preadv :pwritev))
(defstruct request
  (op   :noop :type iocb-cmd)
  (priority 0 :type fixnum) ; XXX
  (fd       0 :type fixnum) ; XXX
  (buf      0 :type buffer)
  (nbytes   0 :type fixnum) ; XXX
  (offset   0 :type fixnum) ; XXX
  (flags    0 :type fixnum) ; XXX
  (resfd    0 :type fixnum) ; XXX
  )

(defun op-value (op)
  (declare (iocb-cmd op))
  (case op
    (:pread +IOCB_CMD_PREAD+)
    (:pwrite +IOCB_CMD_PWRITE+)
    (:fsync +IOCB_CMD_FSYNC+)
    (:fdsync +IOCB_CMD_FDSYNC+)
    (:preadx +IOCB_CMD_PREADX+)
    (:pool +IOCB_CMD_POLL+)
    (:noop +IOCB_CMD_NOOP+)
    (:preadv +IOCB_CMD_PREADV+)
    (:pwritev +IOCB_CMD_PWRITEV+)))
