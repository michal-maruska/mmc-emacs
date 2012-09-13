;;;  KEY-BINDINGs:

;; Base:
(defun under-x ()
  (or (eq window-system 'x)
      (eq window-system 'gtk)))


;; todo:
; M-?  ..
; M-
; c-z
; c-j-m ??
; M-s
; M-n/p
; M-o
;; C-x

(global-set-key "\M-#" 'comment-line)

;;; Key bindings
(global-unset-key "\C-x\C-c")
(global-unset-key [(control z)])

(global-set-key "\C-x\M-e" 'eval-buffer)
(global-set-key [(control ?x) ?E] 'eval-region)
;; in emacs-22 this is overwritten during some auto-load?

;; fixme: we have to overwrite what ffap does!
; (require  'ffap)
(eval-after-load "ffap"
  '(progn
     ;; (message "overriding ffap's C-x C-r binding")
     (ffap-bindings)				; do default key bindings
     (global-set-key "\C-x\C-r" 'revert-buffer)))

(global-set-key [(control ?-)] 'undo)

(global-set-key [menu] 'hippie-expand)
					;(global-set-key "\a-k" 'hippie-expand)
(global-set-key "\C-xH-k" 'hippie-expand)


(global-set-key [(control ?x) kp-0] 'delete-window)
(global-set-key [(control ?x) kp-1] 'delete-other-windows)
					;(global-set-key [kp-0] (lambda () (interactive) (insert ?0)))
					;(global-set-key [kp-1] (lambda () (interactive) (insert ?1)))
					;(global-set-key [kp-2] (lambda () (interactive) (insert ?2)))
					; (global-set-key [(hyper m)] 'insert-date)
					;(global-set-key [(mod2 m)] 'insert-date)
(global-set-key [(meta shift delete)] 'kill-line-save)
(global-set-key [(meta  ?K)] 'kill-line-save)
(global-set-key [(meta shift backspace)] 'kill-backward-line-save)

(unless running-xemacs
  (global-set-key [(meta ?,)] 'tags-loop-continue)) ;scan


;;;  4th row
;; terminal
(unless (under-x)
  (global-set-key "\M-[92~" 'goto-line)
  (global-set-key "\M-[99~" 'TeX-insert-braces)
  (global-set-key "\M-[98~" 'insert-parentheses)
  (global-set-key "\M-[97~" 'M-insert-brackets))

;; For X-Windows:
(when (under-x)
  (global-set-key [f32] 'goto-line)
  (global-set-key [f35] 'M-insert-braces) ; TeX
  (global-set-key [f34] 'insert-parentheses)
  (global-set-key [f33] 'M-insert-brackets)
  (global-set-key [f31] 'lg)

  (global-set-key "\C-^" 'M-insert-exponent)
  (global-set-key [(control kp-subtract)] 'M-insert-log))

;; in winter 2000/2001 i started to backspace as c-h in shell (bash).
;; i found it natural to use it in Emacs too...

(when (under-x)
  (keyboard-translate ?\C-h 'backspace)
)			;only this combination !!!

(when nil
  (keyboard-translate ?\C-,  ?*))
					; ?\H-SPC  ?*
					; '(hyper ? ) ?*			;only this combination !!!

					; (global-unset-key [(alt ? )] 'complete)

(global-set-key [(meta ?h)] 'backward-kill-word)
(global-set-key [(control meta ?h)] 'backward-kill-sexp)
;(global-set-key [(meta 'backspace)] 'backward-kill-sexp)

(global-set-key [(control meta ?K)] 'kill-sexp-save)

(when (under-x)
  (global-unset-key [(control ?,)]))

(unless running-xemacs
  (global-set-key [(shift ?\ )] 'hyperbole))



;;; DELETING & MOVING
;; terminal
(unless (under-x)
  (global-set-key "\C-h"  'delete-backward-char)

  (global-set-key "\M-[96~" 'kill-word)
  (global-set-key "\M-[95~" 'backward-kill-word)
  (global-set-key "\M-[94~" 'kill-line)
  (global-set-key "\M-[93~" 'backward-kill-sentence)
  (global-set-key "\M-[93~" 'backward-kill-line)
					;(global-set-key "\M-[90~" 'scroll-one-up)
  (global-set-key "\M-[89~" 'indent-region)
  (global-set-key "\M-[88~" 'beginning-of-buffer)
  (global-set-key "\M-[87~" 'end-of-buffer)

  (global-set-key "\M-[`1" 'scroll-one-up)
  (global-set-key "\M-[`0" 'scroll-one-down)

  (global-set-key "\M-[4~" 'end-of-line)
  (global-set-key "\M-[1~" 'beginning-of-line)
  (global-set-key "\M-[`3" 'forward-word)
  (global-set-key "\M-[`2" 'backward-word))



;; For X-Windows:
(when (under-x)
					;(global-set-key "\c-?" 'delete-char)
					;(global-set-key "\C--" 'undo)
					;(global-set-key "\c-$" 'undo)
					;(keyboard-translate ?\C-h ?\C-?)
					;(keyboard-translate ?\C-? ?\C-h)

					;(global-unset-key "\C-h")
					;(global-unset-key [backspace] )
  (global-set-key [(meta ??)] 'backward-kill-word)
  (global-set-key [(meta control ??)] 'backward-kill-sexp)
  (global-set-key [backspace]   'delete-backward-char)
  (global-set-key [(control backspace)] 'backward-kill-word)
  (global-set-key [(meta backspace)] 'backward-kill-line)
					;(global-unset-key [delete] )
  (global-set-key [delete]   'delete-char)
  (global-set-key [(control delete)] 'kill-word)
  (global-set-key [(meta delete)] 'kill-line)
  (global-set-key [(control tab)]    'indent-region)
					;(global-unset-key [home] )

  (global-set-key [home]    'beginning-of-line)
  (global-set-key [(control home)]  'beginning-of-buffer)
					;(global-unset-key [end] )
  (global-set-key [(meta control home)]  (lambda () (interactive)
					   (recenter 1 )))

  (global-set-key [(meta left)] 'backward-sexp)
  (global-set-key [(meta right)] 'forward-sexp)
					;    (global-set-key [C-M-left] 'backward-sexp)
					;    (global-set-key [C-M-right] 'forward-sexp)
  (global-set-key [(meta s)] 'mark-sexp)


    ;;; UP & DOWN
  (global-set-key [(control shift down)] 'forward-page)
  (global-set-key [(control shift up)] 'backward-page)


  (global-set-key [(alt ?n)] (lambda () (interactive) (scroll-up 1)))
  (global-set-key [(alt ?p)] '(lambda () (interactive) (scroll-up -1)))


  (global-set-key [mouse-5] '(lambda () (interactive) (scroll-up 2)))
  (global-set-key [mouse-4] '(lambda () (interactive) (scroll-up -2)))



  (global-set-key [end]    'end-of-line)
  (global-set-key [(control end)]  'end-of-buffer)
  (global-set-key [(control meta ?E)]  'end-of-buffer)
  (global-set-key [(control meta ?A)]  'beginning-of-buffer)
  (when nil
    (global-set-key [(control down)] (lambda () (interactive) (scroll-up 1)))
    (global-set-key [(control up)] '(lambda () (interactive) (scroll-up -1)))

    (global-set-key [(romaji)] (lambda () (interactive) (scroll-up 1)))
    (global-set-key [(hankaku)] (lambda () (interactive) (scroll-up -1)))
    )
  (global-set-key [(hankaku)] 'scroll-right)
  (global-set-key [(romaji)] 'scroll-left)
  ;; (global-set-key [(control next)] (lambda () (interactive) (scroll-up 1)))
  ;; (global-set-key [(control prior)] (lambda () (interactive) (scroll-up -1)))
  )


					; (global-set-key [(control ?,)] 'delete-backward-char)
;;; Function Keys:
(unless (under-x)
  ;; terminal
  (global-set-key "[17~" 'font-lock-mod)
  (global-set-key "[18~" 'emacs-lisp-mode)
  (global-set-key "[19~" 'text-mode)
  (global-set-key "[20~" 'c++-mode)
  (global-set-key "[23~" 'latex-mode)
  (global-set-key "[24~" 'plain-tex-mode))



(when (under-x)
  (global-set-key [f6] 'font-lock-mode)
  (global-set-key [f7] 'toggle-debug-on-error)
  ;; 16 Jun 01:   too risky:
  ;;(global-set-key [f7] 'emacs-lisp-mode)
  ;; (global-set-key [f8] 'text-mode)
  ;; (global-set-key [f9] 'c++-mode)
  (global-set-key [f10] 'view-mode)
  ;; (global-set-key [f11] 'latex-mode)
  ;;(global-set-key [f12] 'plain-tex-mode)
  )


(define-key ctl-x-4-map "v" 'view-file-other-window) ; ^x4v
(define-key ctl-x-5-map "v" 'view-file-other-frame) ; ^x5v


;;
;;; Misc
;; terminal
(unless (under-x)
  (global-set-key "\M-[91~" 'unexpand-abbrev)
  (global-set-key "[P" 'eval-last-sexp)

  (global-set-key "\M-[51" 'over)
  (global-set-key "\M-[52" 'underbar)
  (global-set-key "\M-[53" 'paragraf)
  (global-set-key "\M- " 'unexpand-abbrev)
  )


;;; Unbind `C-x f'
(global-unset-key "\C-xf")

(when (under-x)
  ;; language environment
  (global-set-key [f2] 'russo)
  (global-set-key [f3] 'cesky)
  (global-set-key [f4] 'quail-toggle)
  (unless running-xemacs
    (set-keyboard-coding-system 'iso-latin-2))
  (global-set-key [(control ?x) (control ?m) ?m] 'toggle-enable-multibyte-characters))


;; What would change if mascro (I mean when in minibuffer ..?)
(defun insert-slash ()
  (interactive)
  (insert-char ?/ 1))


(defun insert-backslash ()
  ""
  (interactive)
  (insert "\\"))


;(global-set-key [(hyper ? )] 'insert-backslash)
(global-set-key [(meta space)] 'insert-slash)
(global-set-key [(meta ? )] 'insert-slash)
(global-set-key [(meta menu)] 'just-one-space)

(global-set-key [(meta f35)] 'hippie-expand)




;;; ALIAS !!!
;; Here I had highlight-current-line. now obsoleted by

(when (eq window-system 'x)
  (global-set-key [(control ?h) ?W] 'find-function))



;; I want letters-> buffers

(defvar my-global-buffer-keymap
  (let ((map (make-sparse-keymap)))
    (define-key map [?k] 'kill-buffers-with-minor-mode)
    (define-key map [?b] 'switch-to-buffer)
    map))



;; This does not define when loading it byte-compiled.
;;(eval-and-compile
;;  (defconst my-global-keymap (make-sparse-keymap) ""))
;; fixme: If I eval this-buffer, I will lose what is bound
;; in other files, say mmc-ring.el !
;;(eval-and-compile
;;  (defconst my-global-keymap (make-sparse-keymap) ""))


;; (defconst my-global-keymap (make-sparse-keymap) "")
;;(defvar my-distinct-input-methods-map (make-sparse-keymap) "")

(defvar my-global-keymap
  (let ((map (make-sparse-keymap)))	; my-global-keymap
    (define-key map [?b] my-global-buffer-keymap)
    (define-key map [?c] 'rename-buffer) ;adviced !
    ;;(define-key map [?d] 'calibrate-current-directory)

    ;; see my-desktop.el##my-desktop-keymap

    (define-key map [?f] 'set-fill-column)
    (define-key map [?m] 'my-display-messages)

    (define-key map [?0] 'quit-window)
    (define-key map [?n] 'rename-uniquely)
    (define-key map [?#] 'comment-region)
    (define-key map [?r] 'toggle-read-only)
    (define-key map [?h] 'highlight-current-line-toggle)
    (define-key map [?s] 'hscroll-mode)
    (define-key map [?S] 'screen-lines-mode)
    (define-key map [?\\] 'set-my-distinct-input-methods-map)
    (define-key map [?+] 'make-directory)
    (define-key map [?i] 'imenu)
    (define-key map [?j] 'list-jobs)

    (define-key map [?/] 'set-default-directory)
    (define-key map [(meta ? )] 'set-default-directory)

    (define-key map [?.] 'normal-mode)
    (define-key map [?v] 'switch-to-alternate-buffer)
    (define-key map [(control ?v)] 'switch-to-alternate-buffer)

    ;; Finally:
    (global-set-key [(control ?X) ] map)
    map))

(define-key ctl-x-map [?x ] my-global-keymap)
(define-key my-global-keymap [?u] 'my-bury-buffer)

(autoload 'my-bury-buffer "mmc-ring")


(defconst my-distinct-input-methods-alist
  '(
    (?r . cyrillic-jcuken)
    (?c . czech)
    (?i . latin-1-postfix)
    ;;(?i  italian-keyboard)
    )
  "")

(defun set-my-distinct-input-methods-map (key)
  ""
  (interactive
   (list
    (read-char "char:(c  czech    j/r  jcuken   i) ")))
  (let* ((method (aget my-distinct-input-methods-alist key)))
    (if method
	(set-input-method method))))

(global-set-key [(control meta ?1)] (lambda () (interactive) (set-my-distinct-input-methods-map ?r)))
(global-set-key [(control meta ?2)] (lambda () (interactive) (set-my-distinct-input-methods-map ?c)))
(global-set-key [(control meta ?3)] (lambda () (interactive) (set-my-distinct-input-methods-map ?i)))


;; Should be set only when defined !!!    yes hyperbole-buttons ...
;(global-set-key [f5] 'imenu)
(global-set-key [(control ?x) ?5 ?l] 'make-frame-on-display)
; (global-set-key [(control ?x) ?b] 'my-switch-to-buffer-find-file)
(global-set-key [(control ?x) ?a ?c] 'add-change-log-entry)
;(global-set-key [(hyper ?j)] 'join-line)




;;; Alt
(global-set-key [(alt return)] 'compile)
(global-set-key [(alt control ?m)] 'compile)
;(global-set-key [(control ?x) ?r (control ? )] 'register-to-point)
(global-set-key [(alt ?1)]
		(lambda ()
		  (interactive  )
		  (select-palette 5)))


;; (global-unset-key [(control ?1)]) 'select-palette)
(global-set-key [(meta ?g) ] 'goto-line)
(global-set-key [(meta control ?7) ] 'keyboard-escape-quit)
(global-set-key [(control meta ?8)] 'repeat-complex-command)
;; (global-set-key [(control meta ?9)] 'repeat-complex-command)

;; Overriding implementation from simple.el? fixme!
;; I need to remove additional space AFTER this one:
(defun fixup-whitespace ()
  "Fixup white space between objects around point.
Leave one space or none, according to the context."
  (interactive "*")
  (save-excursion
    (delete-horizontal-space)
    (if (or (looking-at "^\\|\\s)")
	    (looking-at "\n")	    ;; mmc: ADDING this:
	    (save-excursion (forward-char -1)
			    (looking-at "$\\|\\s(\\|\\s'")))
	nil
      (insert ?\s))))

(global-set-key [(control ?>)] 'fixup-whitespace)

;; (lookup-key global-map [f1] )




(defun minibuffer-accept-default-value ()
  (interactive)
  (erase-buffer)
  (call-interactively 'exit-minibuffer))

(mapc
 (lambda (map)
   (define-key map [(shift space)]
     (if running-xemacs
	 'minibuffer-accept-default
       'minibuffer-accept-default-value)))
 (list minibuffer-local-completion-map minibuffer-local-must-match-map))



;; (define-key map [(shift ? )] 'minibuffer-accept-default-value))


;;  (global-set-key [(meta ?+ )] 'find-use-of-symbol)
(global-set-key [(meta ?+ )] 'grep)


(global-set-key [(control x) (?<)] 'scroll-right)
(global-set-key [(control x) (?>)] 'scroll-left)
(global-set-key [(control x) (meta ?>)] 'scroll-other-window)
(global-set-key [(control x) (meta ?<)] 'scroll-other-window-down)



;;; insert-keymap
(defvar insert-keymap (make-sparse-keymap)
  "")
(define-key ctl-x-map [?+] insert-keymap)

(global-set-key [(control ?x) (meta ?f)] 'ffap-next)

(defun switch-keys (keymap key1 key2)
  "in the given KEYMAP, switch the functions of 2 KEYS"
  (let ((function1 (lookup-key keymap key1))
        (function2 (lookup-key keymap key2)))
    (define-key keymap key1 function2)
    (define-key keymap key2 function1)))

;;; 2x Jun 01:  i got sick-bored of tabbing (indenting):  hope not to become of c-h (backspace)
(switch-keys global-map "
" [(control ?j)])


(define-key text-mode-map "
" 'newline)




;(global-set-key [(control meta ?f)] 'forward-sexp)
;(global-set-key [(control meta ?g)] 'backward-sexp)

;;(eval-when-compile
(if running-xemacs
    ;;(defalias 'lisp-mode-shared-map 'shared-lisp-mode-map)
    (setq lisp-mode-shared-map shared-lisp-mode-map)
  )
;;)

;;; testing SEXPs vs WORDS
;(unless running-xemacs
(progn
  ;;
  (define-key lisp-mode-shared-map [(meta ?f)] 'forward-sexp)
  (define-key lisp-mode-shared-map [(meta control ?f)] 'forward-word)

  (define-key lisp-mode-shared-map [(meta ?b)] 'backward-sexp)
  (define-key lisp-mode-shared-map [(meta control ?b)] 'backward-word)

  ;;(set-keymap-parent emacs-lisp-mode-map lisp-mode-shared-map)

;  (switch-keys lisp-mode-shared-map [(meta ?f)] [(control meta ?f)])
;  (switch-keys lisp-mode-shared-map [(meta ?b)] [(control meta ?b)])

  (switch-keys global-map [(meta ?k)] [(control meta ?k)])
                                        ;lisp-mode-shared-map
; (switch-keys lisp-mode-shared-map [(meta ?d)] [(control meta ?d)])

  ;; fixme: why global ?
  (switch-keys global-map [(meta ?t)] [(control meta ?t)])

  (switch-keys global-map [(meta ?h)] [(control meta ?h)])
                                        ; lisp-mode-shared-map
  )
;; upon each change !!
(eval-after-load "list-mode"
  '(set-keymap-parent emacs-lisp-mode-map lisp-mode-shared-map))
;)



(global-set-key [(alt ?a)]  'sql-postgres)
(global-set-key [(control ?@)]  'mark-defun)



(when nil
  ;; fixme:  cannot byte-compile
  (let ((map my-global-keymap))
    (define-key map "p"
      (lambda ()
	(interactive)
	(switch-to-buffer-other-window "*psql*"))))
  )

;; fixme:
;; (define-key ctl-x-map "f" 'set-fill-column)

;;; fighting bad keyboards:
(global-set-key [(control meta ?y)] 'beginning-of-defun)

(global-set-key [(control ?x) (meta ?b)] 'switch-to-buffer-other-window)



;;; Got from IRC
(defun run-command-other-frame (command)
  "Run COMMAND in a new frame."
  (interactive "CC-x 5 M-x ")
  (select-frame (make-frame))
  (call-interactively command))

(global-set-key "\C-x5\M-x" 'run-command-other-frame)





(require 'mmc-narrow)
(global-set-key [(control ?N)] ctl-x-n-map)



(unless (under-x)
  (global-set-key "\C-@" 'set-mark-command))

(unless (under-x)
  (global-set-key [(control ?\})] 'other-window))


; (keyboard-translate ?\C-x nil)
; (keyboard-translate ?\C-; ?\C-x)
; keyboard-translate-table




;; new
;; This inhibits  "Return" key!
;; (define-key global-map [(control ?j)]  ctl-x-map) ; ^x5v
(define-key global-map [(control ?m)] 'newline-and-indent)


;;; emacs-24 `yanking:'
(setq mouse-yank-at-point t)

(defun yank-primary (arg)
  "yank, from the X `primary' selection."
  ;; prefix -> stay at the
  (interactive "P")
  (push-mark (point))
  (if arg
      (save-excursion
	(mouse-yank-primary t))
    (mouse-yank-primary t)))

(global-set-key [(control ?c) (control ?y)] 'yank-primary)

;;; end
(provide 'mmc-keys)
