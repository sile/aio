(in-package :aio.alien.bytes)

(defstruct bytes
  (ptr 0 :type (alien (* (unsigned 8))))
  (start 0 :type fixnum)
  (end 0 :type fixnum))

(defun bytes-size (bytes)
  (with-slots (start end) bytes
    (- end start)))

(defmethod print-object ((o bytes) stream)
  (print-unreadable-object (o stream :identity t)
    (format stream "~a ~s ~a" :bytes :size (bytes-size o))))

(defun size (bytes)
  (bytes-size bytes))

(defun alloc-bytes (size)
  (let ((o (make-alien (unsigned 8) size)))
    (sb-ext:finalize (make-bytes :ptr o :start 0 :end size)
                     (lambda () (free-alien o)))))

(defun ref (bytes index)
  (with-slots (ptr start) (the bytes bytes)
    (deref ptr (+ start index))))

(defun (setf ref) (new-value bytes index)
  (with-slots (ptr start) (the bytes bytes)
    (setf (deref ptr (+ start index)) new-value)))

(defun to-bytes (lisp-octets &key (start 0) (end (length lisp-octets)))
  (let* ((len (- end start))
         (bytes (alloc-bytes len)))
    (dotimes (i len bytes)
      (setf (ref bytes i) (aref lisp-octets (+ i start))))))

(defun from-bytes (bytes &key (start 0) (end (bytes-size bytes)))
  (let* ((len (- end start))
         (octets (make-array len :element-type '(unsigned-byte 8))))
    (dotimes (i len octets)
      (setf (aref octets i) (ref bytes (+ i start))))))

(defun subbytes (bytes start &optional end)
  (with-slots (ptr (offset start)) bytes
    (make-bytes :ptr ptr
                :start (+ offset start)
                :end (+ offset end))))
