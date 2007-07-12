
;; diff-mode.el

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

(set-face-background 'diff-file-header-face "red")
(set-face-foreground 'diff-file-header-face "yellow")


(provide 'mmc-diff)
