;;; (c) 2001,2002   M. Maruska     licence:  GNU GPL v. 2


;; 2022:

(require 'mmc-simple)

;; So I can keep minibuffer active, but switch temporarily to other window.
(setq enable-recursive-minibuffers t)

;;; I want to `work' inside minibuffer.
;;  i.e.  invoke another minibuffer action (recurse)


;;;  This is a hack, b/c we _cannot_ invoke completing-read w/ a custom keymap
;; 2003-05-24:  but, we can read-from-minibuffer !!
;; read-file-name

(defmacro with-keymaps-switched* (keymap-symbol keymap-value &rest body)
  `(with-keymaps-switched
     ,keymap-symbol
     ,keymap-value
     (lambda ()
       ,@body)))

(defun with-keymaps-switched (keymap-symbol keymap-value func)
  "call FUNC, while switching the values of the KEYMAP-SYMBOLS to VALUE."
  (let ((original-map (symbol-value keymap-symbol)))
    (unwind-protect
        (progn
          (set keymap-symbol keymap-value)
          (apply func ()))
      ;; And guarantee, that things get back again.
      (set keymap-symbol original-map))))

(put 'with-keymaps-switched 'lisp-indent-function 'defun)


;; so I have >1 commands which call into 1 common emacs-core function which uses
;; 1 keymap.  I want the commands to modify/customize that keymap.
;; So I just redefine the keymap for the duration of the command.  Hmmm.

;;;   reading `filenames'
;; keymaps, which are used instead of the origianl ones:
(defconst mmc-minibuffer-local-filename-map (make-sparse-keymap)
  "my keymap used for reading `filenames'. Other keymaps inherit from it")

;; Inherit & set 1 binding:
(let ((map mmc-minibuffer-local-filename-map))
  (set-keymap-parent map
                     minibuffer-local-completion-map)
  (define-key map [(meta ?m)] 'minibuffer-reset))

;;; functions which get called from inside the minibuffer, while reading filename:
(when nil
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



  (defvar guess nil "my hack workaround")
  (defvar path nil "my hack workaround")
  (defvar path nil "my hack workaround")
  (defvar dir nil "my hack workaround")
  (defvar initial nil "my hack workaround")
  (defvar post-command nil "command to execute when leaving minibuffer?")
  (defvar def nil "my hack workaround")

  (defun get-filename-of-buffer ()
    "Called, when the current buffer is minibuffer, and while reading a filename.
We read a `buffer-name' and substitute in minibuffer its filename.
I would need  these `fluid' variables: `guess' `dir' `initial'   see: `' "
    (let* ((buffer (funcall read-buffer-function "filename of the Buffer: "))
           (path (my-buffer-file-name (get-buffer buffer))))
      (setq
       guess path                       ;ffap
       dir (file-name-directory path)	;standard
       initial (file-name-nondirectory path))))
  )

;;; TODO     bookmarks  syntax-table, but see `my-syntax.el'
;;; I want to NEST various read-*   to arrive at the filename

;; Activate the `mmc-minibuffer-local-filename-map' while reading
;; filenames.
;; And also allow executing commands afterwards.
(defadvice read-file-name (around my-read-file-name activate)
  ;; how to use a lexical-scope variable?
  (let ((my-continue-command 't)
        post-command
        filename)
    (while my-continue-command
      (setq my-continue-command nil)
      ;; (setq default (my-resolve-default table)
      ;; my-buffer-alist (buffer-name-list))
      (with-keymaps-switched*
       'minibuffer-local-completion-map
       mmc-minibuffer-local-filename-map

       (setq filename (progn
                        ;;prompt dir default-filename mustmatch initial))
                        ad-do-it)))
      ;; upon exit we can have some requested command to run:
      (setq continue-command t)
      '(if post-command
           (eval-command-or-form post-command)))
    filename))

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
 ;; I want to register in various keymaps,
 ;;  do they have a CommonGreatestDenomitor (ascendent)?
 (lambda (item)
   ;; (define-key item "\C-M-h" 'mb-backward-kill-sexp)
   (define-key item [(control meta ?h)] 'mb-backward-kill-sexp)
   (unless running-xemacs
     ;;(define-key item [(shift ? )] 'minibuffer-accept-default))
     (define-key item [(shift space)] 'minibuffer-accept-default)
     (define-key item [?,] 'self-insert-command)     ; minibuffer-insert-default
     (define-key item [(meta ?m)] 'minibuffer-reset) ;control
     ))
 ;; mmc: why not as symbols?
 (list-non-nil
  minibuffer-local-must-match-map
  (if running-xemacs
      '()
    minibuffer-local-ns-map)
  minibuffer-local-map
  minibuffer-local-completion-map
  ))

;; <SPC> is really an important key:
;; fixme: (unless (string-equal user-login-name "beta")
;; but beta does not like it (she prefers `insert-backslash')
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


;(current-local-map)
; (lookup-key minibuffer-local-map "C-p")
;(read-string "a")

;;; `FEATURE':  I want to see in `modeline' when I use the minibuffer recursively

;; And this turns off debug-on-error inside minibuffer:
;; todo: seems buggy!
(defvar debug-on-error-outside-minibuffer "")

(defun add-minibuffer-sign ()
  "add into modeline another tick"
  (auto-fill-mode -1)
  ;; dunno why it leaked there (auto-fill into the minibuffer)
  ;(if (not debug-on-error)
   ;   (message "hm, it's false"))
  (setq
   debug-on-error-outside-minibuffer debug-on-error)
  (setq debug-on-error t)
  (setq global-mode-string
        (cons "|" global-mode-string)))

(add-hook 'minibuffer-setup-hook 'add-minibuffer-sign)

(defun remove-minibuffer-sign ()
  "remove from modeline a tick about minibuffer recursion."
  (setq
   debug-on-error debug-on-error-outside-minibuffer)
  (if (member "|" global-mode-string)
      (setq global-mode-string (cdr global-mode-string))))

(add-hook 'minibuffer-exit-hook 'remove-minibuffer-sign)

(when nil
  ;; During development:

  ;; (setq minibuffer-setup-hook (cdr minibuffer-setup-hook))
  ;; minibuffer-exit-hook
  (setq global-mode-string
        (cons "|" global-mode-string))
  (setq global-mode-string (cdr global-mode-string))
  )

(provide 'mmc-minibuffer)
