;;; (c) 2001,2002   M. Maruska     licence:  GNU GPL v. 2

;; xemacs todo:
;; M-m   ~/
;; space complete (not word)


;; http://ruska.dyndns.org/comp/emacs/local/my-minibuffer.el

;;; emacs 21 introduced new behaviour in minibuffer:

(setq enable-recursive-minibuffers 't)

; http://ruska.dyndns.org/comp/emacs/local/mdb



;;; i want to `work' inside minibuffer.
;;  i.e.  invoke another minibuffer action (recurse)


;;;  This is a hack, b/c we _cannot_ invooke completing-read w/ a custom keymap
;; 2003-05-24:  but, we can read-from-minibuffer !!

(defmacro with-keymaps-switched (old new &rest body) ; not hygienic !!!
  "eval BODY with OLD and NEW keymaps switched (given as symbols). Restore the original keymaps upon
either local exit from BODY, or the successful termination."
  (let ((old-map (make-symbol "old-map")))
    `(let ((,old-map ,old))
       (unwind-protect
	   (progn
	     (setq ,old ,new)		;(set old ,new)
	     ,@body)
	 ;; And guarantee, that things get back again.
	 (setq ,old ,old-map)))))

(put 'with-keymaps-switched 'lisp-indent-function 2)



;;;   reading `filenames'
;; keymaps, which are used instead of the origianl ones:
(defconst mmc-minibuffer-local-filename-map (make-sparse-keymap)
  "my keymap used for reading filenames: we inherit from")


;;;
(let ((map mmc-minibuffer-local-filename-map))
  (set-keymap-parent map
		     minibuffer-local-completion-map)
  (define-key map [(meta ?m)]
    'minibuffer-reset
    ;'exit-and-get-filename-of-buffer
    )
  )

;;; functions which get called from inside the minibuffer, while reading filename:
(when nil
  (defun exit-and-get-filename-of-buffer ()
    "Called form mb, while reading filename"
    (interactive)
    ;; fixme:  exit-reading-buffer is gone since 23 ?
    (exit-reading-buffer 'get-filename-of-buffer nil))
  )

;; extension to `buffer-file-name'
;; see `directory-of-buffer'(my-dired)
(defun my-buffer-file-name (buffer)
  "This should return a/the file/dir associated with the BUFFER."
  (with-current-buffer buffer ;;save-excursion
    (if (eq major-mode 'dired-mode)
	dired-directory
      buffer-file-name)))


(defvar guess)
(defvar path)
(defvar path)
(defvar dir)
(defvar initial)
(defvar post-command)
(defvar def)
(defun get-filename-of-buffer ()
  "Called form mb, while reading filename.  We read a _buffer-name_ and substitute in minibuffer its filename
I would need  these `fluid' variables: `guess' `dir' `initial'   see: `' "
  (let* ((buffer (funcall read-buffer-function "filename of the Buffer: "))
	 (path (my-buffer-file-name (get-buffer buffer))))
    (setq
     guess path				;ffap 
     dir (file-name-directory path)	;standard
     initial (file-name-nondirectory path))))


