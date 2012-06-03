;;;  my extensions to sawfish.el
(require 'sawfish)
;; todo:
;;     automatic  go-to-exports  go-to-open skeletons ...

;; customization:
(autoload 'sawfish-mode "sawfish" "sawfish-mode" t)



;;; movements

;; There seems to be a bug in emacs-21.1 lisp.el
;; patch here: http://ruska.dyndns.org/comp/patches/diffs/emacs/lisp.el
(defun sawfish-beginning-of-defun (&optional arg)
  "Just a stupid hack, i should go to define-structure and descend (forward-list) ?"
  (interactive "p")
  ;; the problem is, that we want to skip away from the current line.
  (and (re-search-backward "^[ 	]*(def\\(var\\|un\\|ine\\)"
			   nil 'move (or arg 1))
       (progn (goto-char (1- (match-end 0))))
       (back-to-indentation)
       ;; i wanted to return nil because see: the source of beginning-of-defun
       ;; how to link it in hyperbole?
       't))

(when nil
  (sawfish-beginning-of-defun)
  ;; default:
  (setq
   defun-prompt-regexp nil
   open-paren-in-column-0-is-defun-start 't
   )
  ;; does not work
  (setq
   defun-prompt-regexp nil
   open-paren-in-column-0-is-defun-start nil
   (set (make-variable-buffer-local 'open-paren-in-column-0-is-defun-start) nil)
   (set (make-variable-buffer-local 'defun-prompt-regexp "(define")
	)))


(when nil
  (setq beginning-of-defun-function nil)
  (set (make-variable-buffer-local 'beginning-of-defun-function)
       (function sawfish-beginning-of-defun))  
  )


;;; `Ffap'
;;; loading ... i don't use it
(defun sawfish-load-path ()
  (sawfish-code load-path))
;; (sawfish-load-path)


;; TODO: sawfish-version & rep-version automatic
(defconst sawfish-src-path
  '(
    "/internet/cvs/gnome/sawfish/src"
    "/internet/cvs/gnome/librep/src"
    "/internet/cvs/gnome/rep-gtk"

    "/home/mmc/sf/.src/"
    )  "*Where to find C sources.")


(require 'mmc-string)


;; fixme: we should ask the sawfish-client! (locate-file )

;; todo   (sawfish-code (locate-file "workspace.jl" load-path))
; (sawfish-code (locate-file "sawfish/wm/util/prompt-wm.jl" load-path))

(require 'mmc-files)

(defun ffap-sawfish-mode (name)
  "Given string/name of sawfish/rep module: XXX.YYY.ZZZ.module,
find and return its path in the filesystem"
  (let ((relative (add-suffix-optionally (translate-module-to-filename name ".") ".jl"))
        path found)
    ;; take the first...
    (setq found
	  (or
	   ;; (let ((filename (compose-path (expand-file-name "~/sf/before/lisp") relative)))
	   ;;   (if (file-exists-p filename)
	   ;; 				;filename
	   ;; 	 nil))
	   (sawfish-eval-read
	    (format "(locate-file \"%s\" load-path)" relative))))
    (unless found
      ;; try the C  sources
      (let* ((last-word
              (progn
                (string-match "\\.?\\([^.]*\\)$"  name)
                (match-string 1 name)))
             (basename (concat last-word ".c")))
        (setq found
	      (find-subpath-in-paths basename sawfish-src-path))))
    found))

(require 'assoc)

;; fixme:   (eval-after-load "ffap" '(....)) !!
(require  'ffap)
;; register:
(aput 'ffap-alist 'sawfish-mode 'ffap-sawfish-mode)
(aput 'ffap-alist ' inferior-lisp-mode 'ffap-sawfish-mode)
;ffap-alist
;;; keys
;; not used
(defun my-redefine-key (map key command)
  "should record somewhere the original binding, so that it is accessible")

(eval-after-load 
    "sawfish"
  '(let ((map sawfish-mode-map)
	 ;;(swe-map (make-sparse-keymap))	; sawfish-emacs   --- bad it could be the emacs-lisp-mode-map !
	 )
     ;; 
					; (define-key map [(control c)]          emacs-lisp-mode-map)	;swe-map
     (define-key map [(control x) (control e)]             #'sawfish-eval-last-sexp)
     (define-key map [(meta control x)]                    #'sawfish-eval-defun)
     (define-key map [(meta :)]                            #'sawfish-eval-expression)

     (define-key map [(control h) ?a]          #'sawfish-apropos)
					;(define-key swe-map [(control h) ?a] 'apropos)
    
     (define-key map [(control h) ?f]          #'sawfish-describe-function)
					;(define-key swe-map [(control h) ?f]          #'describe-function)

     ;(define-key sawfish-mode-map [(control ?.)]          #'sf-find-function-module) ;?w


     (define-key sawfish-mode-map [(control ?H) ?W]          #'sf-find-function-module) ;?w


     (define-key map [(control c) (control c)] #'my-sawfish-console)
    
     (define-key map [(control h) (control f)] #'sawfish-info-function)
     ;;(define-key swe-map [(control h) (control f)] #'info-function)
    
     (define-key map [(control h) ?v]          #'sawfish-describe-variable)
     ;;(define-key swe-map [ (control h) ?v]          #'describe-variable)


     (define-key map [(control h) (control v)] #'sawfish-info-variable)
     ;;(define-key map [(control c) (control h) (control v)] #'info-variable)

     ;; (define-key map [(control h) ?i]          #'sawfish-info)
     (define-key map [(meta control ?i)]                   #'sawfish-complete-symbol)
     (define-key map [(control meta :)]                    #'eval-expression)
     ))

;;; my hook ... the mode:

					;(define-derived-mode sawfish-mode scheme-mode

;; inferior-lisp-mode
(defun my-sawfish-mode-init ()
  ""
  (set (make-local-variable 'beginning-of-defun-function)
       (function sawfish-beginning-of-defun))
  (set (make-local-variable 'compile-command)
       (format "sawfish --batch -l compiler -f compile-batch %s" (buffer-file-name)))
  (set (make-local-variable 'outline-regexp)
       ";;;;* \\| *(def\\| +;; ")	; show comments too

					;(inferior-lisp-minor-mode)
  (set (make-local-variable 'inferior-lisp-program) "sawfish-client")
  
					; (setq pop-up-windows
  (set (make-local-variable 'lisp-function-doc-command)
       ",describe %s\n")
  (set (make-local-variable 'lisp-var-doc-command)
       ",describe %s\n")
  (set (make-local-variable 'lisp-describe-sym-command)
       ",describe %s\n")
  (set (make-local-variable 'lisp-where-sym-command)
       ",whereis %s\n"))

(add-hook 'sawfish-mode-hook 'my-sawfish-mode-init)


;;; symbols
					;(sawfish-eval ",locate  window-really-wants-input-p")
'(call-process sawfish-client nil "ahoj" 't sawfish-exec-parameter ",locate  window-really-wants-input-p")


;;; console
(defun my-sawfish-console ()
  ""
  (interactive)
  (if inferior-lisp-buffer
      (progn
	(switch-to-buffer-other-window inferior-lisp-buffer)
	;; insert: ,in module-name 
	)
    (sawfish-console)))

;; use run-list instead !
(defvar sawfish-buffer nil "")
					; (make-variable-buffer-local 'sawfish-buffer)

(defun sawfish-console (&optional arg)
  "Run the sawfish client as an inferior lisp."
  (interactive "p")
  (let ((inferior-lisp-prompt sawfish-comint-prompt))
    ;; TODO: How to set lisp-*-command variables for this particular
    ;; instantiation of the inferior lisp buffer?
    ;; TODO: How to provide TAB completion in this buffer?
    (run-lisp (format "%s %s" sawfish-client sawfish-interactive-parameter))
    (setq sawfish-buffer (get-buffer "*inferior-lisp*"))
    ))


					;(setq sawfish-comint-prompt "^[[:word:]]*>")
(setq lisp-describe-sym-command ",describe %s\n")
(when nil 
  special-display-buffer-names
  same-window-regexps
  (delete "*inferior-lisp*" same-window-buffer-names) ;;  why was it there ?
  special-display-regexps
  )



;;; byte-compile  --- not used!
(defun sawfish-byte-compile (filename)
  ""
  (interactive
   (let* ((buffer-file (buffer-file-name))
	  (dir (file-name-directory buffer-file))
	  (basename (file-name-nondirectory buffer-file)))
     (list (expand-file-name
	    (my-read-file-name
	     "byte-compile file: "
	     dir basename 't)))))
  (let ((output-buffer (get-buffer-create "*sawfish-byte-compile*")))
    (sawfish-eval
     (format "(require 'rep.vm.compiler)(compile-file \"%s\")" filename)
     ;;`(compile-file ,filename)
     output-buffer)
    (display-buffer output-buffer)))


;; these are in sawfish.el ?

;;; indentation
(put 'define 'lisp-indent-function 'defun)
(put 'let-fluids 'lisp-indent-function 1)
(put 'delete-if 'lisp-indent-function 1)
(put 'delete-if-not 'lisp-indent-function 2)

(put 'call-with-keyboard-grabbed-soft* 'lisp-indent-function 1)
(put 'with-key-repeat-rate 'lisp-indent-function 2)


(put 'mm-add-hook 'lisp-indent-function 1)
(put 'read-and-run 'lisp-indent-function 1)

;; i disagree !!!
;(put 'open 'lisp-indent-function 1)
;(put 'export 'lisp-indent-function 1)

;;; Debugging SF: [14 dic 01] i want to send signals to flog(1) from inside emacs.
;; important to filter out the debug of switch-window (to the xterm)...

(defvar sawfish-rotate-log-counter 0 "")
;; (setq sawfish-rotate-log-counter 10)
(defun sawfish-rotate-log ()
  ""
  (interactive)
  (shell-command
   (concat "~/activity/shell/sawfish_rotate_log "
	   (int-to-string (setq sawfish-rotate-log-counter (1+ sawfish-rotate-log-counter))))))

(global-set-key [(alt ?l)] 'sawfish-rotate-log)

;;; Conclusion



					;(define-key inferior-lisp-minor-mode-map "C" nil)
					;  (lookup-key inferior-lisp-minor-mode-map
					;inferior-lisp-mode-map
					;	      "C")


(defvar sawfish-common-keymap (make-sparse-keymap) "")

;(set-keymap-parent sawfish-common-keymap 

;(use-local-map 
(define-key sawfish-common-keymap [(control ?i)]  #'sawfish-complete-symbol)
;(define-key sawfish-common-keymap 

  
;; sawfish-warning-keyword-list
;;; customization
(run-wo-fail
 ;; [23 mar 03] i think, that evalling sawfish.el  solves the problem:
 ;;    ... but i lose the keymap !!
 (sawfish-font-lock-compute-keywords
  'sawfish-warning-keyword-list
  '("fixme" "mmc:" "fixme:" "FIXME" "Fixme" "fix me" "Fix me" "!!!" "Grrr" "Bummer" "BUG" "???" "todo" "\\bold\\b"
    "define-command\\b"                    ;;
    "#!key"
    "define-cycle-command-pair"
    ))

 ; define-command
 
 (custom-set-variables
  '(sawfish-warning-keyword-list
    (list "fixme" "fixme:" "FIXME" "Fixme" "fix me" "Fix me" "!!!" "Grrr" "Bummer" "BUG" "???" "todo" "new")))
					; (sawfish-compute-keywords)(sawfish-font-lock-compute-keywords)
 )




;(bind-keys my-window-keymap

(put 'bind-keys  'lisp-indent-function 1)
(put 'unbind-keys  'lisp-indent-function 1)
(put 'define-command 'lisp-indent-function 1)


;; mmc:
(put 'define-interface 'lisp-indent-function -1)
(put 'export  'lisp-indent-function 0)
(put 'open  'lisp-indent-function -1)

(defun ++ (&rest args)
  (font-lock-add-keywords 'emacs-lisp-mode
    ;sawfish-mode
    args))


;(aget font-lock-keywords-alist 'sawfish-mode)
;(setq font-lock-keywords-alist (cdr font-lock-keywords-alist))
(++ '("^\\s-*(define\\s-+(\\(\\(\\sw\\|\\s_\\)*\\)\\b" 1 font-lock-def-face))

;define (cycle-begin windows step)




(defvar sawfish-helper-process nil "")

(run-wo-fail
 (setq sawfish-helper-process
					;(get-process "sawfish-helper")
       (start-process "sawfish-helper" " sawfish-helper "  sawfish-client))
 )

(defun sf-find-function-in-buffer (function-name arg)
  ""
  (unless arg (goto-char (point-min)))
  (do ((define-symbol
         (search-forward-regexp
          (concat "\\(def\\(\\s_\\|\\sw\\)*\\)[^\"

]*" "\\S_" (regexp-quote function-name) "\\S_"))
         (search-forward-regexp (concat "\\(def\\(\\s_\\|\\sw\\)*\\).*"
                                        "\\S_"
                                        (regexp-quote function-name) "\\S_"))))
      ((not (member (erase-text-properties (match-string 1)) '("define-structure-alias"))) t))
  (message (match-string 0)))


(defun sf-find-function-module (function-name arg)
  "return a list of (librep) modules, where the "
  (interactive (list (find-tag-default)
		     current-prefix-arg))
  (set-mark (point))
  (let ((sf-last-position (marker-position (process-mark sawfish-helper-process)))
	output)
    (process-send-string sawfish-helper-process
			 (concat ",whereis " function-name "\n"))
    (accept-process-output sawfish-helper-process)
    (with-current-buffer (process-buffer sawfish-helper-process)
      (setq output
	    (buffer-substring-no-properties
	     sf-last-position  (process-mark sawfish-helper-process))))

    (string-match ".* is exported by: \\(.*\\)\\.\n" output)
    (let ((modules (match-string 1 output)))
      ;;here we have: "%gaol, sawfish.wm, sawfish.wm.windows."
      (setq modules (split-string ", " modules))
      (setq modules (delete "%gaol" modules))
      (setq modules (delete "sawfish.wm" modules))

      (if modules
	  (let ((file (ffap-sawfish-mode (car modules))))
	    (find-file file)
	    (sf-find-function-in-buffer function-name arg))
	(message "%s is NOT exported" function-name)))))



;(sf-find-function-module "resize-window-with-hints*")



(defun lisp-display ()
  ""
  (interactive)
  (display-buffer (process-buffer (lisp-proc)) 't))


;(require 'ilisp)


(provide 'mmc-sawfish)
