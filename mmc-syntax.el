
;; Featurs:

;; o   When deleting dir-names   /.../  i want to be able to delete entire dirname (beside words)
;;     so  ../my_documents/@   (@ point)  i can back-delete the word and all the dirname.




;; 13 Jun 01   I start studying the syntax tables/indentation...

; (syntax-table-p  (standard-syntax-table))
; text-mode-syntax-table

'(with-syntax-table (standard-syntax-table)
  (let* ((char ?\ )
         (code (char-syntax char)))
    (message "%c -> %s (%c)" char (aget syntax-alist code) code)))



;(with-syntax-table text-mode-syntax-table
;  (char-syntax ?\ ))


;;; Read syntax:
;; the same as in mmc-simple.el
(defvar syntax-history (make-symbol "syntax-history") "") ;;
(set syntax-history ())
(defvar syntax-ring (make-ring 10) "")

(defun read-syntax-table (&optional prompt def)
  ""
  (intern-soft
   (my-completing-read
    (or prompt "syntax table: ")
    (symbols-matching-re "^\\(.*-syntax-table\\)$")
    nil nil "" syntax-history def nil display-ring
    )))
;		          sawfish-mode-syntax-table


(require 'assoc)

;;; Help
(defun syntax-code (char prefix)
  "report the syntax code (verbally) of the CHAR, if PREFIX ask for syntax table."
  (interactive (list (char-after)
		     current-prefix-arg))
  (let ((syntax-table (if prefix
			  (symbol-value (read-syntax-table "syntax table? "))
			(syntax-table))))
    (with-syntax-table syntax-table
      (let ((code (char-syntax char)))
	(message "%c -> %s (%c)" char (aget syntax-alist code) code)))))

(defconst syntax-alist
  '(
    (?\ . "whitespace")
    (?-  . "whitespace")
    (?w . "word")
    (?_ . "symbol")
    (?. . "punctuation")
    (?\( . "open parenthesis")
    (?\) . "close parenthesis")
    (?\" . "string quote")
    (?\\ . "escape")
    (?/ . "quote")
    (?$ . "paired delimiter")
    (?' . "expression"))
  "")

;(with-syntax-table message-mode-syntax-table (char-syntax ?.))
(eval-after-load
    "message"
  '(with-syntax-table message-mode-syntax-table
     (let* ((char ?.)
	    (code (char-syntax char))
	    )
       (message "%c -> %s (%c)" char (aget syntax-alist code) code))))


;(syntax-code ?-)
(require 'mmc-help)
(define-key help-map "S" 'syntax-code)


;(with-syntax-table text-mode-syntax-table
(modify-syntax-entry ?\   " " ;fundamental-mode)
		     text-mode-syntax-table)


(modify-syntax-entry ?   " " ;fundamental-mode
		     c-mode-syntax-table)

(eval-after-load "m4-mode"
  '(modify-syntax-entry ?   " " ;fundamental-mode
		     m4-mode-syntax-table))

(eval-after-load "autoconf-mode"
  '(modify-syntax-entry ?   " "
		     autoconf-mode-syntax-table))

(eval-after-load "make-mode"
  '(progn
    (modify-syntax-entry ?   " " ;fundamental-mode
			makefile-mode-syntax-table)
   (modify-syntax-entry ?.   "_" ;fundamental-mode
                       makefile-mode-syntax-table)
  ))

(eval-after-load "shell"
  '(when (boundp 'shell-mode-syntax-table)
     ;; not Xemacs !!
     (modify-syntax-entry ?   " "       ;fundamental-mode
                          shell-mode-syntax-table)
     (modify-syntax-entry ?.   "_"      ;fundamental-mode
                          shell-mode-syntax-table)
     ))

(eval-after-load "sh-script"
  '(if (boundp 'shell-mode-syntax-table)
       (modify-syntax-entry ? " " sh-mode-syntax-table)));fundamental-mode

'(eval-after-load "css-mode"
  '(modify-syntax-entry ?   " " ;fundamental-mode
		     css-mode))

'(eval-after-load "compile"
  '(modify-syntax-entry ?   " " ;fundamental-mode
		     compilation-mode))



(defun syntax-space ()
  ""
  (interactive)
  (modify-syntax-entry ?   " "))


(defun syntax-table-correct ()
  ""
  (interactive)
  (modify-syntax-entry ?  " " (syntax-table)))




(eval-after-load "cperl-mode"
  '(modify-syntax-entry ?   " " ;fundamental-mode
		     cperl-mode-syntax-table))




(defun make-space-space (&optional table)
  (modify-syntax-entry ?   " " table))
  
(add-hook 'css-mode-hook 'make-space-space)
	  

(eval-after-load "cperl"
  '(modify-syntax-entry ?   " " ;fundamental-mode
		     cperl-mode-syntax-table)
  )



;(format "%s" (symbols-matching-re "syntax-table" 't))

;`
;; (if the command is ...)
;; (message "syntax")

(defvar file-name-reading-syntax-table
  (make-syntax-table)
  "")

(let ((table file-name-reading-syntax-table))
  (modify-syntax-entry ?/ "." table)
  (modify-syntax-entry ?. "_" table)
  (modify-syntax-entry ?\  "_" table))

;(modify-syntax-entry ?\  " " (standard-syntax-table))
;(setq minibuffer-preferred-syntax-table file-name-reading-syntax-table)
(defvar minibuffer-preferred-syntax-table nil "")


(defun my-minibuffer-setup-hook ()
  "change syntax, so that pathname editing can use sexp navigation to skip to '/'"
  (unless running-xemacs
    (set-syntax-table
     (cond
      ;; this is suspect:
      (minibuffer-preferred-syntax-table
       (setq minibuffer-preferred-syntax-table
             (if emacs-22
                 (make-syntax-table)
               nil))
       ;; minibuffer-preferred-syntax-table
       minibuffer-preferred-syntax-table)

      ((eq minibuffer-history-variable 'grep-history)
       (require 'sh-script)
       (if emacs-22
           sh-mode-default-syntax-table
         sh-mode-syntax-table))

      ((eq (current-local-map) read-expression-map)
       emacs-lisp-mode-syntax-table)
      ('t
       file-name-reading-syntax-table)))))

(add-hook 'minibuffer-setup-hook 'my-minibuffer-setup-hook)


; normal-top-level-add-subdirs-to-load-path

;; fixme: all 

;(modify-syntax-entry ?  " " psql-mode-syntax-table)
;(modify-syntax-entry ?_  "_" sql-mode-syntax-table)

;;minibuffer-setup-hook

; (remove-hook 
;  'minibuffer-setup-hook
;  (lambda ()
;    (message "syntax")
;   (modify-syntax-entry ?/ "." )))



(provide 'mmc-syntax)

