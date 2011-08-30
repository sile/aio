(in-package :asdf)

(defsystem aio
  :name "aio"
  :author "Takeru Ohta"
  :version "0.0.1"
  :description "Asynchronous A/O pakcage for SBCL"
  
  :serial t
  :components ((:file "alien/package")
               (:file "alien/init")
               (:file "alien/constant")
               (:file "alien/type")
               (:file "alien/function")
               
               (:file "package")
               (:file "aio")))
