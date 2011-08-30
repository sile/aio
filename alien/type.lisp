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
