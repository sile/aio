(defpackage aio.alien.bytes
  (:use :common-lisp :sb-alien)
  (:export alloc-bytes
           to-bytes
           from-bytes
           size
           ref
           subbytes
           copy

           bytes-ptr
           bytes-start
           bytes-end

           bytes
           ))
(in-package :aio.alien.bytes)
