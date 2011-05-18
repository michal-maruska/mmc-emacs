
;;;  `ibuffer'


(defun ibuffer-limit-by-mode (mode)
  "Toggle current view to buffers with major mode MODE.
To disable the limit, call this function again." 
  (interactive
   (cons 
    (if (ibuffer-get-qualifier 'mode)
	nil
    (read-mode "Limit by major mode: "))
    nil))
  (cond (mode
	 (ibuffer-add-qualifier 'mode mode)
	 (message "View limited by major mode: %s" mode))
	(t
	 (ibuffer-remove-qualifier 'mode)
	 (message "Limiting by major mode disabled.")))
  (ibuffer-update-mode-name)
  (ibuffer-update nil t))


(defun ibuffer-visit-buffer ()
  "Enter the buffer on this line."
  (interactive)
  (let ((buf (ibuffer-current-buffer)))
    (unless (buffer-live-p buf)
      (error "Buffer %s has been killed!" buf))
    ;(bury-buffer (current-buffer))
    (switch-to-buffer buf)))

;;; `iswitchb'
(defun iswitchb-post-command ()
  "Run after command in `iswitchb-buffer'. mmc version"
  (iswitchb-exhibit)
  (if (= (length iswitchb-matches) 1)
      (display-buffer (car iswitchb-matches))))

(defun iswitchb-select-buffer-other-window ()
  "Select the buffer named by the prompt. But in another window."
  (interactive)
  (setq iswitchb-method 'otherwindow)
  (exit-minibuffer))

(defun iswitchb-define-mode-map ()
  "Set up the keymap for `iswitchb-buffer'.
This is obsolete.  Use \\[iswitchb-mode] or customize the
variable `iswitchb-mode'."
  (interactive)
  (let (map)
    ;; generated every time so that it can inherit new functions.
    ;;(or iswitchb-mode-map

    (setq map (copy-keymap minibuffer-local-map))
    (define-key map "?" 'iswitchb-completion-help)
    (define-key map "\C-s" 'iswitchb-next-match)
    (define-key map "\C-r" 'iswitchb-prev-match)
    (define-key map "\t" 'iswitchb-complete)
    
    (define-key map "\C-j" 'iswitchb-select-buffer-text)
    (define-key map "\M-m" 'iswitchb-select-buffer-other-window)
    (define-key map "\C-t" 'iswitchb-toggle-regexp)
    (define-key map "\C-x\C-f" 'iswitchb-find-file)
    ;;(define-key map "\C-a" 'iswitchb-toggle-ignore)
    (define-key map "\C-c" 'iswitchb-toggle-case)
    (define-key map "\C-k" 'iswitchb-kill-buffer)
    (define-key map "\C-m" 'iswitchb-exit-minibuffer)
    (setq iswitchb-mode-map map)
    (run-hooks 'iswitchb-define-mode-map-hook)))

(provide 'mmc-patches)
