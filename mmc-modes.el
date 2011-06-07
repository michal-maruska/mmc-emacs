
;; mmc's customization of major modes   --- the tiny bits!


;;; TeX
(setq tex-default-mode 'latex-mode)
(setq-default TeX-mode t)
;(setq default-major-mode 'latex-mode)
(setq default-major-mode 'text-mode)

;; Commands
(setq tex-dvi-view-command "xdvi")
(setq tex-run-command "cst")
(setq tex-run-command "cstex")




;;  hooks
(add-hook 'Tex-mode-hook '(lambda() (auto-fill-mode 1)))
					; (setq Tex-mode-hook '(lambda() (abbrev-mode 1)))
(add-hook 'Tex-mode-hook 'turn-on-auto-fill)
(setq text-mode-hook
      '(lambda () (auto-fill-mode 1) (abbrev-mode 1) (setq fill-column 130)  ))




;;;  Major modes:
(autoload 'sawfish-mode "sawfish" "sawfish-mode" t)
(autoload 'python-mode "python-mode" "Mode for editing python programs." t)
;(require 'bison-mode)
(autoload 'bison-mode "bison-mode.el")
(autoload 'flex-mode "flex-mode")
(autoload 'css-mode "css-mode")
(autoload 'perl-mode "perl-mode")





;;;  Global MODE-HOOKS 
(setq c-tab-always-indent nil)
(unless (string-match "XEmacs" emacs-version)
  (global-font-lock-mode t)
  (auto-compression-mode t))

; [22 lug 03]
;(setq-default auto-fill-mode nil)
(setq-default outline-minor-mode t)

(add-hook 'emacs-lisp-mode-hook '(lambda() (eldoc-mode 1)))

(defun list-in-lines ()
  "Format a sequence of sexps by putting each one on a separate line"
  (interactive)
  (while 't
    (forward-sexp)
    (insert "\n")))



;; (string-match "/tmp/foto/doc/[^/]+/[^/]+/$"  "/tmp/foto/doc/6/6050/")

;;; DIRED:
;(setq dired-listing-switches "-al --ignore-backups")


;;; [16 dic 02]
(global-set-key [(control ?c) (control ?j)] 'goto-my-mode-definitions)


(defun mode-name (mode)
  "extract the name from the (major)-mode symbol `mode', e.g.  sql-mode -> sql"
  (let ((name (symbol-name mode)))
    (if (string-match "^\\(.*\\)-mode$" name)
        (match-string 1 name)
      name)))


(defun first-file-in-list (files)
  "return the first existing of the `files'"
  (list-search-positive
   (lambda (item)
     (file-if-exists item))
   files))

(defun goto-my-mode-definitions (&optional arg)
  (interactive "p")
  (let* ((dir "/linux/11/x/activity/emacs/")
         (mode major-mode)
         (mode (or (aget '((gnus-summary-mode . gnus-mode)) mode 't)
                   mode))
         (mode (mode-name mode))
         (file (first-file-in-list
                (list (file-name-in-directory dir (concat "my-" mode ".el"))
                      (file-name-in-directory dir (concat "my-" mode "-mode" ".el"))))))
    (if file
        (funcall (if arg
                     'find-file-other-window
                   'find-file) file)
      (message "no file found"))))



;; Makefile
(setq makefile-electric-keys 't
      tags-revert-without-query 't )

;; (modify-syntax-entry ?. "\w" makefile-mode-syntax-table)

;;; Shell:
(add-hook
    'sh-mode-hook
  (lambda ()
    (set
     (make-local-variable 'outline-regexp)
     ;;"\\(#*\\)"
     ;; "##+"
      "function"
      )))


(provide 'mmc-modes)

