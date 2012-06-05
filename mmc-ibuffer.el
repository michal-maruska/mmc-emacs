;; todo:
;; < >  to dired buffers?

(require 'ibuffer)
(require 'mmc-simple)


;;; I don't want to bury the  *Ibuffer* buffer.

;; my patch
(defun ibuffer-visit-buffer (&optional single)
  "Visit the buffer on this line.
If optional argument SINGLE is non-nil, then also ensure there is only"
  (interactive "P")
  (let ((buf (ibuffer-current-buffer)))
    (unless (buffer-live-p buf)
      (error "Buffer %s has been killed!" buf))
    ;;(bury-buffer (current-buffer))
    (switch-to-buffer buf)
    (when single
      (delete-other-windows))))


(autoload 'dircolors "dircolors")
(add-hook 'ibuffer-mode-hooks   'dircolors)
;;(remove-hook 'ibuffer-mode-hooks   'dircolors)

(global-set-key (kbd "C-x C-b") 'ibuffer)


(unless (or emacs-22 emacs-24)
  ;; This is the version for ~/emacs/patch/ibuffer.el
  ;; CVS emacs needs:
  ;; ibuffer-define-op
  (define-ibuffer-op kill-on-deletion-marks-quickly ()
					;(:documentation
    "Kill buffers marked for deletion as with `kill-this-buffer'."

    (:opstring "killed"
	       :active-opstring "kill"
	       :dangerous nil		;t
	       :complex t
	       :mark :deletion
	       :modifier-p nil		; t
	       )
    (let ((buffer buf)) ;; The new version uses `buffer'
      (if (buffer-file-name buffer)
          (de-context-kill buffer nil)
        ;; ask?
        (if (buffer-modified-p buffer)
            nil
          (kill-buffer buffer)))))

  (define-key ibuffer-mode-map [(control ?k)]
    (lambda ()
      (interactive)
      (let ((ibuffer-expert 't))
        (call-interactively 'ibuffer-mark-for-delete)
        ;; ibuffer-do-kill-on-deletion-marks
        (call-interactively
                                        ;'ibuffer-do-kill-on-deletion-marks
                                        ;'ibuffer-do-kill-buffer-quickly
         'ibuffer-do-kill-on-deletion-marks-quickly
         )
        ))))

(provide 'mmc-ibuffer)
