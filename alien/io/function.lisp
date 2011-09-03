(in-package :aio.alien.io)

(define-alien-type size_t (unsigned 64)) ;; XXX:
(define-alien-type ssize_t (signed 64)) ;; XXX:

(define-alien-routine ("read" %read) ssize_t (fd int) (buf (* t)) (count size_t))
(define-alien-routine ("write" %write) ssize_t (fd int) (buf (* t)) (count size_t))
(define-alien-routine ("fcntl" %fcntl) int (fd int) (cmd int) (arg int))

(defconstant +O_NONBLOCK+ 2048) ;; XXX:
(defconstant +F_GETFL+ 3)
(defconstant +F_SETFL+ 4)