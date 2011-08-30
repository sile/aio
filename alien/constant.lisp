(in-package :aio.alien)

(defconstant +EAGAIN+ 11)
(defconstant +EFAULT+ 14)
(defconstant +ENOMEM+ 12)
(defconstant +EINVAL+ 22)
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
