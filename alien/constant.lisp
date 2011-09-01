(in-package :aio.alien)

(defconstant +EPERM+ 1)
(defconstant +ENOENT+ 2)
(defconstant +EINTR+ 4)
(defconstant +EIO+ 5)
(defconstant +EBADF+ 9)
(defconstant +EAGAIN+ 11)
(defconstant +ENOMEM+ 12)
(defconstant +EFAULT+ 14)
(defconstant +EEXIST+ 17)
(defconstant +EINVAL+ 22)
(defconstant +ENFILE+ 23)
(defconstant +EMFILE+ 24)
(defconstant +ENOSPC+ 28)
(defconstant +ENOSYS+ 38)

(defconstant +IOCB_CMD_PREAD+ 0)
(defconstant +IOCB_CMD_PWRITE+ 1)
(defconstant +IOCB_CMD_FSYNC+ 2)
(defconstant +IOCB_CMD_FDSYNC+ 3)
(defconstant +IOCB_CMD_PREADX+ 4) ; experimental
(defconstant +IOCB_CMD_POLL+ 5)   ; experimental
(defconstant +IOCB_CMD_NOOP+ 6)
(defconstant +IOCB_CMD_PREADV+ 7)
(defconstant +IOCB_CMD_PWRITEV+ 8)

(defconstant +F_GETFL+ 3)
(defconstant +F_SETFL+ 4)
(defconstant +O_DIRECT+ 16384)

(defconstant +EPOLL_CLOEXEC+ 524288)

(defconstant +EPOLL_CTL_ADD+ 1)
(defconstant +EPOLL_CTL_DEL+ 2)
(defconstant +EPOLL_CTL_MOD+ 3)

(defconstant +EPOLLIN+ 1)
(defconstant +EPOLLPRI+ 2)
(defconstant +EPOLLOUT+ 4)
(defconstant +EPOLLERR+ 8)
(defconstant +EPOLLHUP+ 16)
(defconstant +EPOLLRDHUP+ 8192)
(defconstant +EPOLLONESHOT+ 1073741824)
(defconstant +EPOLLET+ 2164260864) ; -2147483648)
