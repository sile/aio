(defpackage aio
  (:use :common-lisp)
  (:shadow :common-lisp read write)
  (:export ;; TODO: aio.event
           *default-context*

           context
           create-context
           watch
           unwatch
           do-event

           event
           event-case 

           event-in  ; in? or in-p
           event-out
           event-pri
           event-err
           event-hup
           event-rdhup
           event-et
           event-oneshot
           
           ;; TODO: aio.io
           ensure-nonblock
           read
           write

           ;; TODO: aio.bytes
           make-bytes
           to-bytes
           from-bytes
           subbytes
           byte-ref
           bytes-size
           copy
           ))
(in-package :aio)

(defparameter *fastest* '(optimize (speed 3) (safety 0) (debug 0)))
(defparameter *interface* '(optimize (speed 3) (safety 2) (debug 1)))

;; (defvar *default-context* (aio.alien.epoll:create :cloexec t)) ; XXX

