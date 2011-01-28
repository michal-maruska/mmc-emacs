;;; Ring of LRU buffers:
;(defvar buffer-standing 
;  (make-ring 20)
;  "LRU  buffers")

;; (buffer-file-name)
(require 'ring)


;;;  Some more ring ops
;; Better not to know the structure !!!
(defun ring-empty-p (ring); must be a ring !!
  "is it empty?  (my improver version!)"
  (= (ring-length ring) 0))

(defun ring-assoc (ring element)
  "find the position of eq element"
  (let ((index 0)
	found)
    (while (< index (ring-length ring))
      (if (equal (ring-ref ring index) element)
	  (setq found index))
      (setq index (1+ index)))
    found))

;; remove by element (not index):
(defun ring-remq (ring element)
  "remove element eq ELEMENT in the ring"
  (let ((index (ring-assoc ring element)))
    (if index
	(ring-remove ring index))
    index))

(defun ring-to-head (ring element)
  "add the element to the head (possibly removing it first)"
  (let ((index (ring-remq ring element)))
    (ring-insert ring element) 	    ;  -at-beginning
    index))


;; We keep 2 positions:
;; Current, temporary   buffer-local ?
(defvar current-ring nil) ;(make-ring 100))
(defvar starting-ring-position 0)	; not used anymore ?
(defvar current-ring-position 0 "would be fluid, used here in several functions, for 1 editing session")

;;; Top level:
(defun previous-from-ring ()
  "get the previous element, and move the pointer"
  (when current-ring
    (if (= current-ring-position  (1- (ring-length current-ring)))
	(error "End of history; no next item"))
    (setq current-ring-position
	  (ring-plus1 current-ring-position (ring-length current-ring)))
    (unless (ring-empty-p current-ring)
      (ring-ref current-ring current-ring-position))))


(unless emacs-21
  (defun delete-minibuffer-contents()
    ""
					;(erase-buffer)
    (delete-region
     (progn
       ;; fixme: emacs 24:
       (move-beginning-of-line nil)
       (point))
     (point-max))
    ))


