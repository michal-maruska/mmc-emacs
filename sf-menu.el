;;; Menus:
;; Warning. i took pieces from the process-menu.el and started to overwrite it, expect some non-sense

(require 'mmc-simple)
(defconst sf-windows-buffer "*sf-windows*" "name of the ..buffer")
;;; w/  Widgets: not used.
(when nil
  (require 'wid-edit)
  (define-widget 'sf-window 'group
    "doc"
    :tag "win: "
					;  :format "%t:[%v]"
    :args
    '(
      (integer :tag "id " :size 5)
					; (item :tag " \n ")
      (string :tag "name " :size 25)
					;(widget-insert "\n")
      ))

(defun sf-windows (info)
  "GUI interface, not used now."
  (interactive)
  (switch-to-buffer (get-buffer-create sf-windows-buffer))
  (let ((inhibit-read-only t))
    (erase-buffer)
    (mapcar
     (lambda (item)
       (widget-create 'sf-window
		      :value item)
       (widget-insert "\n"))
     info))
    (widget-setup)
    (widget-minor-mode))
)

;;; Text
(defmacro with-output-to-temp-buffer-bury (buffer-name &rest body)
  ""
  (let ((buf-name (make-symbol "buf-name")))
    `(let ((,buf-name ,buffer-name))
       (with-output-to-temp-buffer ,buf-name
	 ,@body)
       (bury-buffer ,buf-name))))

(put 'with-output-to-temp-buffer-bury 'lisp-indent-function 1)
;(put 'define 'lisp-indent-function 'defun)
;(put 'let-fluids 'lisp-indent-function 1)

(defun sf-list-windows (&optional workspace)
  ""
  (interactive "P")
  (if (equal workspace '(4))
      (setq workspace (sawfish-eval 'current-workspace)))
  ;(save-excursion
  (let ((buffer (get-buffer-create sf-windows-buffer))
	(old-buffer (current-buffer)))
    (with-current-buffer buffer
      (let ((inhibit-read-only t))
	(erase-buffer)
	(sawfish-eval `(require 'emacs.snooper))
	(sawfish-eval `(emacs-list-windows ,workspace) buffer)
	(sf-format-output)
	(set-buffer buffer)
	(sf-menu-mode)
	(goto-char (point-min))))
    (unless (eq old-buffer buffer)
      (switch-to-buffer-other-window buffer 't)
      (bury-buffer buffer)		;fixme
      )))



;; id  \t   #swap  workspace  name
(defconst sf-line-regexp "\\(-?[[:digit:]]+\\)[ \t]*\\([[:digit:]]\\)[ \t]*\\([[:digit:]]\\)"
  "regexp matching the line in the `sf-windows-buffer' buffer")

(defun sf-get-item-from-current-line (n)
  "the line consists of fields, get th N-th one"
  (save-excursion
    (goto-char (point-bol))
    (looking-at sf-line-regexp)
    (match-string n)))

(defun sf-window-on-the-line ()
  ""                                    ; number ->
  ;; return as `string' -> longer that emacs integer !!
  ;(string-to-int
  (sf-get-item-from-current-line 1));)

(defun sf-workspace-on-the-line ()
  ""
  (sf-get-item-from-current-line 3))


(defun sf-switch-to-window (id)
  "tell SF to display the window"
  (interactive (list (sf-window-on-the-line)))
  (sawfish-eval
			    ; `(display-window (get-window-by-id ,id))
   (format "(display-window (get-window-by-id %s))" id))) ; %d


;; (sawfish-eval '(display-window (get-window-by-id -109051890)))

(defun sf-menu-revert (&optional arg)
  ""
  (interactive "P")
  (sf-list-windows arg))

(defun sf-limit-to-workspace (&optional arg)
  ""
  (interactive "P")
  (unless arg (setq arg (string-to-number (sf-workspace-on-the-line))))
  (sf-list-windows arg))


(defvar sf-menu-mode-map (make-sparse-keymap)
  "Mode map used in the buffer `*Process List*'.")
;; (setq sf-menu-mode-map (make-sparse-keymap))


(defun sf-add-window-to-space (w space)
  (interactive
   (list (sf-window-on-the-line)
         (string-to-number (read-string "space: ")))) ; fixme
  (sawfish-eval `(ws-add-window-to-space (get-window-by-id ,w) ,space)))






(let ((map sf-menu-mode-map))
  (define-key map "\C-m" 'sf-switch-to-window)
  (define-key map "\C-o" 'sf-switch-to-window)

  (define-key map "i" 'sf-info-on-window)
  (mapc
   (lambda (item)
     (define-key map (int-to-string item) 'digit-argument))
   '(1 2 3 4 5 6 7 8 9 0))
  (define-key map "w" 'sf-limit-to-workspace)
  (define-key map "a" 'sf-add-window-to-space)


  (define-key map "v" 'Process-menu-select)
  (define-key map "f" 'Process-menu-this-window)

  (define-key map "o" 'Process-menu-other-window)
  (define-key map "q" 'quit-window)
  (define-key map "d" 'Process-menu-delete)
  (define-key map "k" 'Process-menu-kill)
  (define-key map "b" 'Process-menu-quit)
  (define-key map "s" 'Process-menu-stop)
  (define-key map "z" 'Process-menu-stop)
  (define-key map "c" 'Process-menu-continue)
  (define-key map "\C-k" 'Process-menu-delete)
  (define-key map "x" 'Process-menu-execute)

  (define-key map "\C-cd" '(lambda ()
			     (interactive)
			     (switch-to-buffer "*inferior-lisp*")))



  (define-key map "W" 'Process-menu-send-buffer)
  (define-key map "e" 'Process-menu-send-eof)
  (define-key map " " 'next-line)
  (define-key map "n" 'next-line)
  (define-key map "p" 'previous-line)
  (define-key map "?" 'describe-mode)
  (define-key map "u" 'Process-menu-unmark)
  (define-key map "g" 'sf-menu-revert)
  (define-key map [mouse-2] 'Process-menu-mouse-select)
  )


(defun sf-format-output ()
  ""
  (goto-char (point-min)) (do-replace-string "\\012" "\n")
  (goto-char (point-min)) (do-replace-string "\\011" "\t")
  (goto-char (point-min))
  (delete-char 1)			; "
  (do-replace-string "=" "=\t")
  (goto-char (point-max))
  (backward-delete-char 1))

;(read-string

(defun sf-info-on-window (id)
  "Get a page with info on the WINDOW (given by id)"
  (interactive
   (let ((def (sf-window-on-the-line)))
     (list (if (string= (buffer-name) sf-windows-buffer)
		def
	     (string-to-number (read-string "window id: " def))))))
  ;134217742
  (let* ((buffer-name (format "*sf-%s*" id)) ;(truncate 146800642.0)
	 (buffer (get-buffer-create buffer-name)))
    (with-current-buffer buffer
      (erase-buffer)
      (sawfish-eval `(emacs-describe-window ,id)
		    buffer)
      (sf-format-output)
      (hscroll-mode)
      (cd "~/sawfish"))
    (switch-to-buffer-other-window buffer)
    (goto-char (point-min))))






(defun sf-menu-mode ()
  "Major mode for editing a list of processes.
Each line describes one of the processes in Emacs.
Letters do not insert themselves; instead, they are commands.

\\{Process-menu-mode-map}"
  (kill-all-local-variables)
  (use-local-map sf-menu-mode-map)
  (setq major-mode 'sf-menu-mode)
  (setq mode-name "sf Menu")
  (make-local-variable 'revert-buffer-function)
  (setq revert-buffer-function 'Process-menu-revert-function)
  (setq truncate-lines t)
  (setq buffer-read-only t)
  (run-hooks 'sf-menu-mode-hook))


(defun sf-list-windows-bad ()
  "Create and return a buffer with a list of names of existing processes.
The buffer is named `*Process List*'."
  (let ((old-buffer (current-buffer))
        ;(standard-output standard-output)
        desired-point)
    (with-current-buffer (get-buffer-create "*Process List*")
      (setq buffer-read-only nil)
      (erase-buffer)

      (setq standard-output (current-buffer))
      (princ "\
 S ID    Process      Buffer         Tty         Command
 - --    -------      ------         ---         -------
")
      ;; Record the column where process names start.
      (setq Process-menu-process-column 9)
      (let ((pl (process-list)))
	(Process-menu-mode)
	;; DESIRED-POINT doesn't have to be set; it is not when the
	;; current buffer is not displayed for some reason.
	(and desired-point
	     (goto-char desired-point))
	(current-buffer)))))




(defun sf-show-hooks ()
  "(try to) Show in a dedicated buffer the values of sawfish variables --- possible hooks"
  (interactive)
  (let ((buffer-name "*sf-hooks*"))
    (with-output-to-temp-buffer-bury buffer-name
      (princ
       (sawfish-code
	 (apply concat
		(mapcar
		 (lambda (hook)
		   (condition-case data
					;(unwind-protect
		       (format nil "%s = %s\n" hook (eval hook))
		     (error . "bad")))
		 (apropos "-hook$"))))))
    (set-buffer buffer-name)
    (sf-format-output)
    (sawfish-mode)
    (hscroll-mode)
    (cd "~/sawfish")			;set-default-directory
    ))

(global-set-key [(control ?x) ?w] 'sf-list-windows)


(provide 'sf-menu)
