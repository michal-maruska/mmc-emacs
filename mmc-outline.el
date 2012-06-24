;;; my-outline.el --- key-bindings

(require 'outline)

(eval-and-compile
  (when running-xemacs
    (define-minor-mode outline-minor-mode
      "Toggle Outline minor mode.
With arg, turn Outline minor mode on if arg is positive, off otherwise.
See the command `outline-mode' for more information on this mode."
      nil " Outl" (list (cons [menu-bar] outline-mode-menu-bar-map)
			(cons outline-minor-mode-prefix
			      outline-mode-prefix-map))
      )))


;; http://ruska.dyndns.org/comp/emacs/local/my-outline.el
;; allout.el
(when nil
   (require 'allout)
   (outline-init 't)
   )


;; fold.el
;; koutl-mode
;; hyperbole

;; Author: Michal Maruska <mmc@linux4.maruska.tin.it>
;; Keywords: local

;;; Commentary:

;; see my-perl.el
;; grep outline-regexp

;;; Code:

;(defalias define-minor-mode
(setq outline-minor-mode-prefix "\C-c\C-d")

;;(defadvice find-file
; (define-minor-mode MODE DOC &optional INIT-VALUE LIGHTER KEYMAP)


;;(defmacro emacs-define-minor-mode (mode doc &optional init-value lighter keymap &rest body)
;;  (list 'define-minor-mode mode doc init-value lighter keymap))

(require 'advice)
'(defadvice define-minor-mode (before emacs-compatible
                              (MODE DOC &optional INIT-VALUE LIGHTER KEYMAP &rest body)
                              activate)
  ad-do-it)


;(keymapp outline-minor-mode-map)

(unless
    (lookup-key outline-minor-mode-map (kbd "\C-c\C-d"))
  (define-key outline-minor-mode-map (kbd "\C-c\C-d")
    (lookup-key outline-minor-mode-map (kbd "\C-c@"))))

;;; Regexp:


;; lisp:
;; (setq outline-regexp "\\(;;;*\\) \\|(")
;;";;;;* \\|("
;; (setq outline-regexp "^[a-zA-Z_.]*:")
;; outline:
;; should be loaded after ?

(unless running-xemacs
  (set-default 'outline-regexp "\*")
  (setq outline-regexp "##*|<Location")
  (setq outline-regexp "\\*+")
  (set-default 'outline-regexp "\\*+")
)

;;; still regexp
(defun my-outline ()
  ""
  (interactive)
  (setq outline-regexp "\*"))

;;; keymaps

;; winhist-forward  m-F
(when 't
  (global-set-key [(meta ?P)] 'outline-previous-visible-heading)
  (global-set-key [(meta ?N)] 'outline-next-visible-heading)
  (global-set-key [(meta ?F)] 'outline-forward-same-level)
  (global-set-key [(meta ?B)] 'outline-backward-same-level)

;  (global-set-key [(meta ?M)] 'outline-back-to-heading)
  (global-set-key [(meta ?M)] 'outline-mark-subtree)
  (global-set-key [(meta ?U)] 'outline-up-heading)

  (global-set-key [(meta ?I)] 'show-children)
  (global-set-key [(meta ?K)] 'show-branches)
  (global-set-key [(meta ?L)] 'hide-leaves)

  (global-set-key [(meta ?A)] 'show-all)
  (global-set-key [(meta ?Y)] 'show-all)
  (global-set-key [(meta ?T)] 'hide-body)

  ;;
  (global-set-key [(meta ?E)] 'show-entry)
  (global-set-key [(meta ?C)] 'hide-entry)
  ;;
  (global-set-key [(meta ?D)] 'hide-subtree)
  (global-set-key [(meta ?S)] 'show-subtree) ; not so good:
  (global-set-key [(meta ?_)] 'show-entry)

					;(lookup-key outline-mode-map  [(meta ?S)])
					;(define-key outline-mode-map  [(meta ?S)] nil)

  (global-set-key [(meta ?O)] 'hide-other)
  (global-set-key [(meta ?Q)] (lambda ()
				(hide-sublevels 1))))



;;; my 2nd ---- inspired by infodock:
(defun outline-level-inverse ()
  ""
  (- 4 (outline-level)))


(define-key outline-mode-prefix-map  [return ] 'outline-commands)
(define-key outline-mode-prefix-map  [(control ?m)] 'my-outline-mode)
(global-set-key [(control meta ?-)] 'outline-commands)


(defvar my-outline-keymap (make-sparse-keymap)
  "")

(easy-mmode-define-minor-mode
 my-outline-mode
 ""
 nil
 "OUT"
 my-outline-keymap
 )


(defun define-key-even-control (map letter function)
  "bind the letter and even C-letter"
  (define-key map (make-vector 1 letter) function)
  (define-key map (make-vector 1 `(control ,letter)) function))

; (lookup-key my-outline-keymap [(control ?a)] 't)

(let ((map my-outline-keymap)
      )
  ;; default
  ;(define-key map [ t ] 'my-outline-exit)          ; i give-up
  ; (define-key map [ t ] nil)
  ;;
  ;(define-key map [ (contol ?m) ] 'my-outline-exit)
  (define-key map [ return ] 'my-outline-exit)
  (define-key map [ (control ?m) ] 'my-outline-exit)
  (define-key-even-control map ?f 'outline-forward-same-level)
  (define-key-even-control map ?b 'outline-backward-same-level)

  (define-key-even-control map ?p 'outline-previous-visible-heading)
  (define-key-even-control map ?n 'outline-next-visible-heading)
  (define-key-even-control map ?u 'outline-up-heading)

  (define-key-even-control map ?i 'show-children)
  (define-key-even-control map ?k 'show-branches)

  (define-key-even-control map ?a 'show-all)
  (define-key-even-control map ?t 'hide-body)
  (define-key-even-control map ?l 'hide-leaves)

  (define-key-even-control map ?c 'hide-entry)
  (define-key-even-control map ?e 'show-entry)

  (define-key-even-control map ?d 'hide-subtree)
  (define-key-even-control map ?s 'show-subtree)


  (define-key-even-control map ?q 'hide-sublevels)	; 1
  (define-key-even-control map ?o 'hide-other)
  )



(defun event-is-not-intended (event)
  (or
   (and (listp event)
	(eq (car event) 'switch-frame))))


(defun my-outline-exit ()
  ""
  (interactive)
  (let ((this-event last-input-event)
	)
    (if (event-is-not-intended this-event)
	(funcall (lookup-key global-map this-event))
      (progn
	  (my-outline-mode nil)
	  (setq my-outline-mode nil)
	  (if nil
	      (setq unread-command-events
		    (cons			;(listify-key-sequence
		     this-event			;)
		     unread-command-events)))))))



(defun outline-commands (&optional arg)
  "Resize window interactively."

  (interactive "p")
  (or arg (setq arg 1))
  (let (c)
    (catch 'done
      (while t
	(message
	 ;; arg
	 "n,p,f,b,u   aLL, /t body, s/d subtree, /q sublevels, /oTHER, /lEAVES, k/ branches, i/ chIldren, e/c NTRY")
	(setq c (read-char))
	(condition-case ()
	    (cond
	     ((eq c ?\^G) (throw 'done t)) ; (keyboard-quit)
	     ((eq c ?\^m) (throw 'done t))

	     ((eq c ?f) (outline-forward-same-level arg))
	     ((eq c ?b) (outline-backward-same-level arg))

	     ((eq c ?p) (outline-previous-visible-heading arg))
	     ((eq c ?n) (outline-next-visible-heading arg))
	     ((eq c ?u) (outline-up-heading arg))


	     ((eq c ?i) (show-children))
	     ((eq c ?k) (show-branches))

	     ((eq c ?a) (show-all))
	     ((eq c ?t) (hide-body))
	     ((eq c ?l) (hide-leaves))

	     ((eq c ?c) (hide-entry))
	     ((eq c ?e) (show-entry))

	     ((eq c ?d) (hide-subtree))
	     ((eq c ?s) (show-subtree))


	     ((eq c ?q) (hide-sublevels 1))
	     ((eq c ?o) (hide-other))

	     ((eq c ? ) (throw 'done t))

	     ((and (> c ?0) (<= c ?9)) (setq arg (- c ?0)))
	     (t (beep)))
	  (error (beep)))))
    (message "Finished outline commands")) )


(unless running-xemacs
  (set-default 'selective-display t)

  ;; (eval-after-load
  (require 'disp-table)
  (set-display-table-slot
   standard-display-table
   'selective-display
   ;[?M ?o ?r ?e ?. ?. ?.]
   [?\  ?. ?. ?.]
   ;[?\  46 46 46]
   ))




;(defadvice outline-back-to-heading &optional invisible no-error)


'(defun show-entry ()
  "Show the body directly following this heading.
Show the heading too, if it is currently invisible."
  (interactive)
  (save-excursion
    (condition-case nil
	(outline-back-to-heading t)
      (error
       (beginning-of-buffer)))
    (outline-flag-region (1- (point))
			 (progn (outline-next-preface) (point)) nil)))



(defun outline-back-to-heading (&optional invisible-ok)
  "Move to previous heading line, or beg of this line if it's a heading.
Only visible heading lines are considered, unless INVISIBLE-OK is non-nil."
  (beginning-of-line)
  (or (outline-on-heading-p invisible-ok)
      (let (found)
	(save-excursion
	  (while (not found)
	    (or (re-search-backward (concat "^\\(" outline-regexp "\\)")
				    nil t)
		;; mmc:
		(goto-char (point-min)); (error "before first heading")
		)
	    (setq found (and (or invisible-ok (not (outline-invisible-p)))
			     (point)))))
	(goto-char found)
	found)))


'(defun show-entry ()
  "Show the body directly following this heading.
Show the heading too, if it is currently invisible."
  (interactive)
  (save-excursion
    (condition-case nil
	(outline-back-to-heading t)
      (error
       (beginning-of-buffer)))
    (outline-flag-region (1- (point))
			 (progn (outline-next-preface) (point)) nil)))





'(ad-disable-advice 'show-entry 'around 'before-heading)
'(defadvice show-entry (around before-heading activate)
  "capture the condition-case: before first heading"
  ;; (catch
  (condition-case nil
      ad-do-it
    (error
     (progn
       (message "error: show-entry failed")))))



;;; comments
;; For _years_ i wanted to modify outline-minor-mode, so that comments starting at the beginnin of line
;; were left visible.  Now i add the codition that they don't get marked as headers. Here's the code:
(defun outline-flag-region-make-overlay (from to) ;mmc
  (let ((o (make-overlay from to)))
    (overlay-put o 'invisible 'outline)
    (overlay-put o 'isearch-open-invisible
                 'outline-isearch-open-invisible)
    o))
;; ab

;;
(defun cheese-outline-hide (to)
  ""
  (let ((beginning (point))
	(regexp (concat "^" (regexp-quote comment-start))))
    (while (re-search-forward regexp to 't)
      (goto-char (match-beginning 0))
      (if (> (- (point) beginning) 2)
	  (outline-flag-region-make-overlay beginning
					    (- (point) 1)))
                                        ;(goto-char
      (end-of-line)
      (setq beginning (point)))
    ;; the final part:
    (outline-flag-region-make-overlay beginning to)))


(defun outline-flag-region (from to flag) ;mmc
  "Hides or shows lines from FROM to TO, according to FLAG.
If FLAG is nil then text is shown, while if FLAG is t the text is hidden."
  ;; mmc:
  (if (functionp 'remove-overlays)
      (remove-overlays from to 'invisible 'outline))
  (save-excursion
    (goto-char from)
    (end-of-line)
    ;;(if (functionp 'outline-discard-overlays)
    ;;	(outline-discard-overlays (point) to 'outline))
    (if flag
        ;; mmc: I want to leave the comments visible!
	;; very ugly code:
        (if comment-start
            (cheese-outline-hide to)
          ;; original:
          (let ((o (make-overlay (point) to)))
            (overlay-put o 'invisible 'outline)
            (overlay-put o 'isearch-open-invisible
                         'outline-isearch-open-invisible))))
    (run-hooks 'outline-view-change-hook)))




;; stop
(if running-xemacs
    nil ;; (global-set-key [(meta shift ? )] 'outline-commands)
  (global-set-key [(meta shift ? )] 'outline-commands)
  )



;; (setq magic-mode-alist ())
;; fixme: I need something to go `after' auto-mode-alist, when `text-mode' is on
(add-to-list 'magic-fallback-mode-alist
	     ;;magic-mode-alist
	     '(detect-outline . outline-mode))

;; magic-fallback-mode-alist
;; (setq magic-mode-alist ())
(defun detect-outline ()
  ""
  (and (eq major-mode 'text-mode)
       (save-excursion
	 (goto-char (point-min))
	 (search-forward-regexp "^\\*\\([^/]|*+\\)" 1000 t))))




(provide 'mmc-outline)
;;; my-outline.el ends here