(defun minibuffer-previous-ring ()
  (interactive)
  (let ((string (previous-from-ring)))
    ;(display-message 'error "last in ring")
    (when (stringp string)
      (delete-minibuffer-contents)
      (insert string))))

(defun next-from-ring ()
  "get the next element, and move the pointer"
  (when current-ring
    (if (= current-ring-position 0)
	(error "End of history; no next item"))
    (setq current-ring-position
	  (ring-minus1 current-ring-position (ring-length current-ring)))
    (unless (ring-empty-p current-ring)
      (ring-ref current-ring current-ring-position))))

(defun minibuffer-next-ring ()
  (interactive)
  (let ((string (next-from-ring)))
    (when (stringp string)
      (delete-minibuffer-contents)
      (insert string))))

;;; Test
(when nil
  (setq current-ring (make-ring 100))
  (mapcar
   (lambda (atom)
     (ring-insert current-ring atom)
     )
   '("a" "b" "c" "d"))
  (ring-remove current-ring 2)
  )



;  (setq current-ring-position 0)
;  (ring-remove current-ring 2)
;; After we have determined the selected value:
;(setq selected-value (cur)

;;; keymap  global !!!
;; (keymap-parent minibuffer-local-completion-map)
;; (keymap-parent minibuffer-local-must-match-map)

(mapcar
 (lambda (map)
   (define-key map [(control ?n)] 'minibuffer-next-ring)
   (define-key map [(control ?p)] 'minibuffer-previous-ring))
 (list minibuffer-local-completion-map
       minibuffer-local-must-match-map
       ;; my-minibuffer-local-completion-map
       ))
(when nil
  (lookup-key minibuffer-local-completion-map
	      ;;my-minibuffer-local-completion-map
	      "\C-p")
  )
; (defvar ring-history ())



;;; switching buffers



(defvar previous-frame nil "")
;;; Hooks
(add-hook 
 'before-make-frame-hook
 (lambda ()
   (message "leaving frame")
   (setq previous-frame (selected-frame))))

(if running-xemacs
    (add-hook 'create-frame-hook 'frame-inherit-rings)
  ;; after-make-frame-functions
  (add-hook
   'after-make-frame-functions 
   'frame-inherit-rings))
;; FIXME: should inherit !!!
 
(defun frame-inherit-rings (frame)
  ""
  (modify-frame-parameters
   frame
   (list (cons 'recent-buffer-ring
	       (clone-ring 
		(frame-parameter previous-frame 'recent-buffer-ring)))))
  (unless running-xemacs
    (make-variable-frame-local 'recent-buffer-ring))
  )


(when running-xemacs
  (defalias 'frame-parameter 'frame-property))
'(defun frame-parameter ()
  ""
  (frame-property (selected-frame) 'name)
  ;(frame-parameters (selected-frame))
  )



;;; frame.el
(when nil
  ;;
  (progn
    (other-frame 1)
    (frame-parameter  (selected-frame) 'recent-buffer-ring))

  (make-local-variable 'maruska)
  (setq foo '(b 1))
  (modify-frame-parameters (selected-frame) (list (cons 'recent-buffer-ring  (make-ring 100))))
  ;; Make a frame-local binding for `foo' in a new frame.
  ;; Store that frame in `f2'.
  (setq f2 (make-frame))
  (frame-parameter  (selected-frame) 'recent-buffer-ring)
  (frame-parameters (selected-frame))
  (modify-frame-parameters (selected-frame) '((maruska . "ahoj")))

  (make-variable-frame-local 'recent-buffer-ring)
  (setq recent-buffer-ring recent-buffer-ring-e)
  (setq recent-buffer-ring nil)
  (setq recent-buffer-ring (make-ring 100))
  )




;;; the ring: 
(if nil
    ;; at first i had:
    (defvar recent-buffer-ring (make-ring 100))
  (modify-frame-parameters (selected-frame) (list (cons 'recent-buffer-ring  (make-ring 100))))
  )



;;  (recent-buffer-ring)
;;; FIXME
(defun recent-buffer-ring ()
  "Get the ring. frame-local variables do NOT work. This is work-around!!
I got tired of having the shared ring. FIXME: history ??"
  (or (frame-parameter  (selected-frame) 'recent-buffer-ring)
      (and (boundp 'recent-buffer-ring) recent-buffer-ring)
      (setq recent-buffer-ring (make-ring 100))))

;; should be Advice:
(defun my-bury-buffer (&optional buffer)
  "Track buried buffers "
  (interactive)
  (let ((ring (recent-buffer-ring)))
    ;; (unless buffer (setq buffer (buffer-name)))
    (ring-remq ring (or buffer (buffer-name)))
    (bury-buffer buffer)))


(define-key my-global-keymap [?u] 'my-bury-buffer)
;(when nil (global-set-key [ (control ?x ) ?b] 'my-switch-buffer))

(defun ring-head (ring)
  ""
  (car ring))



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

(defadvice switch-to-buffer (after push-to-ring nil activate)
  "notify the change to my memory/ring, we keep the LRU thing"
  ;; Now insert the ....
  (let ((current-ring (recent-buffer-ring))
	(buffer       (buffer-name (current-buffer))))
    (ring-to-head current-ring buffer))) ; was ring-lru ...


;;recent-buffer-ring
(defun visualize-buffer-ring ()
  ""
  (interactive)
  (prune-dead-buffers-from-ring)
  (let ((ring (recent-buffer-ring))
	buffer )
    (with-output-to-temp-buffer "*ring*"
	(loop for index from 0 to (1- (ring-length ring)) by 1
	      do
	      (princ (format "%d %s\n" index
			     (ring-ref ring index)) )))))

(require 'cl)
(defun prune-dead-buffers-from-ring ()
  "delete from the `recent-buffer-ring' those elements which are dead buffers"
  (let ((ring (recent-buffer-ring))
	buffer)
    (loop for index from 0 below (ring-length ring) by 1
	  do
	  (setq buffer (ring-ref ring index))
	  (unless (buffer-live-p (get-buffer buffer))
	  (ring-remove ring index)))))


;buffers-menu-switch-to-buffer-function
; (ding "aafda")
; (c-x x u) !!
;;current-ring
(provide 'mmc-ring)
