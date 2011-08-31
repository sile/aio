(defpackage aio.alien
  (:use :common-lisp :sb-alien)
  (:export io-context-t
           
           io-setup
           io-destroy
           io-submit 
           io-cancel
           io-getevents

           allocate-buffer
           free-buffer
           make-request
           
           o-direct

           %epoll-create
           %close
           %epoll-ctl-add
           %epoll-ctl-mod
           %epoll-ctl-del
           %epoll-wait

           allocate-events
           free-events
           ))
(in-package :aio.alien)
