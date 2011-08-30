(defpackage aio
  (:use :common-lisp)
  (:export *default-maxevents*
           *default-context*))
(in-package :aio)

(defparameter *fastest* '(optimize (speed 3) (safety 0) (debug 0)))
(defparameter *interface* '(optimize (speed 3) (safety 2) (debug 1)))

(defvar *default-maxevents* 1024)
(defvar *default-context* (aio.alien:io-setup *default-maxevents*))