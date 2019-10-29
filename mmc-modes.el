;;; mmc's customization of major modes   --- the tiny bits!


;;; Detecting major mode
;; see mmc-outline.el
(add-to-list 'magic-fallback-mode-alist
	     ;;magic-mode-alist
	     '(detect-makefile . makefile-mode)
	     '(detect-makefile . makefile-mode))

(defun detect-makefile ()
  (or
   (string-match "\.mk\." (buffer-file-name))
   (string-match "makefile" (buffer-file-name))))



;;; TeX
(setq tex-default-mode 'latex-mode)
(setq-default TeX-mode t)
;(setq default-major-mode 'latex-mode)
(setq-default major-mode 'text-mode)

;; Commands
(setq tex-dvi-view-command "xdvi")
(setq tex-run-command "cst")
(setq tex-run-command "cstex")




;;  hooks
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

(add-to-list 'auto-mode-alist
	     '("\\.qml$" . java-mode))

(add-to-list 'auto-mode-alist
	     '("\\.pro$" . makefile-mode))
; auto-mode-alist
(add-to-list 'auto-mode-alist
	     '("\\.adb$" . sh-mode))
(add-to-list 'auto-mode-alist
	     '("\\.sls$" . scheme-mode))


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




;;; Major modes for which I have little code & thus no separate mmc-MODE.el file
;;  have the relevent code here:
;; Makefile
(setq makefile-electric-keys 't
      tags-revert-without-query 't )

;; (modify-syntax-entry ?. "\w" makefile-mode-syntax-table)


(add-to-list 'auto-mode-alist '("\\.adb$" . sh-mode))
(add-to-list 'auto-mode-alist '("\\.qml$" . java-mode))
(add-to-list 'auto-mode-alist '("\\.pro$" . makefile-mode))
(add-to-list 'auto-mode-alist
             `(,(expand-file-name "~/tests/bash/")
               . sh-mode))
;;
(add-to-list 'auto-mode-alist '("\\.sls$" . scheme-mode))

(add-to-list 'auto-mode-alist '("\\.expect$" . tcl-mode))

;; Android
;; auto-mode-alist
(add-to-list 'auto-mode-alist
             '("buildspec\\.mk\\.default" . makefile-gmake-mode))
(add-to-list 'auto-mode-alist
             '("AndroidManifest\\.xml" . nxml-mode))

(add-to-list 'auto-mode-alist '("\\.xml$" . nxml-mode))

(add-to-list 'auto-mode-alist '("\\.xsd$" . nxml-mode))


;;  tomtom:
(add-to-list 'auto-mode-alist '("\\.ttbld$" . sh-mode))
(add-to-list 'auto-mode-alist '("\\.cmpnt$" . sh-mode))
(add-to-list 'auto-mode-alist '("build.inc" . sh-mode))
(add-to-list 'auto-mode-alist '("zsh/" . sh-mode))
(add-to-list 'auto-mode-alist '("bin/" . sh-mode))
(add-to-list 'auto-mode-alist '(".*\\.env" . sh-mode))
;; Google build systems:
(add-to-list 'auto-mode-alist '(".*\\.gn" . sh-mode))
(add-to-list 'auto-mode-alist '(".*\\.ninja" . ninja-mode))
(add-to-list 'auto-mode-alist '(".*\\.service" . sh-mode))
(add-to-list 'auto-mode-alist '(".*\\.rid" . c++-mode))

(add-to-list 'auto-mode-alist '("\\.yml$" . yaml-mode))
(add-to-list 'auto-mode-alist '("\\.jam$" . c++-mode))
(add-to-list 'auto-mode-alist '(".*\\.gradle" . groovy-mode))


(provide 'mmc-modes)
