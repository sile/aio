(defpackage aio.alien.epoll
  (:use :common-lisp :sb-alien)
  (:shadow :common-lisp close)
  (:export create
           close
           wait
           ctl-add
           ctl-mod
           ctl-del))
(in-package :aio.alien.epoll)


          