;;; use the patch from ~/diffs/emacs/files.el

(eval-when-compile
  ;; with-keymaps-switched macro
  (require 'mmc-minibuffer))

(require 'compile)                      ;grep
;; fixme: how to test if the GREP supports this...?
(setq grep-command "grep --directories=recurse --no-recurse-symlinks --exclude='*~' -i -n -e ")
(setq grep-program  (if emacs-22
                        "grep"
		      "grep --directories=recurse --exclude='*~' --exclude=semantic.cache -i "))

(require 'mmc-simple)
(setenv "GREP_OPTIONS"
	(delete-substring (or (getenv "GREP_OPTIONS") "")
			  "--color"))

(defvar ask-for-directory)
;;; M-m to signal that we want to specify some directory.
(defvar my-minibuffer-ask-for-directory (make-sparse-keymap) "")
(let ((map my-minibuffer-ask-for-directory))
  (set-keymap-parent map
                     minibuffer-local-map)
  (define-key map [(meta ?m)] ;"\C-j"
    (lambda ()
      (interactive)
      (setq ask-for-directory 't)
      (call-interactively 'exit-minibuffer)
      ;;(exit-reading-buffer 'get-filename-of-buffer nil)
      )))



(defmacro with-default-directory (directory &rest body)
  "eval BODY with cwd set to DIRECTORY. Restore the original default-directory upon
either local exit from BODY, or the successful termination."
  (let ((old-directory (make-symbol "old-directory")))
    `(let ((,old-directory default-directory))
       (unwind-protect
	   (progn
	     (set-default-directory ,directory)
	     ,@body)
	 ;; And guarantee, that things get back again.
	 (set-default-directory ,old-directory)))))


(defun my-grep (command-args directory)
  "With prefix,  the symbol under point is the default string to grep for.
When editing the Grep command line, \M-m invokes selection of directory where to run."
  (interactive
   (let ((ask-for-directory nil))

     (let (grep-default
	   (arg current-prefix-arg))
       (unless grep-command
         (grep-compute-defaults))
       (when arg
         (let ((tag-default
                (funcall (or find-tag-default-function
                             (get major-mode 'find-tag-default-function)
                             ;; We use grep-tag-default instead of
                             ;; find-tag-default, to avoid loading etags.


                             ;; pre CVS:
                             ;; 'grep-tag-default
                             'find-tag-default))))
           (setq grep-default (or (car grep-history) grep-command))
           ;; Replace the thing matching for with that around cursor
           (when (string-match "[^ ]+\\s +\\(-[^ ]+\\s +\\)*\\(\"[^\"]+\"\\|[^ ]+\\)\\(\\s-+\\S-+\\)?"
			       grep-default)
             (unless (or (match-beginning 3) (not (stringp buffer-file-name)))
               (setq grep-default (concat grep-default "*."
                                          (file-name-extension buffer-file-name))))
             (setq grep-default (replace-match (or tag-default "")
                                               t t grep-default 2)))))
       (list
        (with-keymaps-switched 'minibuffer-local-map my-minibuffer-ask-for-directory
	  (lambda ()
	    (read-from-minibuffer "Run grep (like this): "
				  (or grep-default grep-command)
				  nil nil 'grep-history)))
        (if ask-for-directory
            (read-file-name "directory")
          default-directory)))))
  ;;(exit-reading-buffer 'get-filename-of-buffer nil)
  (with-default-directory directory
     (grep command-args)))

(substitute-key-definition 'grep 'my-grep global-map)


(defvar compile-command "make -k" "")

;(setq compile-command "make -k")
(defconst compilation-read-command nil "")
;; (require 'compile)
;;(setq compilation-ask-about-save 't)
(eval-after-load 'compile
  '(progn
     (defvar compile-wo-saving nil
       "if 't do not save buffers (interactively) before compile")
     (setq compile-wo-saving 't)
     (defun compile (command)
       "Compile the program including the current buffer.  Default: run `make'.
Runs COMMAND, a shell command, in a separate process asynchronously
with output going to the buffer `*compilation*'.

You can then use the command \\[next-error] to find the next error message
and move to the source code that caused it.

Interactively, prompts for the command if `compilation-read-command' is
non-nil; otherwise uses `compile-command'.  With prefix arg, always prompts.

To run more than one compilation at once, start one and rename the
\`*compilation*' buffer to some other name with \\[rename-buffer].
Then start the next one.

The name used for the buffer is actually whatever is returned by
the function in `compilation-buffer-name-function', so you can set that
to a function that generates a unique name."
       (interactive
	(if (or compilation-read-command current-prefix-arg)
	    (list (read-from-minibuffer "Compile command: "
					compile-command nil nil
					'(compile-history . 1)))
	  (list compile-command)))
       (require 'compile)
       (setq compile-command command)
       (unless compile-wo-saving
	 (save-some-buffers (not compilation-ask-about-save) nil))
       (compile-internal compile-command "No more errors"))
     ))


(provide 'mmc-compile)
