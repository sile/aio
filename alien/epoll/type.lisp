(in-package :aio.alien.epoll)
 
;; TOOD: move to another package
(eval-when (:compile-toplevel :load-toplevel)
  (defun symb (&rest args)
    (intern (format nil "~{~a~}" args))))

(defmacro defaccessor (type field)
  (let ((name (symb type "." field)))
    `(defmacro ,name (o) `(slot ,o ',',field))))

(defmacro defaccessors (type &rest fields)
  `(progn ,@(mapcar (lambda (f) `(defaccessor ,type ,f)) fields)))

;;;
(define-alien-type epoll_data
  (union nil
    (ptr (* t))
    (fd  int)
    (u32 (unsigned 32))
    (u64 (unsigned 64))))

(defaccessors epoll_data
  ptr
  fd
  u32
  u64)

;;;
(define-alien-type epoll_event
  (struct nil
    (events (unsigned 32))
    (data   epoll_data :alignment 32)))

(defaccessors epoll_event
  events
  data)

