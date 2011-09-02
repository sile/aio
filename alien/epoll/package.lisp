(defpackage aio.alien.epoll
  (:use :common-lisp :sb-alien)
  (:shadow :common-lisp close)
  (:export create
           close
           wait do-event
           ctl-add
           ctl-mod
           ctl-del

           event-in
           event-out
           event-pri
           event-err
           event-hup
           event-rdhup
           event-et
           event-oneshot
           ))
(in-package :aio.alien.epoll)
