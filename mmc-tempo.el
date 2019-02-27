(require 'tempo)


(defconst elisp-tempo-tags ())		;disappeared?

(defun elisp-tempo ()
  "Set up emacs-lisp mode to use tempo.el"
  ;; (local-set-key [M-C-tab] 'tempo-complete-tag)
  ;(local-set-key "\C-c\C-f" 'tempo-forward-mark)
  (local-set-key "\C-c\C-b" 'tempo-backward-mark)
  (local-set-key " " 'tempo-space)
  (setq tempo-match-finder "(\\([^\\b]+\\)\\=")
  ;; in every buffer?
  (tempo-use-tag-list 'elisp-tempo-tags))



;;; why did i remove it ?
(global-set-key "\C-c\C-f" 'my-tempo-forward-mark)
(global-set-key "\C-c\C-b" 'tempo-backward-mark)


(defun my-tempo-forward-mark (prefix)
  ""
  (interactive "p")
  (or (tempo-forward-mark)
      (search-forward "'")))

;;
(when nil
  (global-set-key "\C-f" 'forward-char)
  (global-set-key [(control ?b)] 'backward-char))


(defun tempo-space ()
  (interactive)
  (if (tempo-expand-if-complete)
      nil
    (insert " ")))


;;; Emacs-Lisp mode

(define-key emacs-lisp-mode-map " " 'tempo-space)
;(elisp-tempo)

;(load "~/tempo/elisp.el" 't)
;; (load "~/emacs/tempo/elisp.el" 't)
(load "tempo/elisp.el" 't)


(provide 'mmc-tempo)


; (tempo-define-template
;  "interactive"
;  '("interactive" 
;    '(progn
;       (describe-function 'interactive)
;       (scroll-other-window)
;       (let ((char (read-char)))
; 	(delete-other-windows)
; 	(insert char)
;       ))
;    )
;  "inter"
;  "Insert a defun expression"
;  'elisp-tempo-tags)

