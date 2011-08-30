(defpackage aio.alien
  (:use :common-lisp :sb-alien)
  (:export io-setup
           io-destroy
           io-submit 
           io-cancel
           io-getevents))
(in-package :aio.alien)