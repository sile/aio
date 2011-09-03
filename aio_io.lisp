(in-package :aio)

(defun read (fd bytes size &key force-nonblock)
  (aio.alien.io:read fd bytes size :force-nonblock force-nonblock))

(defun write (fd bytes size &key force-nonblock)
  (aio.alien.io:write fd bytes size :force-nonblock force-nonblock))

(defmacro ensure-nonblock ((fd) &body body)
  `(aio.alien.io:ensure-nonblock (,fd)
     ,@body))
