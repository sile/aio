(in-package :aio.alien.epoll)

;;; Flags to be passed to epoll_create1
(defconstant +CLOEXEC+ 524288 "Set close_on_exec")

;;; Valid opcodes ( "op" parameter ) to issue to epoll_ctl().
(defconstant +CTL_ADD+ 1 "Add a file decriptor to the interface")
(defconstant +CTL_DEL+ 2 "Remove a file decriptor from the interface")
(defconstant +CTL_MOD+ 3 "hange file decriptor epoll_event structure")

;;; epoll events
(defconstant +IN+ 1)
(defconstant +PRI+ 2)
(defconstant +OUT+ 4)
(defconstant +ERR+ 8)
(defconstant +HUP+ 16)
(defconstant +RDHUP+ 8192)
(defconstant +ONESHOT+ 1073741824)
(defconstant +ET+ 2164260864)
