(defpackage aio
  (:use :common-lisp)
  (:export *default-maxevents*
           *default-context*
           *default-epoll*
           
           set-handler
           wait

           nonblock-read
           nonblock-write
           
           alloc-bytes
           free-bytes
           ;; TODO: with-xxx
           
           to-lisp-string
           ))
(in-package :aio)

(defparameter *fastest* '(optimize (speed 3) (safety 0) (debug 0)))
(defparameter *interface* '(optimize (speed 3) (safety 2) (debug 1)))

(defvar *default-maxevents* 1024)
(defvar *default-context* (aio.alien:io-setup *default-maxevents*))

(defvar *default-epoll* (aio.alien:%epoll-create))

(defvar *default-event-buffer* (aio.alien:allocate-events 16))
