;; fixme: autoload!

(require 'dired)

;(require 'background)
;; This is standard in xemacs!

;; started from http://www.gatago.com/gnu/emacs/help/16477675.html 
(defun dired-do-shell-command-in-background (files command)
  "In dired, do shell command in background on the file or directory named on this line."
  (interactive
   (let ((files (or
                (dired-get-marked-files)
                (list (dired-get-filename)))))
     (list files (dired-read-shell-command (concat "& on " "%s: ") nil files))))
  ;(apply 'call-process command nil (generate-new-buffer "*dired background*") 't files)
  (shell-command (concat command " "
                         (mapconcat 
                          'shell-quote-argument
                          files " ")
                         "&")
                 (generate-new-buffer "*dired background*")
                 't))

(add-hook 'dired-load-hook
  (function (lambda ()
              (load "dired-x")
              (define-key dired-mode-map "&" 'dired-do-shell-command-in-background))))

(setq dired-guess-shell-alist-user
      (list (list "\\.wav$" "snack")
            (list "\\.au$" "snack")
            (list "\\.pdf$" "acroread")
            (list "\\.doc$" "OOo" )
            (list "\\.xls$" "OOo")))


;;(eval-after-load
;;    "dired"
(unless running-xemacs
  (require 'dired-x))
(dired-omit-mode t)

;;; Browsing between:
(defun dired-substitute ()
  "find/dired the file on currrent line by substituting it (kill the current buffer)"
  (interactive)
  (let ((buffer (current-buffer)))
    (dired-find-file)
    (kill-buffer buffer)))

;; i would like to Advice and rebind !!!  copy and advice !!
(defun dired-up-directory-substitute (arg)
  ""
  (interactive "P")
  (let ((buffer (current-buffer)))
    (dired-up-directory arg)
    (kill-buffer buffer)))



(defun dired-do-cd (directory)
  "dired another DIRECTORY. (would be `dired-do-chdir')"
  (interactive  ;; "d")
   (list 
    (my-read-directory "cd to directory: " "" nil nil (dired-current-directory))))
  ;;(completing-read "cd: " dired-subdir-alist 'nil 't (try-completion "" dired-subdir-alist))
  (dired directory))



;;; Pruning:
(defvar dired-delete-directory-r nil "")

;; todo: revise for 21.1: started, but ...
(defun dired-do-prune (&optional arg)
  "rm -r all marked (or next ARG) files/dirs."
  (interactive "P")
  (save-window-excursion
    (let ((window (selected-window))
 	  new-buffer
	  new-window)
      (unwind-protect
	  (let ((dired-recursive-deletes 'top)
		(dired-delete-directory-r 't))
	    ;;(save-window-excursion
	    (dired-other-window (car (dired-get-marked-files)) "-laR")
	    (setq new-buffer (current-buffer)
		  new-window (selected-window))
	    (select-window window)
	    (dired-do-delete arg))
	;; These are called for sure:
	(if new-buffer (kill-buffer new-buffer))
	;;(if new-window (delete-window new-window))
	))))
;; (setq dired-recursive-deletes 't)

;;; `rename' ....
(defvar my-dired-default "" "")


(defvar dired-last-rename-name "" "")
(defvar dired-last-rename-target "" "")

(require 'mmc-simple)

(string-match "\\([^[:digit:]]+\\)" " 2 ")
(defun increment-integer-in-string (string)
  "return the given STRING with the first number incremented"
  (let ((scan-for-number-regexp "^\\(.*\\)\\([[:digit:]]+\\)\\([^[:digit:]]?.*\\)$"))
    (if (string-match scan-for-number-regexp string)
	(concat
	 (match-string 1 string)
	 (add-to-string (match-string 2 string) 1)
	 (match-string 3 string))
      string)))



;; fixme: 
(defun my-read-file-name (prompt &optional dir default must-match initial)
  ""
  (let ((my-prompt (if default
		       (format "%s (%s) " prompt default)
		     prompt)))
    (read-file-name my-prompt dir default must-match (or initial default))))

(defun mmc-read-file-name-dired (prompt &optional dir default must-match initial)
  "Read a file name for `cp',`mv' ... operation on marker"
  ;; What is a good default:
  (let ((new-name my-dired-default)
	new-target
	new-target-default
	;; analyze the last...
	(basename dired-last-rename-name)
	(target dired-last-rename-target)
	prefix suffix)
    ;; decompose the basename in:    prefix  N suffix
    (when (string-match (concat "^\\(.*\\)"
				(regexp-quote basename)
				"\\(.*\\)$")  target)
      (setq prefix (match-string 1 target)
	    suffix (match-string 2 target))
      (setq suffix (increment-integer-in-string suffix)
	    prefix (increment-integer-in-string prefix)))
    ;; apply to this:
    (setq new-target-default (concat prefix new-name suffix)
	  new-target (read-file-name prompt dir default must-match new-target-default)
	  dired-last-rename-name new-name
	  dired-last-rename-target (file-name-nondirectory new-target))
    new-target))



;;; overload: we want
;; 21 changed: files  arg -->  arg  rfn-list default
(defun dired-mark-read-file-name (prompt  dir op-symbol arg  rfn-list default)
  "insert `my-read-file-name'"
  (dired-mark-pop-up
   nil op-symbol rfn-list
   (if (and (= (length rfn-list) 1) 't)
       (progn (setq my-dired-default (car rfn-list))
	      (function mmc-read-file-name-dired))
     (function read-file-name))
   (format prompt (dired-mark-prompt arg rfn-list)) dir))




;;; `Auto-view'
(define-key dired-mode-map [(control ?c) (control ?a)] 'dired-autoview-mode)

(defun dired-current-directory-in-other-window ()
  ""
  (interactive)
  (when dired-autoview-mode
    ;; (message "dired")
    ;; if the current file is a directory
    ;;(condition-case
    (let ((dir (condition-case nil
		   (dired-get-filename nil 't);; Good
		 '(error . (message "error in hook")))))
      (if (and dir (file-directory-p dir))
	  (save-selected-window
	    (bury-buffer (dired-other-window dir)))
	(save-selected-window
	  (bury-buffer (find-file-other-window  dir)))))))

(defvar dired-autoview-mode nil "")
;; (setq dired-autoview-mode nil)
(defun dired-autoview-mode (arg)
  ""
  (interactive "P")
  (let ((hook-function (function dired-current-directory-in-other-window)))
    (add-hook 'post-command-hook hook-function 't)
    ;;(make-local-variable 'post-command-hook)
    (set (make-local-variable 'dired-autoview-mode)
	 (not arg))))
;;(remove-hook 'post-command-hook hook-function 't)


;; delete it from parent dir ??



;;; 
(defun dired-create-directory-if-necessary (dir)
  "i want to Rename/Move into an inexistent directory and create it implicitely"
  ;; If we move to a directory:  ---more files
  (cond
   ((and (not (file-exists-p dir))
	 ;; This is a `TERRIBLE' HACK:  we use a local variable in the outer
	 ;; procedure
	 (or (> fn-count 1)
	     (string= (substring dir (1- (length dir))) "/")))
    (message "Creating the dir: %s" dir)
    (dired-create-directory dir)
    dir)
   ((file-exists-p dir)
    ;; we are either  renaming dir, or moving  file(s) to existant dir:
    ;; if we overwrite file ???
    dir)
   ('t
    ;; Return nil to say it must be created:
    nil)))
;; else
;; If we do rename: 
;     (if (and (file-directory-p (car fn-list))
; 	     (> fn-count 1))
; 	nil
;       dir)))


(defun delete-subtree (dir)
  ""
  (shell-command (concat "rm -r " dir)))


(defun dired-eldoc ()
  ""
  (make-local-variable 'eldoc-documentation-function)
  (setq eldoc-documentation-function 'dired-show-description)
  (eldoc-mode))

;;(add-hook 'post-command-idle-hook 'dired-show-description)
;; pre-idle-hook
;; post-command-hook


;;; eldoc && dired
(defun dired-show-description ()
  "Get the description of the file from the MANIFEST file (if exists)"
  (interactive)
  (cond
   ((eq major-mode 'dired-mode)
    (let ((message (current-message)))
      (shell-command
       (format 
	"if [ -e MANIFEST ]; then grep  %s MANIFEST|head --lines=1; fi" 
	(file-name-nondirectory (dired-get-filename)))
       (get-buffer-create " eldoc-shell"))
      (message message)
					;(shell-command (format "grep --count 1 Description %s" (dired-get-filename)))
      ))))


;; (delq eldoc-timer timer-idle-list)


;; ugly kludge ---


;; Xemacs has it ?

(defun list-timers ()
  ""
  (interactive)
  (with-output-to-temp-buffer "*timers*"
  (mapcar 
   (lambda (timer)
     (print				;(timer-relative-time timer)
      (aref timer 5) 
      )) timer-idle-list    ;timer-list
    )) )





(defun dired-possible-create (dirname)
  ""
  (interactive  "Fdirname: ")
  (unless (file-exists-p dirname)
    (dired-create-directory dirname)
    ;; (make-directory dirname)
    )
  (dired dirname))



(require 'mmc-read-dir)


;;;  10 Jul 01: after 2 responses on dired/efs mail-list: 
(defun directory-of-buffer (buffer)
  "Given BUFFER, return its `default-directory' (in dired ??)"
  (with-current-buffer buffer ;;save-excursion
    (if (eq major-mode 'dired-mode)
	dired-directory
      default-directory)))


(when nil
  (directory-of-buffer
   (car (buffers-in-mode 'dired-mode))))


;; prepare for the feature:
;; fixme:  should be enabled only when used!
(setq enable-recursive-minibuffers 't)

;; (lookup-key minibuffer-local-completion-map "/")
(let ((map minibuffer-local-completion-map))
  (define-key map  [(meta ?i)] 'expand-directory-of-dired-buffer)
  (define-key map [(control ?o)] 'expand-directory-of-dired-buffer))




(defun expand-directory-of-dired-buffer ()
  "called from minibuffer, while `read-file-name' upon \\<minibuffer-local-completion-map>\\[expand-directory-of-dired-buffer], enter recursive:
get a name of (an open) dired buffer. taking the basename of the current path as ..
\(exit recursion) and substitute its directory."
  (interactive)
  (let* ((path (buffer-string))
	 (buffer-name (file-name-nondirectory path))
	 (buffer-list
	  (mapcar
	   (lambda (item)
	     (buffer-name item))
	   (buffers-in-mode 'dired-mode))))
    ;;complete-on-the name of -..
    (unless (member buffer-name buffer-list)
      ;; default:
      (setq buffer-name (my-completing-read "dired-buffer: " buffer-list nil 't buffer-name)))
    (delete-minibuffer-contents) ;;(erase-buffer)
    (insert (directory-of-buffer buffer-name))))



;;; Movements

(defconst dired-re-file "^. [0-9 	]*[^d][-r][-w][^:]" "")
(defun dired-next-file (arg &optional opoint)
  "Goto ARG'th next directory file line."
  (interactive "p")
  (or opoint (setq opoint (point)))
  (if (if (> arg 0)
	  (re-search-forward dired-re-file nil t arg)
	(beginning-of-line)
	(re-search-backward dired-re-file nil t (- arg)))
      (dired-move-to-filename)		; user may type `i' or `f'
    (goto-char opoint)
    ;;(error "No more subdirectories")
    ))


(defun dired-prev-file (arg)
  "Goto ARG'th previous directory file line."
  (interactive "p")
  (dired-next-file (- arg)))

(defun my-dired-chgrp-chmod (arg)
  ""
  ;; non sense
  (dired-do-chxxx "Group" "chgrp" 'chgrp arg)
  )

(let ((map dired-mode-map))
  (setq dired-listing-switches "-alhB");; -h B at the end. !!!!!
  ;;      (unless running-xemacs
  ;;        (define-key dired-mode-map [ ?b ] 'quit-window)
  ;;        (define-key dired-mode-map [ ?q ] (lambda () (interactive) (kill-buffer (current-buffer))))
  ;;        )
  (define-key map [ ?b ] 'quit-window)
  (define-key map [ ?q ] (lambda () (interactive) (kill-buffer (current-buffer))))
  (define-key map [delete] 'dired-unmark-backward)
  (define-key map [backspace] 'dired-unmark-backward)

  
  (define-key map "c" 'dired-do-cd)
  (define-key map "j" 'dired);; -at-point
  (define-key map "w" 'dired-substitute);; -at-point
  (define-key map "‚½" 'dired-up-directory-substitute);; -at-point
  (define-key map "\C-^" 'dired-up-directory-substitute)
  
  
  (define-key map "+" 'dired-possible-create) ;
  (define-key map "'" 'dired-do-prune) ;
  (define-key map "@" 'dired-create-directory)
  (define-key map "
" 'dired-advertised-find-file)

  (define-key map "N" 'my-dired-chgrp-chmod)
  
  (define-key map "{" 'dired-prev-file)
  (define-key map "}" 'dired-next-file)
  (define-key map [(control ?k)] 'dired-kill-line)

  (define-key map ":" 'dired-cvs-repository)


  (define-key map ";" 'dired-create-symlink)

  ;; too late?
  (add-hook 'dired-mode-hook 'dired-eldoc))





;;; Font lock:
(unless running-xemacs
  (aput 'dired-font-lock-keywords
	dired-re-exe
	'(".+" (dired-move-to-filename) nil (0 'font-lock-important)))
)
;; font-lock-lemma-face



;;; CVS
(defun cvs-repository-of (dir)
  ""
  (let ((string
	 (shell-command-to-string
	  (format "cd %s && dirname $(cvs admin . | grep RCS |head -1| sed -e 's/RCS file: //')" dir))))
    (substring string 0 (1- (length string)))))
;; (cvs-repository-of "~/perl/foto")

(defun  dired-cvs-repository (dir)
  ""
  (interactive (list (dired-current-directory)))
  (dired (cvs-repository-of dir)))


;;; Dired buffers
(defun dired-prune-invalid-buffers ()
  "kill dired buffers which display deleted directories"
  (interactive)
  (let ((buffers (buffers-in-mode 'dired-mode)))
    (save-excursion
      (mapcar
       (lambda (item)
	 (set-buffer item)
	 (unless (file-exists-p dired-directory)
	   (kill-buffer item)))
       buffers))))

(defvar find-file-dired-history (make-symbol "find-file-dired-history") "")

(defun find-file-dired (directory name)
  "find the filenames in the subtree below DIRECTORY, which contain the NAME (as shell pattern)."
  (interactive (list (read-file-name "Run find in directory: " nil "" t)
		     (read-string "filename: " "" find-file-dired-history)))
  (find-dired directory (format "-name  '*%s*'" name)))



(define-key my-global-keymap "f" 'find-file-dired)

(defun dired-directory-of (buffer)
  "return the directory, that we dir-edit in BUFFER?"
  (with-current-buffer buffer
    (dired-current-directory)))





;;; external processes:

(defvar dired-command-args nil
  "Last arguments given to `find' by \\[find-dired].")

;; History of find-args values entered in the minibuffer.
(defvar dired-command-args-history nil)

(defun do-dired (dir command-args)
  "Run COMMAND and go into Dired mode on a buffer of the output.
The command run (after changing into DIR) is

except that the variable `find-ls-option' specifies what to use
as the final argument."
  (interactive (list (read-file-name "Run in directory: " nil "" t)
		     (read-string "command to run (with args): " dired-command-args-history
				  '(dired-command-args-history . 1))))
  (let ((dired-buffers dired-buffers)
	(buffer-name "*Find*"))
    
    ;; Expand DIR ("" means default-directory), and make sure it has a
    ;; trailing slash.
    (setq dir (abbreviate-file-name
	       (file-name-as-directory (expand-file-name dir))))
    ;; Check that it's really a directory.
    (or (file-directory-p dir)
	(error "find-dired needs a directory: %s" dir))
    (switch-to-buffer (get-buffer-create buffer-name))

    ;; See if there's still a `find' running, and offer to kill
    ;; it first, if it is.
    (let ((find (get-buffer-process (current-buffer))))
      (when find
	(if (or (not (eq (process-status find) 'run))
		(yes-or-no-p "A `find' process is running; kill it? "))
	    (condition-case nil
		(progn
		  (interrupt-process find)
		  (sit-for 1)
		  (delete-process find))
	      (error nil))
	  (error "Cannot have two processes in `%s' at once" (buffer-name)))))
      
    (widen)
    (kill-all-local-variables)
    (setq buffer-read-only nil)
    (erase-buffer)
    (setq default-directory dir
	  dired-command-args command-args		; save for next interactive call
	  )
    ;; The next statement will bomb in classic dired (no optional arg allowed)
    (dired-mode dir (cdr find-ls-option))
    ;; This really should rerun the find command, but I don't
    ;; have time for that.
    (use-local-map (append (make-sparse-keymap) (current-local-map)))
    (define-key (current-local-map) "g" 'undefined)
    ;; Set subdir-alist so that Tree Dired will work:
    (if (fboundp 'dired-simple-subdir-alist)
	;; will work even with nested dired format (dired-nstd.el,v 1.15
	;; and later)
	(dired-simple-subdir-alist)
      ;; else we have an ancient tree dired (or classic dired, where
      ;; this does no harm) 
      (set (make-local-variable 'dired-subdir-alist)
	   (list (cons default-directory (point-min-marker)))))
    (setq buffer-read-only nil)
    ;; Subdir headlerline must come first because the first marker in
    ;; subdir-alist points there.
    (insert "  " dir ":\n")
    ;; Make second line a ``find'' line in analogy to the ``total'' or
    ;; ``wildcard'' line. 
    (insert "  " command-args "\n")
    ;; Start the find process.
    (let ((proc (start-process-shell-command
		 find-dired-find-program (current-buffer) command-args)))
      (set-process-filter proc (function find-dired-filter))
      (set-process-sentinel proc (function find-dired-sentinel))
      ;; Initialize the process marker; it is used by the filter.
      (move-marker (process-mark proc) 1 (current-buffer)))
    (setq mode-line-process '(":%s"))))






(defun basename (filename)
  "get the last path component"
  (let ((test (file-name-nondirectory filename)))
    (if (string= test "")
        (file-name-nondirectory
         (substring filename 0 (- (length filename) 1)))
      test)))
; (basename "/p/gauche-gtk-0.3.1/work/Gauche-gtk-0.3.1/")

;; 
(defun dired-create-symlink (prefix filename &optional dir)
  "ask for FILENAME, and make a symlink from CWD to FILENAME. (prefix -> hard)"
  (interactive
   (list
    current-prefix-arg
    (read-file-name (format "(existing) destination of %s link: " (if current-prefix-arg "hard" "symbolic")))))
                                        ; (dired-do-symlink
;  (unless dir (setq dir
;                    (file-name-in-directory (dired-current-directory) (basename filename))))
  (let ((destination (basename filename)))
    (if prefix
        (add-name-to-file filename destination)
      (make-symbolic-link filename destination)
      (revert-buffer)))
  ) ;; move to the created file ??

(defun dired-edit-symlink (symlink &optional new-destination)
  ""
  (interactive (list (dired-get-filename)))
  (let ((destination (file-symlink-p symlink)))
    (when destination
      (setq new-destination (read-file-name "new symlink destination: " destination destination))
      (delete-file symlink)
      (make-symbolic-link new-destination symlink)
      (revert-buffer))))

(define-key dired-mode-map "e" 'dired-edit-symlink)


(provide 'mmc-dired)




