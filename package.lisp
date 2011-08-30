(defpackage aio
  (:use :common-lisp :sb-alien)
  (:export ))
(in-package :aio)

(defparameter *fastest* '(optimize (speed 3) (safety 0) (debug 0)))
(defparameter *interface* '(optimize (speed 3) (safety 2) (debug 1)))


  