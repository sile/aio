(in-package :aio)

(defun make-bytes (size)
  (aio.alien.bytes:alloc-bytes size))

(defun to-bytes (lisp-bytes)
  (aio.alien.bytes:to-bytes lisp-bytes))

(defun from-bytes (bytes)
  (aio.alien.bytes:from-bytes bytes))

(defun subbytes (bytes start &optional end)
  (aio.alien.bytes:subbytes bytes start end))

(defun byte-ref (bytes index)
  (aio.alien.bytes:ref bytes index))

(defun bytes-size (bytes)
  (aio.alien.bytes:size bytes))

(defun copy (destination source)
  (aio.alien.bytes:copy destination source))