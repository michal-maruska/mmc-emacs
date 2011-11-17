
(require 'eshell)
(require 'sh-script)
(defun find-which (command-name)
  "execute which (1) and visit the file"
  (interactive "sThe command name: ")
  (let (filename)
    (shell-command (format "which %s" command-name))
    (set-buffer "*Shell Command Output*")
    (setq filename  (buffer-substring (point-min) (- (point-max) 1)) )
    (find-file filename) ))



(defun publish (arg)
  ""
  (interactive "P")
  (let ((module ""))
    (if arg
	(setq module (file-name-nondirectory (buffer-file-name))))
    (shell-command
     ;;(format "export PATH=$PATH:/usr/local/sbin && publish %s &" module)
     (format "publish.scm %s &"   (if arg "" (read-string "host: "))))))



;;; grep ...
;; [28 nov 01] sawfish mail-list ... i add -u
(setq diff-switches "--unified -b -B"); was --context
;; -c context  -u unified

;;;   Shell/environement inside emacs:
(setenv "HISTFILE" "~/.zsh_history/emacs")

;; when under xdm
;(setenv "PGHOST" "linux10")
;; (setenv "PGHOST" "linux1")
;; (setenv "PATH" (concat (getenv "PATH") ":/bin:/usr/bin:/usr/X11R6/bin:/usr/ucb:/usr/local/bin/"))

(setenv "INSIDE_EMACS" (number-to-string (emacs-pid)))


(defadvice  sh-set-shell (before default-shell first nil activate)
  "offer DEFAULT value in interactive: `completing-read'
why did they forget it ?"
  (interactive
   (list
    ;; But in /etc/rc.d i would prefer /bin/sh
    (my-completing-read
     "Name or path of shell: "
     interpreter-mode-alist
     (lambda (x) (eq (cdr x) 'sh-mode))
     't
     ""
     nil; hist
     "bash")
    (eq executable-query 'function)
    t)))



(font-lock-add-keywords 'sh-mode
  '(("`\\(\\(\\s_\\|\\sw\\)+\\)'" 1 font-lock-important prepend)))


(defun shell-push ()
  ""
  (interactive)
  (let* ((name "*Async Shell Command*")
	(buffer (get-buffer name))
	(new-name (generate-new-buffer-name name)))
    (with-current-buffer buffer
      (rename-buffer new-name))))




;(setq sh-mode-hook '())
(add-hook 'sh-mode-hook
          (lambda ()
	    ;; make-variable-buffer-local
            (set (make-local-variable 'outline-regexp) "[^ 	]+\\(\\) ?{")))


; (modify-syntax-entry ?-  "_"  shell-mode-syntax-table)
; (getenv "INSIDE_EMACS")
; (setenv "INSIDE_EMACS" "1")

; (setenv "BROWSER" "elinks")



;; http://www.gentoo.org/doc/en/gentoo-howto.xml
(defun ebuild-mode ()
  (shell-script-mode)
  (sh-set-shell "bash")
  (make-local-variable 'tab-width)
  (setq tab-width 4))


(setq auto-mode-alist (cons '("\\.ebuild\\'" . ebuild-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.eclass\\'" . ebuild-mode) auto-mode-alist))


;(setq explicit-shell-file-name "su")
;(setq explicit-su-args (list "-l"))

(provide 'mmc-shell)
