


(defun show-region-limits (beg end)
  ""
  (interactive "r")
  (let ((other-end (if (= (point) beg) end beg))
        (opoint (point))
        (inhibit-quit t))
    (set-marker (mark-marker) (point) (current-buffer))
    (goto-char other-end)
    (sit-for 1)
    (set-marker (mark-marker) other-end (current-buffer))
    (goto-char opoint)
    
    (and quit-flag mark-active
		   (deactivate-mark))))

;;; this code works better when the <nick> is a 'field.
(defun erc-copy-region-wo-field (beg end)
  "`kill-ring-save', but strip away Fields"
  (interactive "r")
  (show-region-limits beg end)
  ;; i use a temporary buffer. That buffer should be w/o  kill-ring/undo !!
  (let ((temp-buffer (get-buffer-create " *strip fields*")))
    (with-current-buffer temp-buffer (erase-buffer))
    (append-to-buffer temp-buffer beg end)

    (with-current-buffer temp-buffer
      ;; remove the problematic Fields:
      (goto-char (point-min))
      (while (setq next (next-single-property-change (point) 'field))
        ;;prop &optional object limit
        (goto-char next)
                                        ;(field-beginning next 't)
                                        ;(field-end next 't)
                                        ;(field-string)
                                        ;(get-char-property next 'field)
                                        ;(field-string-no-properties)
                                        ;;(delete-field (point))
        (kill-region next (field-end next 't))) ;;
      (kill-ring-save (point-min) (point-max))
      (kill-buffer temp-buffer))))



(provide 'erc-kill)
