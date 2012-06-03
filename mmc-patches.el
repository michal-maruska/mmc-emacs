
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


;;; Show the buffer when asking whether to reload.
(defun find-file-noselect (filename &optional nowarn rawfile wildcards)
  "Read file FILENAME into a buffer and return the buffer.
If a buffer exists visiting FILENAME, return that one, but
verify that the file has not changed since visited or saved.
The buffer is not selected, just returned to the caller.
Optional second arg NOWARN non-nil means suppress any warning messages.
Optional third arg RAWFILE non-nil means the file is read literally.
Optional fourth arg WILDCARDS non-nil means do wildcard processing
and visit all the matching files.  When wildcards are actually
used and expanded, return a list of buffers that are visiting
the various files."
  (setq filename
	(abbreviate-file-name
	 (expand-file-name filename)))
  (if (file-directory-p filename)
      (or (and find-file-run-dired
	       (run-hook-with-args-until-success
		'find-directory-functions
		(if find-file-visit-truename
		    (abbreviate-file-name (file-truename filename))
		  filename)))
	  (error "%s is a directory" filename))
    (if (and wildcards
	     find-file-wildcards
	     (not (string-match "\\`/:" filename))
	     (string-match "[[*?]" filename))
	(let ((files (condition-case nil
			 (file-expand-wildcards filename t)
		       (error (list filename))))
	      (find-file-wildcards nil))
	  (if (null files)
	      (find-file-noselect filename)
	    (mapcar #'find-file-noselect files)))
      (let* ((buf (get-file-buffer filename))
	     (truename (abbreviate-file-name (file-truename filename)))
	     (attributes (file-attributes truename))
	     (number (nthcdr 10 attributes))
	     ;; Find any buffer for a file which has same truename.
	     (other (and (not buf) (find-buffer-visiting filename))))
	;; Let user know if there is a buffer with the same truename.
	(if other
	    (progn
	      (or nowarn
		  find-file-suppress-same-file-warnings
		  (string-equal filename (buffer-file-name other))
		  (message "%s and %s are the same file"
			   filename (buffer-file-name other)))
	      ;; Optionally also find that buffer.
	      (if (or find-file-existing-other-name find-file-visit-truename)
		  (setq buf other))))
	;; Check to see if the file looks uncommonly large.
	(when (not (or buf nowarn))
	;;
	  (abort-if-file-too-large (nth 7 attributes) "open" filename))
	(if buf
	    ;; We are using an existing buffer.
	    (let (nonexistent)
	      (or nowarn
		  (verify-visited-file-modtime buf)
		  (cond ((not (file-exists-p filename))
			 (setq nonexistent t)
			 (message "File %s no longer exists!" filename))
			;; Certain files should be reverted automatically
			;; if they have changed on disk and not in the buffer.
			((and (not (buffer-modified-p buf))
			      (let ((tail revert-without-query)
				    (found nil))
				(while tail
				  (if (string-match (car tail) filename)
				      (setq found t))
				  (setq tail (cdr tail)))
				found))
			 (with-current-buffer buf
			   (message "Reverting file %s..." filename)
			   (revert-buffer t t)
			   (message "Reverting file %s...done" filename)))
			((progn
			   (display-buffer buf)
			   (yes-or-no-p
			    (if (string= (file-name-nondirectory filename)
					 (buffer-name buf))
				(format
				 (if (buffer-modified-p buf)
				     "File %s changed on disk.  Discard your edits? "
				   "File %s changed on disk.  Reread from disk? ")
				 (file-name-nondirectory filename))
			      (format
			       (if (buffer-modified-p buf)
				   "File %s changed on disk.  Discard your edits in %s? "
				 "File %s changed on disk.  Reread from disk into %s? ")
			       (file-name-nondirectory filename)
			       (buffer-name buf)))))
			 (with-current-buffer buf
			   (revert-buffer t t)))))
	      (with-current-buffer buf

		;; Check if a formerly read-only file has become
		;; writable and vice versa, but if the buffer agrees
		;; with the new state of the file, that is ok too.
		(let ((read-only (not (file-writable-p buffer-file-name))))
		  (unless (or nonexistent
			      (eq read-only buffer-file-read-only)
			      (eq read-only buffer-read-only))
		    (when (or nowarn
			      (let ((question
				     (format "File %s is %s on disk.  Change buffer mode? "
					     buffer-file-name
					     (if read-only "read-only" "writable"))))
				(y-or-n-p question)))
		      (setq buffer-read-only read-only)))
		  (setq buffer-file-read-only read-only))

		(when (and (not (eq (not (null rawfile))
				    (not (null find-file-literally))))
			   (not nonexistent)
			   ;; It is confusing to ask whether to visit
			   ;; non-literally if they have the file in
			   ;; hexl-mode.
			   (not (eq major-mode 'hexl-mode)))
		  (if (buffer-modified-p)
		      (if (y-or-n-p
			   (format
			    (if rawfile
				"The file %s is already visited normally,
and you have edited the buffer.  Now you have asked to visit it literally,
meaning no coding system handling, format conversion, or local variables.
Emacs can only visit a file in one way at a time.

Do you want to save the file, and visit it literally instead? "
				"The file %s is already visited literally,
meaning no coding system handling, format conversion, or local variables.
You have edited the buffer.  Now you have asked to visit the file normally,
but Emacs can only visit a file in one way at a time.

Do you want to save the file, and visit it normally instead? ")
			    (file-name-nondirectory filename)))
			  (progn
			    (save-buffer)
			    (find-file-noselect-1 buf filename nowarn
						  rawfile truename number))
			(if (y-or-n-p
			     (format
			      (if rawfile
				  "\
Do you want to discard your changes, and visit the file literally now? "
				"\
Do you want to discard your changes, and visit the file normally now? ")))
			    (find-file-noselect-1 buf filename nowarn
						  rawfile truename number)
			  (error (if rawfile "File already visited non-literally"
				   "File already visited literally"))))
		    (if (y-or-n-p
			 (format
			  (if rawfile
			      "The file %s is already visited normally.
You have asked to visit it literally,
meaning no coding system decoding, format conversion, or local variables.
But Emacs can only visit a file in one way at a time.

Do you want to revisit the file literally now? "
			    "The file %s is already visited literally,
meaning no coding system decoding, format conversion, or local variables.
You have asked to visit it normally,
but Emacs can only visit a file in one way at a time.

Do you want to revisit the file normally now? ")
			  (file-name-nondirectory filename)))
			(find-file-noselect-1 buf filename nowarn
					      rawfile truename number)
		      (error (if rawfile "File already visited non-literally"
			       "File already visited literally"))))))
	      ;; Return the buffer we are using.
	      buf)
	  ;; Create a new buffer.
	  (setq buf (create-file-buffer filename))
	  ;; find-file-noselect-1 may use a different buffer.
	  (find-file-noselect-1 buf filename nowarn
				rawfile truename number))))))

(provide 'mmc-patches)
