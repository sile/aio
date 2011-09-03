(in-package :aio.alien.io)

;; TODO: move to other package
(defmacro unix-return (exp &key on-success on-fail)
  (let ((ret (gensym))
        (err (gensym)))
    `(let ((,ret ,exp))
       (if (= -1 ,ret)
           (let ((,err (aio.e:errno)))
             (values ,(typecase on-fail
                        (null nil)
                        (cons `(funcall ,on-fail ,err))
                        (t    on-fail))
                     ,err))
         (values ,(typecase on-success
                    (null ret)
                    (cons `(funcall ,on-success ,ret))
                    (t    on-success))
                 aio.e:SUCCESS)))))

(define-symbol-macro +O_NONBLOCK_BIT+ (byte 1 #.(1- (integer-length +O_NONBLOCK+))))

(defun nonblock (fd)
  (unix-return (%fcntl fd +F_GETFL+ 0)
               :on-success (lambda (flag)
                             (ldb-test +O_NONBLOCK_BIT+ flag))))

(defun (setf nonblock) (nonblock? fd)
  (unix-return (%fcntl fd +F_GETFL+ 0)
               :on-success (lambda (flag)
                             (setf (ldb +O_NONBLOCK_BIT+ flag)
                                   (if nonblock? 1 0))
                             (unix-return (%fcntl fd +F_SETFL+ flag)
                                          :on-success nonblock?))))

(defmacro ensure-nonblock ((fd) &body body)
  `(if (nonblock ,fd)
       (locally ,@body)
     (progn
       (unless (setf (nonblock ,fd) t)
         ;; TODO: 
         (error "Can't set O_NONBLOCK flag as true (FD=~a). ~%reason: ~a"
                ,fd (aio.e:str (aio.e:errno)))) ;; aio.e:str => (aio.e:message or reason default)
       (unwind-protect
           (locally ,@body)
         (setf (nonblock ,fd) nil))))) ;; TODO: check

(defun read (fd bytes size &key force-nonblock)
  (if (not force-nonblock)
      #1=(unix-return (%read fd bytes size)
                      :on-fail (lambda (err)
                                 (when (= err aio.e:AGAIN) 
                                   :blocked)))
    (ensure-nonblock (fd) #1#)))

(defun write (fd bytes size &key force-nonblock)
  (if (not force-nonblock)
      #1=(unix-return (%write fd bytes size)
                      :on-fail (lambda (err)
                                 (when (= err aio.e:AGAIN) 
                                   :blocked)))
    (ensure-nonblock (fd) #1#)))
