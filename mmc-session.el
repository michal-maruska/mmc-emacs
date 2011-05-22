

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
	(save-excursion
	  ;; Read in the auto-save-list file.
	  (set-buffer buffer)
	  (erase-buffer)
	  (insert-file-contents file)
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
		  (forward-line 1)
		  (setq autofile
			(buffer-substring-no-properties
			 (point) (progn (end-of-line) (point))))
		  (forward-line 1)))
	      ;; Ignore a file if its auto-save file does not exist now.
	      ;; mmc: WRONG!
	      (if (and autofile (file-exists-p autofile))
		  (setq files (cons thisfile files))
		(add-to-list 'other-files thisfile))))
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

	  (if other-files
	      (if (y-or-n-p "open also the other --clean-- files? ")
		  (mapc
		   (lambda (file)
		     (find-file-noselect file t))
		   other-files))))
      (kill-buffer buffer))))

(provide 'mmc-session)