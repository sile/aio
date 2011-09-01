(in-package :asdf)

(defsystem aio
  :name "aio"
  :author "Takeru Ohta"
  :version "0.0.1"
  :description "Asynchronous A/O pakcage for SBCL"
  
  :serial t
  :components ((:file "error/package")
               (:file "error/error")
;;               (:file "alien/common/package")
;;               (:file "alien/common/common")

               (:file "alien/epoll/package")
               (:file "alien/epoll/constant")
               (:file "alien/epoll/type")
               (:file "alien/epoll/function")
               (:file "alien/epoll/epoll")
               
               (:file "alien/package")
               (:file "alien/init")
               (:file "alien/constant")
               (:file "alien/type")
               (:file "alien/function")
               
               (:file "package")
               (:file "aio")))
