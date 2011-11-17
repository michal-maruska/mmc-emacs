
(eval-when-compile
  (require 'diff-mode))
(require 'cl)


(defun diff-2-ediff ()
  "invoke ediff on the context of 2 files in diff-mode"
  (interactive)
  ;; A
  (destructuring-bind (buf-A line-offset pos old new &optional switched)
      (diff-find-source-location 't nil)
    ;; B
    (destructuring-bind (buf-B line-offset pos old new &optional switched)
	(diff-find-source-location nil nil)
      (ediff-buffers buf-A buf-B))))

(define-key diff-mode-map "\C-c\C-n" 'diff-hunk-next)
(define-key diff-mode-map "\C-c\C-p" 'diff-hunk-prev)
(define-key diff-mode-map "\C-c\C-c" 'diff-2-ediff)
(define-key diff-mode-map "\C-c\C-e" 'diff-goto-source)


; (set-face-foreground 'diff-added (face-foreground 'magit-diff-add))
;(set-face-foreground 'diff-removed (face-foreground 'magit-diff-del))
;; (face-background 'magit-diff-add)
; (face-foreground 'magit-diff-add)
;(set-face-foreground 'diff-file-header-face "yellow")



(defun fast-diff-mode ()
  ""
  (interactive)
  (setq buffer-read-only 't))

(defface diff-overlay-face nil "")

(defun diff-post-command-hook ()
  ;(magit-correct-point-after-command)
  (fast-diff-mode-highlight))

(add-hook 'post-command-hook #'diff-post-command-hook t t)
;; (set-face-background 'diff-overlay-face "gray9")


(defvar fast-diff-highlight-overlay nil)
(defun fast-diff-mode-highlight ()
  ""
  (interactive)
  (save-excursion
    (let* ((start (progn (diff-beginning-of-hunk 'try-harder) (point)))
	   (end (progn (diff-end-of-hunk) (point))))
      (if (and start end)
	  (if fast-diff-highlight-overlay
	      (move-overlay fast-diff-highlight-overlay
			    start end)
	    (setq fast-diff-highlight-overlay
		  (make-overlay start end)
		  ;;(current-buffer)
		  )
	    (overlay-put fast-diff-highlight-overlay 'face 'diff-overlay-face)))
      ;;priority'
					;(overlay-put overlay 'backtround "dim gray")
      )))


(provide 'mmc-diff)
