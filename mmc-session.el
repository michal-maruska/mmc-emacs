(defun maybe-open-rest (other-files)
  ""
  ;; (message "maybe-open-rest %s" other-files)
  (if other-files
      (if (y-or-n-p "open also the other --clean-- files? ")
	  (mapc
	   (lambda (file)
	     (find-file-noselect file t))
	   other-files))))

(defun decode-all-filenames ()
  "return (files . other-files).
Files is a list of those, which need recovery. other-files are the rest"
  (let (files other-files)
    ;; Loop thru the text of that file
    ;; and get out the names of the files to recover.
    (while (not (eobp))
      (let (thisfile autofile)
	(if (eolp)
	    ;; This is a pair of lines for a non-file-visiting buffer.
	    ;; Get the auto-save file name and manufacture
	    ;; a "visited file name" from that.
	    (progn
	      (forward-line 1)
	      ;; If there is no auto-save file name, the
	      ;; auto-save-list file is probably corrupted.
	      (unless (eolp)
		(setq autofile
		      (buffer-substring-no-properties
		       (point)
		       (line-end-position)))
		(setq thisfile
		      (expand-file-name
		       (substring
			(file-name-nondirectory autofile)
			1 -1)
		       (file-name-directory autofile))))
	      (forward-line 1))
	  ;; This pair of lines is a file-visiting
	  ;; buffer.  Use the visited file name.
	  (progn
	    (setq thisfile
		  (buffer-substring-no-properties
		   (point) (progn (end-of-line) (point))))
	    ;; (message "possibly buffer to open %d %d %s: %s"
	    ;; 	     (point) (progn (beginning-of-line) (point))
	    ;; 	     (buffer-substring-no-properties
	    ;; 	      (progn (beginning-of-line) (point)) (point) )
	    ;; 	     thisfile)
	    (forward-line 1)
	    (setq autofile
		  (buffer-substring-no-properties
		   (point) (progn (end-of-line) (point))))
	    (forward-line 1)))
	;; Ignore a file if its auto-save file does not exist now.
	;; mmc: WRONG!
	(if (and autofile (file-exists-p autofile))
	    (add-to-list 'files thisfile)
	  ;;(setq files (cons thisfile files))

	  ;; (message "possibly buffer to open %s -- %s" thisfile autofile)
	  (if (stringp thisfile)
	      (add-to-list 'other-files thisfile)))))
    (cons files
	  other-files)))

;; open ALL the files.
(defun recover-session-finish (&optional force)
  "Choose one saved session to recover auto-save files from.
This command is used in the special Dired buffer created by
\\[recover-session]."
  (interactive "p")
  ;; Get the name of the session file to recover from.
  (let ((file (dired-get-filename))
	files
	other-files
	(buffer (get-buffer-create " *recover*")))
    (dired-unmark 1)
    (dired-do-flagged-delete t)
    (unwind-protect
	(with-current-buffer buffer
	  ;; Read in the auto-save-list file.
	  (erase-buffer)
	  (insert-file-contents file)
	  (let ((res (decode-all-filenames)))
	    (setq files (car res)
		  other-files (cdr res))
	    (setq files (nreverse files))
	    ;; The file contains a pair of line for each auto-saved buffer.
	    ;; The first line of the pair contains the visited file name
	    ;; or is empty if the buffer was not visiting a file.
	    ;; The second line is the auto-save file name.
	    (if files
		(map-y-or-n-p  "Recover %s? "
			       (lambda (file)
				 (condition-case nil
				     (save-excursion (recover-file file))
				   (error
				    "Failed to recover `%s'" file)))
			       files
			       '("file" "files" "recover"))
	      (message "No files can be recovered from this session now"))

	    (maybe-open-rest other-files)))
      (kill-buffer buffer))))

;;
(defun recover-file (file &optional force)
  "Visit file FILE, but get contents from its last auto-save file."
  ;; Actually putting the file name in the minibuffer should be used
  ;; only rarely.
  ;; Not just because users often use the default.
  (interactive "FRecover file: ")
  (setq file (expand-file-name file))
  (if (auto-save-file-name-p (file-name-nondirectory file))
      (error "%s is an auto-save file" (abbreviate-file-name file)))
  (let ((file-name (let ((buffer-file-name file))
		     (make-auto-save-file-name))))
    (cond ((if (file-exists-p file)
	       (not (file-newer-than-file-p file-name file))
	     (not (file-exists-p file-name)))
	   (error "Auto-save file %s not current"
		  (abbreviate-file-name file-name)))
	  ((save-window-excursion
	     (with-output-to-temp-buffer "*Directory*"
	       (buffer-disable-undo standard-output)
	       (save-excursion
		 (let ((switches dired-listing-switches))
		   (if (file-symlink-p file)
		       (setq switches (concat switches "L")))
		   (set-buffer standard-output)
		   ;; Use insert-directory-safely, not insert-directory,
		   ;; because these files might not exist.  In particular,
		   ;; FILE might not exist if the auto-save file was for
		   ;; a buffer that didn't visit a file, such as "*mail*".
		   ;; The code in v20.x called `ls' directly, so we need
		   ;; to emulate what `ls' did in that case.
		   (insert-directory-safely file switches)
		   (insert-directory-safely file-name switches))))
	     ;; mmc:
	     (or force
		 (yes-or-no-p (format "Recover auto save file %s? " file-name))))
	   (switch-to-buffer (find-file-noselect file t))
	   (let ((inhibit-read-only t)
		 ;; Keep the current buffer-file-coding-system.
		 (coding-system buffer-file-coding-system)
		 ;; Auto-saved file should be read with special coding.
		 (coding-system-for-read 'auto-save-coding))
	     (erase-buffer)
	     (insert-file-contents file-name nil)
	     (set-buffer-file-coding-system coding-system))
	   (after-find-file nil nil t))
	  (t (error "Recover-file cancelled")))))

(provide 'mmc-session)
