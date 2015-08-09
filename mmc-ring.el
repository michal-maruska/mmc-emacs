;;; Ring of LRU buffers:

;; Fixme:  frame-local- is now broken.
;; and is this used at all?


;(defvar buffer-standing
;  (make-ring 20)
;  "LRU  buffers")

;; (buffer-file-name)
(require 'ring)


;;;  Some more ring ops

;; ring-assoc obsoleted by ring-member


;; remove by element (not index):
(defun ring-remq (ring item)
  "remove element eq ITEM in the ring"
  (let (ind)
    (while (setq ind (ring-member ring item))
      (ring-remove ring ind))))


;; ring-remove+insert+extend
(defun ring-to-head (ring item)
  "add the element to the head (possibly removing it first)"
  (ring-remove+insert+extend ring item 'grow))


;;; Top level:
(defun previous-from-ring (ring ring-position-symbol)
  "get the previous element, and move the pointer"
  (when ring
    (if (= (symbol-value ring-position-symbol)  (1- (ring-length ring)))
	(error "End of history; no next item"))
    (set ring-position-symbol
	 (ring-plus1 (symbol-value ring-position-symbol)
		     (ring-length ring)))
    (unless (ring-empty-p ring)
      (ring-ref ring (symbol-value ring-position-symbol)))))

(defun next-from-ring (ring ring-position-symbol)
  "get the next element, and move the pointer"
  (when ring
    (if (= (symbol-value ring-position-symbol) 0)
	(error "End of history; no next item"))
    (set ring-position-symbol
	 (ring-minus1 (symbol-value ring-position-symbol)
		      (ring-length ring)))
    (unless (ring-empty-p ring)
      (ring-ref ring (symbol-value ring-position-symbol)))))

(defun ring-head (ring)
  ""
  (car ring))

;; todo: move to mmc-vector
(defun copy-vector (from to)
  "we have 2 vectors: to MUST be longer= than FROM"
  (let ((index 0)
	(size (length from)))
    (while (< index size)
      (aset to index (aref from index))
      (setq index (1+ index)))))

(defun ring-vector (ring)
  "return the vector associated w/ RING"
  (cdr (cdr ring)))

(defun clone-ring (ring)
  "return a deep-copy of the RING"
  (let* ((length (length (ring-vector ring)))
	 (vector (make-vector length nil)))
    (copy-vector (ring-vector ring) vector)
    (cons
     (ring-head ring)
     (cons (ring-length ring) vector))))

;;(clone-ring recent-buffer-ring)

(defun ring-lru- (ring object)
  ""
  (ring-to-head ring object)
  ;; (setq starting-ring-position		; global var
  ;; 	  (ring-plus1 starting-ring-position
  ;; 		      (ring-length ring)))
  )

;;; Test
(when nil
  (setq current-ring (make-ring 100))
  (mapc
   (lambda (atom)
     (ring-insert current-ring atom)
     )
   '("a" "b" "c" "d"))
  (ring-remove current-ring 2))



;  (setq current-ring-position 0)
;  (ring-remove current-ring 2)
;; After we have determined the selected value:
;(setq selected-value (cur)

;buffers-menu-switch-to-buffer-function
; (ding "aafda")
; (c-x x u) !!
;;current-ring
(provide 'mmc-ring)
