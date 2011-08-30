(defpackage aio.alien
  (:use :common-lisp :sb-alien)
  (:export io-context-t
           
           io-setup
           io-destroy
           io-submit 
           io-cancel
           io-getevents
           io-fsync))
(in-package :aio.alien)
