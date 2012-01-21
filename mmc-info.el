;; http://ruska.dyndns.org/comp/activity/emacs/my-info.el

(require 'mmc-simple)
;; from sawfish.el !!

(defun search-info-files (index-function symbol info-files)
  "Look for SYMBOL in all the sawfish info files.

INDEX-FUNCTION is used to decide which index name will be searched. The
function is used to access the lists in `sawfish-info-files'."
  (loop for info-file in info-files
        if (sawfish-find-info-entry (car info-file) (funcall index-function info-file) symbol) return t
        finally (error "No info documentation found for %s" symbol)))



(defun gtk-info-doc (function)
  ""
  (interactive (list (thing-at-point 'symbol))) ;((function "gtk_box_pack_start"))
  (search-info-files #'sawfish-info-function-index
                     function
                     '(("gtk" "Function Index" "Variable Index")
                       ("gdk" "Function Index" "Variable Index")))
  (sawfish-jump-to-info-documentation function))



;;; Info path
(mapc
 (lambda (item)
   (add-to-list 'Info-default-directory-list item))
 (list "/x/internet/scheme/info"))


;(setq Info-dir-contents-directory "/usr/info")
(setq Info-directory-list
      (mapcar-nonil (lambda (file)
		  (if (file-exists-p file)
		      file nil))
		 (list
		  "/usr/share/info/" 
		  "/usr/info/Emacs/" 
		  "/usr/info/xemacs/" 
		  "/usr/info/TeX"
		  "/usr/info/"
		  "/usr/info/GCC"
					; "/usr/info/Howto"
					;	    (concat xemacs-root "info")
		  ;; "/internet/commercial/beopen/infodock/id-info/"
		  )))



;;; some handy keys:
(eval-after-load 
    "info"
  '(progn
     (if running-xemacs
         (define-key Info-mode-map [backspace] 'Info-scroll-prev)
       (define-key Info-mode-map [backspace] 'Info-scroll-down))
     (define-key Info-mode-map [(control ?i)] 'Info-next-reference)
     ;; (define-key Info-mode-map [(meta control ?i)] 'Info-prev-reference)
     (define-key Info-mode-map [(meta ?i)] 'Info-prev-reference)
     (define-key Info-mode-map [(control ?I)] 'Info-prev-reference)
     ))


;;; switching TO info buffers:
                                        ;(buffers-in-mode 'Info-mode)
(defun switch-to-info-buffer (buffer)
  "switch to one of those buffers which are in the Info mode."
  (interactive 
   (let ((buffers (buffers-in-mode 'Info-mode 'names-please))
	 info-list name); note name is declared here but used in the inner lambda-function, dynamic scope!
     (list (my-completing-read "Info buffer: " buffers nil 't "*info"))))
  (switch-to-buffer buffer))

(define-key  my-global-keymap [(control ?i)] 'switch-to-info-buffer)

(defun Info-locate-book (book)
  "find the File containing info document on BOOK"
  ;; i would love to make it in scheme: fix the path in the function!!
  (let* ((path Info-default-directory-list)
	 (found (or (locate-file book path) ;must be a reg. file & file(1) ??
		    (locate-file (concat book ".gz") path)
		    (locate-file (concat book ".info") path)
		    (locate-file (concat book ".info.gz") path)
		    (locate-file (concat book ".info-1") path)
		    (locate-file (concat book ".info-1.gz") path))))
    ;; (message "Info-locate-book in %s -> %s" path found)
    found))

;(equal "elisp" (Info-locate-book "elisp"))

(defconst major-mode-info-mapping
  '(
    (gud-mode . "gdb")
    (sh-mode . "zsh")
    (emacs-lisp-mode . "elisp")
    (scheme-mode . "gauche-refe")       ;scheme
    (sawfish-mode . "sawfish")
    (awk-mode . "gawk")
    (makefile-mode . "make")
    (makefile-gmake-mode . "make")
    (gnus-group-mode . "gnus")
    (gnus-article-mode . "gnus")
    (gnus-summary-mode . "gnus")	;buffer

    (autoconf-mode . "autoconf")

    (sgml-mode . "psgml")	;buffer
    )
  "mapping Major mode -> info file"
  )


(defun file= (file-1 file-2)
  ""
  (string= file-1 file-2))


(defun my-aget (alist key)
  (let ((result nil)
	(a alist))
    (while (consp a)
      (if (equal key (caar a))
	  (setq result (cdar a)
		a ())
	(setq a (cdr a))))
    result))

;; (my-aget major-mode-info-mapping 'emacs-lisp-mode)

;;; context (major-mode) sensitive  Info
(defun my-info (prefix)
  "this is a context sensitive `info'. Through the PREFIX you can request:
C-u --> standard info, C-u C-u --> select 1 of the *info buffers, otherwise mode-specific!"
  (interactive "P")
  (cond ((= (prefix-numeric-value prefix) 4)
	 (message "prefix -> plain info")
	 (call-interactively 'info))
	;; fixme: 2011-05-17   where is `my-get-buffer-find-file' ?
	;(prefix
	; (switch-to-buffer (my-get-buffer-find-file "info buffer"  nil nil 't "*info-")))
	(t
	 (let ((info-book (my-aget major-mode-info-mapping major-mode))) ;return nil (not key)
	   (message "%s -> %s" major-mode info-book)
	   (if info-book
	       (visit-info-at info-book)
	     (info))))))

;; I divided into 2 function, otherwise byte-compiling damaged the semantics..
(defun visit-info-at (info-book)
  ""
  ;;  JUST BUGGY!
  (let ((info-file (Info-locate-book info-book))
	;;(i2        (Info-locate-book info-book))
	(info-buffers (buffers-in-mode 'Info-mode)))
    (if info-file
	(progn
	  ;; (if (string= info-file i2)
	  ;;     (message "ok %s = %s" info-file)
	  ;;   (progn
	  ;;    (message "Bug: %s != %s" info-file i2)
	  ;;    (error "bug")))

	  (message "looking at %s info buffers. For %s (%s)"
		   info-buffers		;(buffers-in-mode 'Info-mode) ;;
		   ;; bug: why info-file does not work?
		   info-file ;; (Info-locate-book info-book)
		   info-book)
					;(length info-buffers))
	  (let (
		       
		;;(info-book-name (string-match "-?[0-9]*\\.info" info-book))
		(info-buffer (list-search-positive
			      (lambda (item)
				(message "%s =? %s"
					 (variable-in-buffer item 'Info-current-file)
					 info-file)
				(if (file=
				     ;; fixme: ;(file-name-nondirectory 
				     (variable-in-buffer item 'Info-current-file)
				     info-file)
				    item))
			      info-buffers
					;(buffers-in-mode 'Info-mode)
			      )))
	    (if info-buffer
		(switch-to-buffer info-buffer)
	      (progn
		(message "invoking info on %s" info-file)
		(info info-file)))
	    (rename-buffer (concat "*info-" info-book) 'unique)))
      (progn
	(message "cannot find the File for info book %s" info-book)
	(info)))))

;; keys: (overload:)
;; batch does not like it:
;(unless (batch-
;(substitute-key-definition 'info 'my-info help-map);global-map) 
(define-key help-map [?i] 'my-info)


;; i don't use F keys anymore
;; (global-set-key [(control f1) ?i] 'switch-to-info-buffer)
;; (global-set-key [f1 ?a] 'apropos)






(defun my-current-info-node-name (&optional insert)
  ;; 
  (interactive "*P")
  (let ((node ""))
    (with-current-buffer (get-buffer "*info*")
      (setq node (concat "("
                         (file-name-nondirectory Info-current-file)
                         ")"
                         Info-current-node)))
    (if insert
        (insert node)
      (message node))))


(provide 'mmc-info)
