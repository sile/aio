(defpackage aio
  (:use :common-lisp)
  (:export *default-maxevents*
           *default-context*
           *default-epoll*
           
           set-handler
           wait

           nonblock-read
           nonblock-write
           
           read  ; TODO: add 'non-block' option
           write
           with-ensure-nonblock 
           
           alloc-bytes
           free-bytes
           ;; TODO: with-xxx
           
           to-lisp-string

           ;;;;;;;;;;
           ;; TODO: aio.eventパッケージ?
           create-context
           close-context
           set-event
           del-event
           do-event
           ))
(in-package :aio)

(defparameter *fastest* '(optimize (speed 3) (safety 0) (debug 0)))
(defparameter *interface* '(optimize (speed 3) (safety 2) (debug 1)))

(defvar *default-maxevents* 1024)
(defvar *default-context* (aio.alien.epoll:create :cloexec t)) ; XXX

(defvar *default-epoll* (aio.alien:%epoll-create))

(defvar *default-event-buffer* (aio.alien:allocate-events 16))
