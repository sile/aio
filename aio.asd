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

               (:file "alien/io/package")
               (:file "alien/io/function")
               (:file "alien/io/io")

               (:file "alien/bytes/package")
               (:file "alien/bytes/bytes")

               (:file "package")
               (:file "aio_event")
               (:file "aio_io")
               (:file "aio_bytes")
               ))
