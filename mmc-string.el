;; (require 'string)


;; (require 'dircolors)
;; `gives':
;; generic functions not included in emacs
(defun string-join (xs &optional sep)
  (cond ((null xs) "")
	((null (cdr xs)) (car xs))
	(t (concat (car xs) (or sep " ") (string-join (cdr xs) sep)))))

;; (string-join (string-split "\\." "a.b") "/")  <-- string-replace-match
;; we need source
;; (load "/usr/share/emacs/site-lisp/elib/string.el")


;; I use it in my-perl too
(defun translate-module-to-filename (module separator)
  ""
  ;; if the module does contain "/" then it is already a filename !!!
  (if (string-match "/" module)
      module
    ;; (regexp-quote separator)
    (or (string-join (split-string module "\\.") "/")
	;;(string-replace-match "\\." module "/" 't 't)
	module)))

;; (translate-module-to-filename "a.b" ".")
(provide 'mmc-string)
