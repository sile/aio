(in-package :aio)

(defun read (fd bytes &key force-nonblock)
  (let* ((base (aio.alien.bytes:bytes-ptr bytes))
         (start (aio.alien.bytes:bytes-start bytes))
         (end (aio.alien.bytes:bytes-end bytes))

         (ptr (sb-alien:addr (sb-alien:deref base start)))
         (size (- end start)))
    (aio.alien.io:read fd ptr size :force-nonblock force-nonblock)))

(defun write (fd bytes &key force-nonblock)
  (let* ((base (aio.alien.bytes:bytes-ptr bytes))
         (start (aio.alien.bytes:bytes-start bytes))
         (end (aio.alien.bytes:bytes-end bytes))

         (ptr (sb-alien:addr (sb-alien:deref base start)))
         (size (- end start)))
  (aio.alien.io:write fd ptr size :force-nonblock force-nonblock)))

(defmacro ensure-nonblock ((fd) &body body)
  `(aio.alien.io:ensure-nonblock (,fd)
     ,@body))
