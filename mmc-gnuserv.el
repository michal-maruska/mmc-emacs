
;;; Note: this used to be in `my'  patched  gnuserv package.
;;; Now experimenting w/ stock gnuserv, and therefore
;;; including this file in `mmc-emacs' package!


;;; i had to:
;; * change the ./confgure flags (in ebuild) to *disable* unix-domain sockets
;; (which take precedence)..  autothority ? i have a file

;; Emacs CVS has problems w/o this. fixme!
;;(defun define-obsolete-variable-alias (&rest rest)
;;  ""
;;  t)


(defvar gnuserv-authority-file "~/.gnuserv.trust" "")

(defvar gnuserv-port
  (+ 21490 (user-uid)
     (if running-xemacs 1000 0)
     1)
  "run gnuserv w/ this port.
 I run both emacs/xemacs and want to contact them both.")



(when t	            ; nil ... in emacs-22 I need this, since gnuserv-compat define
					; `temp-directory' !
  (unless running-xemacs
                                        ;(unless emacs-22
    (require 'gnuserv-compat)
    ;;"/usr/share/emacs/site-lisp/gnuserv/gnuserv-compat.el"
    ;; emacs-22 needs source !
    (require 'gnuserv )
    ;;"/usr/share/emacs/site-lisp/gnuserv/gnuserv.el"
    ))

;;; I don't run gnuserv in some cases?
(autoload 'gnuserv-start "gnuserv")
;;(getenv "GNU_PORT")

;(start-process "server" nil server-program)

(defvar gnuserv-session nil
  "number of session, used by gnuserv, to add to the default port.")



(require 'mmc-frame)

(defun update-frame-title ()
  (setq frame-title-format
        (list
         (concat (if running-xemacs
                     "xemacs "
                   "emacs ") (number-to-string (emacs-pid))
                   (if gnuserv-session
                       (concat " " (number-to-string gnuserv-session) " ")
                     " ")
                   (user-login-name) "@" (hostname) " %S: %j ")
         '(buffer-file-name "%f" (dired-directory dired-directory "%b")))))


(update-frame-title)
(setq icon-title-format frame-title-format)

;(setq gnuserv-session 3)
(defun my-gnuserv-start (session)      ;&optional
  "run gnuserv w/ this port.
I run both emacs/xemacs and want to contact them both."
  (interactive "nsession: \n")
  (unless session
    (setq session 0))

  (setq gnuserv-session session)
  (update-frame-title)
  (setq gnuserv-port
        (+ 21490 (user-uid)
           (if running-xemacs 1000 0)
           session
           ))

  ;(setq default-frame-alist
  (aput 'default-frame-alist
        'background-color
        ;; "black"
        ;"gray7"
        ;)
        (nth session
             '("black" "gray10")))      ;   `'gray3  during night

  (setenv "GNU_PORT" (int-to-string   gnuserv-port))
  (setenv "GNU_SECURE" (expand-file-name gnuserv-authority-file))
  (gnuserv-start))

(require 'mmc-cli-options)

;; register this at init time:

(add-hook
     'after-init-hook
   (lambda ()
     (run-wo-fail (my-gnuserv-start (if mmc-nodesktop 1 0)))
     ))

(provide 'mmc-gnuserv)
