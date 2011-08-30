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

#|
struct iocb {
        /* these are internal to the kernel/libc. */
        __u64   aio_data;       /* data to be returned in event's data */
        __u32   PADDED(aio_key, aio_reserved1);
                                /* the kernel sets aio_key to the req # */

        /* common fields */
        __u16   aio_lio_opcode; /* see IOCB_CMD_ above */
        __s16   aio_reqprio;
        __u32   aio_fildes;

        __u64   aio_buf;
        __u64   aio_nbytes;
        __s64   aio_offset;

        /* extra parameters */
        __u64   aio_reserved2;  /* TODO: use this for a (struct sigevent *) */

        /* flags for the "struct iocb" */
        __u32   aio_flags;

        /*
         * if the IOCB_FLAG_RESFD flag of "aio_flags" is set, this is an
         * eventfd to signal AIO readiness to
         */
        __u32   aio_resfd;
}; /* 64 bytes */
|#
(define-alien-type iocb
  (struct nil
    ;; these are internal to the kernel/libc
    (__data_for_kernel (unsigned 128))
    
    ;; common fields
    (lio_opcode (unsigned 16)) ; see IOCB_CMD_XXX
    (reqprio    (signed   16))
    (fildes     (unsigned 32))
    
    (buf    (unsigned 64))
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