(when nil
   (ad-deactivate 'scroll-up)
   (ad-define-subr-args 'scroll-up '(&optional arg))
   ;;(lookup-key minibuffer-local-map "\M-m")
   )


;;;  TODO     bookmarks  syntax-table, but see `my-syntax.el'
;;; i want to NEST various read-*   to arrive at the filename
(defadvice read-file-name (around my-read-file-name activate)
  (let ((my-continue-command 't)
        post-command
        filename)
    (while my-continue-command
      (setq my-continue-command nil)
      ;; (setq default (my-resolve-default table)
      ;; my-buffer-alist (buffer-name-list))
      (with-keymaps-switched minibuffer-local-completion-map mmc-minibuffer-local-filename-map
        ;;minibuffer-local-completion-map
        (setq filename
              (progn
                ad-do-it ;;prompt dir default-filename mustmatch initial))
                ))
        ;; upon exit we can have some requested command to run:
        (if post-command
            (eval-command-or-form post-command)) ; (eval (bury-buffer))
        ))
    filename))


;; useless
'(defun my-read-file-name (prompt &optional dir default-filename mustmatch initial)
  ""
  (let (continue-command)
    (while (null continue-command)
      ;; (setq default (my-resolve-default table)
      ;; my-buffer-alist (buffer-name-list))
      (with-keymaps-switched minibuffer-local-completion-map mmc-minibuffer-local-filename-map
	;;minibuffer-local-completion-map
	(read-file-name prompt dir default-filename mustmatch initial))
      ;; upon exit we can have some requested command to run:
      (if post-command
	  (eval-command-or-form post-command)) ; (eval (bury-buffer))
      )))


;minibuffer-local-completion-map

;;; FIXME:   should be updated !
;; redefine:  why ??
(eval-after-load "ffap"
  (lambda ()
    (defun ffap-read-file-or-url (prompt guess)
      "Read file or url from minibuffer, with PROMPT and initial GUESS."
      (or guess (setq guess default-directory))
      (let (dir)
	;; Tricky: guess may have or be a local directory, like "w3/w3.elc"
	;; or "w3/" or "../el/ffap.el" or "../../../"
	;; ------------
	(let ((minibuffer-completing-file-name t))
	  (let (continue-command)
	    (while (null continue-command)

	      (or (ffap-url-p guess)
		  (progn
		    (or (ffap-file-remote-p guess)
			(setq guess
			      (abbreviate-file-name (expand-file-name guess))
			      ))
		    (setq dir (file-name-directory guess))))
	      ;; (setq default (my-resolve-default table)
	      ;; my-buffer-alist (buffer-name-list))
	      (with-keymaps-switched minibuffer-local-completion-map mmc-minibuffer-local-filename-map
		;;minibuffer-local-completion-map
					;(read-file-name prompt dir default-filename mustmatch initial))
		(setq guess
		      (completing-read
		       prompt
		       'ffap-read-file-or-url-internal
		       dir
		       nil
		       (if dir (cons guess (length dir)) guess)
		       (list 'file-name-history)))
		;; upon exit we can have some requested command to run:
		(if post-command
		    (eval-command-or-form post-command)) ; (eval (bury-buffer))
		))))
	;; ------------
	;; Do file substitution like (interactive "F"), suggested by MCOOK.
	(or (ffap-url-p guess) (setq guess (substitute-in-file-name guess)))
	;; Should not do it on url's, where $ is a common (VMS?) character.
	;; Note: upcoming url.el package ought to handle this automatically.
	guess))))




;(lookup-key my-minibuffer-local-completion-map "\M-m")

;; (read-file-name "filename: ")
;; in e 21, the minibuffer concept changed: to keep using 
(defun mb-backward-kill-sexp ()
  ""
  (interactive)
  ;; active-minibuffer-window
  (save-restriction
    (narrow-to-region
     (minibuffer-prompt-end)
     (point-max))
    (backward-kill-sexp)))


;; (lookup-key minibuffer-local-must-match-map [(control meta ?h)])
;; "C-M-h")

(defun minibuffer-accept-default ()
  "after some confused editing you decide to accept the (offered) default:"
  (interactive)
  (delete-minibuffer-contents)
  (exit-minibuffer))

(defun minibuffer-insert-default ()
  "after some confused editing you decide to accept the default:"
  (interactive)
  (delete-minibuffer-contents)
  (insert (prin1-to-string def))); default-value

(when running-xemacs
  (defalias 'delete-minibuffer-contents 'erase-buffer))

(defun minibuffer-reset ()
  ""
  (interactive)
  ;; i would like to take the DEF ..
  ;(backtrace)
  ;(erase-buffer)
  (if running-xemacs
      (erase-buffer)
    (delete-minibuffer-contents))
  (insert "~/"))




;;; some keys to the mb keymaps
(mapc
 ;; i want to register in various keymaps, do they have a CommonGreatestDenomitor (ascendent)?
 (lambda (item)
   ;; (define-key item "\C-M-h" 'mb-backward-kill-sexp)
   (define-key item [(control meta ?h)] 'mb-backward-kill-sexp)
   (unless running-xemacs
     ;;(define-key item [(shift ? )] 'minibuffer-accept-default))
     (define-key item [(shift space)] 'minibuffer-accept-default)
     (define-key item [?,] 'self-insert-command) ; minibuffer-insert-default
     (define-key item [(meta ?m)] 'minibuffer-reset) ;control
     ))
 (list-non-nil
  minibuffer-local-must-match-map
  (if running-xemacs
      '()
    minibuffer-local-ns-map)
  minibuffer-local-map
  minibuffer-local-completion-map
  ))


;; <SPC> is really an important key:
;; fixme: (unless (string-equal user-login-name "beta")	; but beta does not like it (she prefers `insert-backslash')
(mapc
 (lambda (item)
   (define-key item [(meta ? )] 'minibuffer-complete-word)
   (define-key item [(?\ )] 'minibuffer-complete))
 (list
  minibuffer-local-must-match-map
  minibuffer-local-completion-map
  ;; 2010-05-15
  minibuffer-local-filename-completion-map
  ))
 



;;; read numbers:
;; todo: match-string .. replace-match ..
(defun read-number-increment (&optional arg)
  (interactive)
  (or arg (setq arg 1))
  (let ((string (minibuffer-contents)))
    (delete-minibuffer-contents)
    (insert (int-to-string (+ (string-to-number string) arg)))))

(defun read-number-decrement (&optional arg)
  (interactive)
  (or arg (setq arg 1))
  (read-number-increment (- arg)))




(defconst read-number-map (make-sparse-keymap) "")
(let ((map read-number-map)
      )
  (set-keymap-parent map minibuffer-local-map)
  
  (define-key map [(control ?<)] 'read-number-decrement) ;"C-n"
  (define-key map [(control ?>)] 'read-number-increment)

  (define-key map "<" 'read-number-decrement) ;"C-n"
  (define-key map ">" 'read-number-increment)
  ;;(define-key map [(control ?n)] 'read-number-decrement) ;"C-n"
					;(define-key map [(control ?p)] 'read-number-increment) ;"C-n"
					;(define-key map "C-p" 'read-number-decrement)
  )

(defun read-number (prompt &optional init def history)
  ""
  (with-keymaps-switched minibuffer-local-map read-number-map
    (string-to-number
     (read-string (format "%s (%s) " prompt def)
		 (if (numberp init) (int-to-string init) init)
		 history def))))


;(current-local-map)
; (lookup-key minibuffer-local-map "C-p")
;(read-string "a")
;(read-number "group:" 1 1 nil)





(defvar debug-on-error-outside-minibuffer "")
;;; i want a visual feedback:
(defun add-minibuffer-sign ()
  ""
  (auto-fill-mode -1)                  ; dunno why it leaked there (auto-fill into the minibuffer)
  (setq
    ;fill-column (screen-width)
   debug-on-error-outside-minibuffer debug-on-error
   debug-on-error nil)
  (setq global-mode-string
		  (cons "|" global-mode-string)))
;(setq minibuffer-setup-hook (cdr minibuffer-setup-hook))
(add-hook 'minibuffer-setup-hook 'add-minibuffer-sign)

(defun remove-minibuffer-sign ()
  ""
  (setq
   debug-on-error debug-on-error-outside-minibuffer)
  (if (member "|" global-mode-string)
      (setq global-mode-string (cdr global-mode-string))))


(add-hook 'minibuffer-exit-hook 'remove-minibuffer-sign)
;minibuffer-exit-hook

(when nil
  (setq global-mode-string
	(cons "|" global-mode-string))
  (setq global-mode-string (cdr global-mode-string))
  )


(provide 'mmc-minibuffer)
