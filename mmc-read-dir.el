
;;; read a directory name with completion

;; 17 Jun 01
;; I was quite surprised, there is no such function.
;; after a month of using zsh(1) i feel unbearable having to distinguish by eye
;; in emacs between files and directories.


(defun subdirs-in-dir (dir &optional slash)
  "Get the list of names of subdirs in the DIR. Uses find(1)"
  (save-excursion
    (let (subdirs
	  window
	  (temp-buf (generate-new-buffer "*subdirs*")))
      (set-buffer temp-buf)
      (insert
       (shell-command-to-string
	(concat "find " dir " -type d -printf \"%f" 
		(if slash "/" "")
		"\\n\" -maxdepth 1 -mindepth 1")))
      ;; we have to avoid the last empty line!
      (map-lines (point-min) (point-max)
		 (lambda (end)
		   (setq subdirs (cons (line-string) subdirs))))
      (if (setq window (get-buffer-window temp-buf))
	  (delete-window window))
      (kill-buffer temp-buf)
    subdirs)))

;; (subdirs-in-dir "/usr/share/emacs" 't)


(defun my-read-directory-completion (string predicate op)
  "This is the completion engine for `my-read-directory' "
  (let* ((directory (file-name-directory string))
	 (completions (subdirs-in-dir directory 't))
	 (basename (file-name-nondirectory string))
	 result)
    ;;    (try-completion)
    ;;    (all-completions)
    (setq 
     result
     (cond ((eq op 'lambda)
	    ;; exact 
	    (or (string= basename "")
		(member basename completions)))
	   ((eq op 't)
	    (all-completions basename (alist-from-list completions))
	    ;; 
	    )
	   ('t
	    (try-completion basename (alist-from-list completions) predicate))))
    (cond
     ((listp result)
      (setq result
	    (mapcar
	     (lambda (item)
	       (concat directory item))
	     result)))
     ((stringp result)
      (setq result (concat directory result))))	;  (if (member result completions) "/")
    result))

(when nil
  (read-file-name "")
  (my-read-directory-completion "/usr/loc" nil nil)
  (my-read-directory "dir: " "/" nil 't "/internet/gn"))

(defun my-read-directory (prompt &optional dir default-name mustmatch initial)
  ""
  (completing-read prompt 'my-read-directory-completion nil mustmatch initial))


(provide 'mmc-read-dir)
