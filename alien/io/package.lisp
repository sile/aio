(defpackage aio.alien.io
  (:use :common-lisp :sb-alien)
  (:shadow :common-lisp read write)
  (:export read
           write
           ensure-nonblock))
(in-package :aio.alien.io)
