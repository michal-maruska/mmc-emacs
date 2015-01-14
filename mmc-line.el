
;; edit filename:XX where XX is line number.
;; taken from http://stackoverflow.com/questions/3139970/open-a-file-at-line-with-filenameline-syntax

;; Open files and go places like we see from error messages, ie: path:line:col
;; todo: "make `find-file-line-number' work for emacsclient as well"
;; todo: "make `find-file-line-number' check if the file exists"
;; mmc: this needs to write :20 in the minibuffer!
(defadvice find-file (around find-file-line-number
                             (path &optional wildcards)
                             activate)
  "Turn files like file.js:14:10 into file.js and going to line 14, col 10."
  (save-match-data
    (let* ((match (string-match "^\\(.*?\\):\\([0-9]+\\):?\\([0-9]*\\)$" path))
           (line-no (and match
                         (match-string 2 path)
                         (string-to-number (match-string 2 path))))
           (col-no (and match
                        (match-string 3 path)
                        (string-to-number (match-string 3 path))))
           (path (if match (match-string 1 path) path)))
      ad-do-it
      (when line-no
        ;; goto-line is for interactive use
        (goto-char (point-min))
        (forward-line (1- line-no))
        (when (> col-no 0)
          (forward-char (1- col-no)))))))



;; I want ffap to work with it!
;; find file at point, jump to line no.
;; ====================================
(require 'ffap)

;; todo: make it work even when the point is NOT over the filename.
;; ie. after the dot: ffff:.XX
(defun find-file-at-point-with-line (&optional filename)
  "Opens file at point and moves point to line specified next to file name."
  (interactive)
  (let* ((filename (or filename
		       (if current-prefix-arg (ffap-prompter)
			 (or (ffap-guesser) (ffap-prompter)))))
         (line-number
          (and (or (looking-at ".* line \\(\[0-9\]+\\)")
                   (looking-at "[^:]*:\\(\[0-9\]+\\)"))
               (string-to-number (match-string-no-properties 1))))
         (column-number
          (or
           (and (looking-at "[^:]*:\[0-9\]+:\\(\[0-9\]+\\)")
                (string-to-number (match-string-no-properties 1)))
           (let 'column-number 0))))
    (message "%s --> %s:%s" filename line-number column-number)
    (cond ((ffap-url-p filename)
           (let (current-prefix-arg)
             (funcall ffap-url-fetcher filename)))
          ((and line-number
                (file-exists-p filename))
           (progn (find-file-other-window filename)
                  ;; goto-line is for interactive use
                  (goto-char (point-min))
                  (forward-line (1- line-number))
                  (forward-char column-number)))
          ((and ffap-pass-wildcards-to-dired
                ffap-dired-wildcards
                (string-match ffap-dired-wildcards filename))
           (funcall ffap-directory-finder filename))
          ((and ffap-dired-wildcards
                (string-match ffap-dired-wildcards filename)
                find-file-wildcards
                ;; Check if it's find-file that supports wildcards arg
                (memq ffap-file-finder '(find-file find-alternate-file)))
           (funcall ffap-file-finder (expand-file-name filename) t))
          ((or (not ffap-newfile-prompt)
               (file-exists-p filename)
               (y-or-n-p "File does not exist, create buffer? "))
           (funcall ffap-file-finder
                    ;; expand-file-name fixes "~/~/.emacs" bug sent by CHUCKR.
                    (expand-file-name filename)))
          ;; User does not want to find a non-existent file:
          ((signal 'file-error (list "Opening file buffer"
                                     "no such file or directory"
                                     filename))))))

(define-key global-map (kbd "C-x C-f") 'find-file-at-point-with-line)
;; replace in keymaps
;; ~/.emacs:14

(defadvice server-visit-files (before parse-numbers-in-lines
				      (files proc &optional nowait) activate)
  "looks for filenames like file:line or file:line:position and reparses
name in such manner that position in file"
  (ad-set-arg 0
     (mapcar
      (lambda (fn)
	(let ((name (car fn)))
	  (if (string-match "^\\(.*?\\):\\([0-9]+\\)\\(?::\\([0-9]+\\)\\)?$"
			    name)
	      (cons
	       (match-string 1 name)
	       (cons (string-to-number (match-string 2 name))
		     (string-to-number (or (match-string 3 name) ""))))
	    fn)))
      files)))


(provide 'mmc-line)
