;;; mmc-narrow.el --- Simple narrowing (away) some annoying sections: Buffer-variables and  header.
;; Copyright (C) 1999 by Maruska

;; Author: Michal Maruska <mmc@linux3.maruska.tin.it>
;; Keywords: narrow, file variables

;;; Commentary:

;; 

;;; Code:

(defvar ctl-x-n-map (lookup-key global-map "\C-xn")
  "i really expected this pretty standard, why not?")

(provide 'mmc-narrow)

(defvar my-narrow-end (concat "\\" "endinput")
  "regexp which indicates the beginning of lo-cal (file) variables section") ;I often use TeX

(defvar  my-narrow-end-other (concat "Local " "Variables: ")
  "an alternative to `my-narrow-end'")

(defun narrow-to-local-vars ()
  "Narrow to the real content of the file; i.e. cut off Emacs-related administration, \\
uses the vars: `my-narrow-end' and `my-narrow-end-other'"
  (interactive)
  (save-excursion
    (goto-char (point-max))
    (if (or 
	 (search-backward my-narrow-end (- (point-max) 3000) t)
	 (search-backward-regexp my-narrow-end-other (- (point-max) 3000) t))
	(narrow-to-region (point-min) (progn (beginning-of-line) (point)))
      t)
    )
  )

(global-set-key [(control x) (n) (m)] 'narrow-to-local-vars)

(provide 'my-narrow)

;;; my-narrow.el ends here
