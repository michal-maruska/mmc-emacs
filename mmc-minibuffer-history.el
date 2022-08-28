
(require 'mmc-ring)

;; support
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




;; todo: make mmc-ring around an abstract ring. and here the variable:
;; (defvar current-ring nil "")
;;(make-ring 100))

;; We keep 2 positions:
;; Current, temporary   buffer-local ?
(defvar current-ring nil) ;(make-ring 100))
(defvar starting-ring-position 0)	; not used anymore ?
(defvar current-ring-position 0 "would be fluid, used here in several functions, for 1 editing session")




(defun minibuffer-previous-ring ()
  (interactive)
  (let ((string (previous-from-ring current-ring 'current-ring-position)))
    ;(display-message 'error "last in ring")
    (when (stringp string)
      (delete-minibuffer-contents)
      (insert string))))

(defun minibuffer-next-ring ()
  (interactive)
  (let ((string (next-from-ring current-ring 'current-ring-position)))
    (when (stringp string)
      (delete-minibuffer-contents)
      (insert string))))



;;; keymap  global !!!
;; (keymap-parent minibuffer-local-completion-map)
;; (keymap-parent minibuffer-local-must-match-map)

(mapc
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
(defvar previous-frame nil "variable to carry over/between frame switch, the previous one")

(defun mark-previous-frame ()
  ""
  (message "leaving frame -- saving in a variable")
  (setq previous-frame (selected-frame)))

(defun frame-inherit-rings (frame)
  ""
  (modify-frame-parameters
   frame
   (list (cons 'recent-buffer-ring
	       (clone-ring
		(frame-parameter previous-frame 'recent-buffer-ring)))))
  ;;(unless running-xemacs

  ;;(modify-frame-parameters (selected-frame) 'recent-buffer-ring)
  ;;  (make-variable-frame-local))
  )


;; (remove-hook 'before-make-frame-hook 'mark-previous-frame)
;; (remove-hook 'create-frame-hook 'frame-inherit-rings)
;; (remove-hook 'after-make-frame-functions 'frame-inherit-rings)


;;; Hooks
(add-hook
    'before-make-frame-hook
  'mark-previous-frame)

(if running-xemacs
    (add-hook 'create-frame-hook 'frame-inherit-rings)
  ;; after-make-frame-functions
  (add-hook
      'after-make-frame-functions
    'frame-inherit-rings))
;; FIXME: should inherit !!!




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


(defvar recent-buffer-ring (make-ring 100))

;;; the ring:
(if nil
    ;; at first i had:
    (defvar recent-buffer-ring (make-ring 100))
  (modify-frame-parameters (selected-frame) (list (cons 'recent-buffer-ring  (make-ring 100))))
  )



;;; FIXME
(defun recent-buffer-ring ()
  "Get the ring. frame-local variables do NOT work. This is work-around!!
I got tired of having the shared ring. FIXME: history ??"
  (or (frame-parameter  (selected-frame) 'recent-buffer-ring)
      (and (boundp 'recent-buffer-ring) recent-buffer-ring)
      (setq recent-buffer-ring (make-ring 100))))

;;  (recent-buffer-ring)


;; should be Advice:
(defun my-bury-buffer (&optional buffer)
  "Track buried buffers "
  (interactive)
  (let ((ring (recent-buffer-ring)))
    ;; (unless buffer (setq buffer (buffer-name)))
    (ring-remq ring (or buffer (buffer-name)))
    (bury-buffer buffer)))

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
	(cl-loop for index from 0 to (1- (ring-length ring)) by 1
	      do
	      (princ (format "%d %s\n" index
			     (ring-ref ring index)) )))))

(eval-when-compile
  (require 'cl))

(defun prune-dead-buffers-from-ring ()
  "delete from the `recent-buffer-ring' those elements which are dead buffers"
  (let ((ring (recent-buffer-ring))
	buffer)
    (cl-loop for index from 0 below (ring-length ring) by 1
	  do
	  (setq buffer (ring-ref ring index))
	  (unless (buffer-live-p (get-buffer buffer))
	  (ring-remove ring index)))))



(provide 'mmc-minibuffer-history)
