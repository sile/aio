(defpackage aio.error
  (:use :common-lisp)
  (:nicknames aio.e)
  (:export str
           
           2BIG
           ACCES
           ADDRINUSE
           ADDRNOTAVAIL
           ADV
           AFNOSUPPORT
           AGAIN
           ALREADY
           BADE
           BADF
           BADFD
           BADMSG
           BADR
           BADRQC
           BADSLT
           BFONT
           BUSY
           CANCELED
           CHILD
           CHRNG
           COMM
           CONNABORTED
           CONNREFUSED
           CONNRESET
           DEADLK
           DEADLOCK
           DESTADDRREQ
           DOM
           DOTDOT
           DQUOT
           EXIST
           FAULT
           FBIG
           HOSTDOWN
           HOSTUNREACH
           IDRM
           ILSEQ
           INPROGRESS
           INTR
           INVAL
           IO
           ISCONN
           ISDIR
           ISNAM
           KEYEXPIRED
           KEYREJECTED
           KEYREVOKED
           L2HLT
           L2NSYNC
           L3HLT
           L3RST
           LIBACC
           LIBBAD
           LIBEXEC
           LIBMAX
           LIBSCN
           LNRNG
           MEDIUMTYPE
           MFILE
           MLINK
           MSGSIZE
           MULTIHOP
           NAMETOOLONG
           NAVAIL
           NETDOWN
           NETRESET
           NETUNREACH
           NFILE
           NOANO
           NOBUFS
           NOCSI
           NODATA
           NODEV
           NOEN
           NOEXEC
           NOKEY
           NOLCK
           NOLINK
           NOMEDIUM
           NOMEM
           NOMSG
           NONET
           NOPKG
           NOPROTOOPT
           NOSPC
           NOSR
           NOSTR
           NOSYS
           NOTBLK
           NOTCONN
           NOTDIR
           NOTEMPTY
           NOTNAM
           NOTRECOVERABLE
           NOTSOCK
           NOTTY
           NOTUNIQ
           NXIO
           OPNOTSUPP
           OVERFLOW
           OWNERDEAD
           PERM
           PFNOSUPPORT
           PIPE
           PROTO
           PROTONOSUPPORT
           PROTOTYPE
           RANGE
           REMCHG
           REMOTE
           REMOTEIO
           RFKILL
           ROFS
           SHUTDOWN
           SOCKTNOSUPPORT
           SPIPE
           SRCH
           SRMNT
           STALE
           STRPIPE
           TIMEDOUT
           TOOMANYREFS
           TXTBSY
           UCLEAN
           UNATCH
           USERS
           WOULDBLOCK
           XDEV
           XFULL))
(in-package :aio.error)
