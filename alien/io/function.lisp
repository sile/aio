(in-package :aio.alien.io)

(define-alien-type size_t (unsigned 64)) ;; XXX:
(define-alien-type ssize_t (signed 64)) ;; XXX:

(define-alien-routine read ssize_t (fd int) (buf (* t)) (count size_t))
(define-alien-routine write ssize_t (fd int) (buf (* t)) (count size_t))
