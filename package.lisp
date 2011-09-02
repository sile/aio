(defpackage aio
  (:use :common-lisp)
  (:export *default-context*

           context
           create-context
           watch
           unwatch
           do-event

           event
           event-in  ; in? or in-p
           event-out
           event-pri
           event-err
           event-hup
           event-rdhup
           event-et
           event-oneshot
           ))
(in-package :aio)

(defparameter *fastest* '(optimize (speed 3) (safety 0) (debug 0)))
(defparameter *interface* '(optimize (speed 3) (safety 2) (debug 1)))

;; (defvar *default-context* (aio.alien.epoll:create :cloexec t)) ; XXX

