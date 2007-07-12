;; I define some new faces

;   '(("\\(di\\|sub\\)graph \\(\\sw+\\)" (2 font-lock-function-name-face))))

;;; installing a *GLOBAL* fontified keyword

;;; on #emacs    someone got the idea of fontlocking numbers. 
(defvar font-lock-number-face (make-face 'font-lock-number-face)
  "Face to use for numbers.")
(set-face-foreground 'font-lock-number-face "red")

;; hmmm, no:
'(mapcar
  (lambda (mode)
    (font-lock-add-keywords mode '(("\\([[:digit:]]+\\)" . font-lock-warning-face))))
  font-lock-defaults-alist)


(defun font-lock-add-my-global()
  (when font-lock-mode
    (if nil
        (progn
          ;; Old approch
          (add-to-list 'font-lock-keywords '("\\b\\([[:digit:]]+\\)\\b" (1 font-lock-number-face prepend))) ; keep 't keep prepend append
                                        ;(add-to-list 'font-lock-keywords '("\\([[:digit:]]+\\)" (1 font-lock-number-face)) 't)
          (add-to-list 'font-lock-keywords '("`\\(\\(\\s_\\|\\sw\\)+\\)'" (1 font-lock-important prepend))) ; t
          (add-to-list 'font-lock-keywords '("*\\(\\(\\s_\\|\\sw\\)+\\)*" (1 font-lock-warning-face prepend)))
          ;; bold

          (add-to-list 'font-lock-keywords '("\\b\\(fixme\\|XXX\\|mmc\\|todo\\|bug\\|obsolete\\|note\\|new\\)[:!?]"
                                             (1 font-lock-warning-face prepend)))) ; t

      ;; In CVS: 
      (progn
        (font-lock-add-keywords nil
          '(
            ;; Numbers
            ("\\b\\([[:digit:]]+\\)\\b" 1 font-lock-number-face t) ;; 't) ; keep prepend append
            ;; keep ... exclusive !
            ;; append
            ;; prepend
            ;; `keywords'
            ("`\\(\\(\\s_\\|\\sw\\)+\\)'" 1 font-lock-important prepend) ;) 't)

            ;; ("\\*\\(\\(\\s_\\|\\sw\\)+\\)\\*" 1 font-lock-warning-face prepend)
            ;; fixed words:
            ("\\b\\(fixme\\|XXX\\|mmc\\|todo\\|bug\\|obsolete\\|note\\|new\\)[:!?]" 1 font-lock-warning-face prepend); 't)
        ))))))
    

    

;;; This works:
;(unless emacs-22
(add-hook 'font-lock-mode-hook 'font-lock-add-my-global)

;(setq font-lock-mode-hook (cdr font-lock-mode-hook))
;(setcdr font-lock-mode-hook nil)
;(set-default 'font-lock-keywords '())
;(setcdr font-lock-keywords (nthcdr 2 font-lock-keywords))
;(font-lock-remove-keywords 'c-mode '(("\\([[:digit:]]+\\)" font-lock-warning-face)))







;; font-lock
(defun add-keyword-to-font-lock (keyword face)
  "only in the current buffer!"
  (interactive
   (list
    (read-string "keyword (to add) : ")
    (read-face-name "face: ")))
  (font-lock-add-keywords
   nil
   (list (concat "\\(" keyword "\\)")
	 1 face 't 't)
   't))

(when nil
  (font-lock-add-keywords
    nil
    '(("\\(find_window_by_id\\)" 1 font-lock-section-face t t)) 't)
  
  faces
  basic-faces
  w3-active-faces
  )


;;; Global (setting)
(unless running-xemacs
  (global-font-lock-mode +1 t))

(unless emacs-22
  (setq font-lock-support-mode (if 't 'lazy-lock-mode
                                 'fast-lock-mode )
        lazy-lock-stealth-time 10
        lazy-lock-stealth-load 1
        lazy-lock-stealth-nice 18
        lazy-lock-stealth-lines 10000
        lazy-lock-stealth-verbose t
        lazy-lock-minimum-size 10000)
  )


;;; additional  for specific major modes
(unless running-xemacs
  (font-lock-add-keywords 
    'Man-mode
    '(("\\<\\(NAME\\|SYNOPSIS\\|OPTIONS\\|DESCRIPTION\\|ENVIRONMENT\\|SEE ALSO\\|BUGS\\|AUTHOR\\)"
       1 font-lock-warning-face prepend)
      ("\\<\\(and\\|or\\|not\\)\\>" . font-lock-keyword-face)))


;;; i simply like the `xxx' in comments
  (font-lock-add-keywords 
    'c-mode
    '(("`\\(\\(\\s_\\|\\sw\\)+\\)'" 1 font-lock-important prepend)))
  )


;;; additional `Faces'
(defvar font-lock-section-face)
(setq font-lock-section-face 'font-lock-section-face)
(setq font-lock-th-face 'font-lock-th-face)
(setq font-lock-lemma-face 'font-lock-lemma-face)
(setq font-lock-def-face 'font-lock-def-face)
(setq font-lock-secondary 'font-lock-secondary)
(setq font-lock-important 'font-lock-important)

(make-face 'font-lock-section-face)
(make-face 'font-lock-def-face)
(make-face 'font-lock-th-face)
(make-face 'font-lock-lemma-face)
(make-face 'font-lock-secondary)
(make-face 'font-lock-important)

(unless running-xemacs
  (font-lock-add-keywords
   'latex-mode
   '(("\\\\\\(section\\|chapter\\|paragraf\\)\\b"
      1 'font-lock-section-face prepend)
     ("\\\\begin{\\(theorem\\)}"
      1 'font-lock-th-face prepend)
     ("\\\\begin{\\(lemma\\)}"
      1 'font-lock-lemma-face prepend)
     ("\\\\begin{\\(definice\\)"
      1 'font-lock-def-face prepend)
     ("\\\\\\(begin\\|end\\|item\\)\\>"
      1 'font-lock-secondary)
     ("\\[\\(.*\\)\\]"
      1 'font-lock-important)
     ("\\\\end{\\([^}]*\\)}"
      1 'font-lock-secondary)
     )))


(unless running-xemacs
  (font-lock-add-keywords
  'm4-mode
  '(
    ("\\(@dnl\\b\\|^\\#\\).*$" . font-lock-comment-face)
    ("@[a-zA-Z_]*" . 'font-lock-keyword-face)
    ("define(\\([^,]*\\)," 1 'font-lock-def-face))
  'set)
  )
; (font-lock-add-keywords 'Info-mode
;   '(("\\*\\(note\\|Note\\)"
;      1 'font-lock-important prepend)
;     ("^\\* \\([^:]*\\):"
;      1 'font-lock-important)
;     ("\\(Function\\|Command\\):"
;      1 'font-lock-function-name-face)
; ;    ("\\<\\*"
; ;     1 'font-lock-important)
;     ))
  


(provide 'mmc-font-lock)