
;; http://www.emacswiki.org/cgi-bin/wiki/EdiffMode

(require 'ediff)
;;; config:
(setq ediff-window-setup-function ;; default:
      'ediff-setup-windows-multiframe
      ;ediff-setup-windows-plain
      )

;(setq emerge-diff-options "--ignore-all-space")
;; ignore space
(setq ediff-diff-options "-w")
(setq ediff-filtering-regexp-history '("[^~]$"))
(setq ediff-auto-refine-limit 50000)


(eval-after-load "ediff"
  '(progn
     (setcdr
      (car ediff-control-frame-parameters) nil)

     (setq
      ediff-control-frame-parameters
      (aput
       'ediff-control-frame-parameters 'auto-raise ))))




;;; Description:
;; Sometimes I must revert the buffer, but don't know
;; whether I made some changes: (lose synchronization with my co-workers)


(defcustom my-ediff-dir "/tmp/emacs/ediff/"
  "Dir where i store temporary copy of the buffer, when ... to the file"
  :group 'ediff
  :type 'filename);; directory

;; But w/ cvs !!
(defun my-ediff (buffer prefix)
  "diff the CURRENT buffer with its image on the disk"
  (interactive "bEdiff buffer with its file: \np")
  (condition-case nil
      (with-current-buffer buffer
	(make-directory my-ediff-dir 't)
	(let ((file (buffer-file-name (get-buffer-create buffer)))
	      (temp-file (make-temp-name (concat my-ediff-dir "/"))))
	  (if (not prefix)
	      (write-file temp-file)
	    (shell-command (format "mv %s %s" file temp-file))
	    (write-file file))
	  (ediff temp-file file)))
    (error . nil)))



;; I want the stuff accessible from Global keymap:
(defconst ediff-keymap (make-sparse-keymap) "")

(let ((map ediff-keymap))
  (define-key map "d" 'edirs)
  (define-key map "b" 'my-ediff-buffers)
  ;(define-key map "b" 'ebuffers)
  (define-key map "f" 'ediff))

(global-set-key [(control ?E)] 'ediff-map)


;(frame-first-window
(defun my-ediff-buffers ();buffer-A buffer-B &optional startup-hooks job-name)
  "Run Ediff on a pair of buffers, BUFFER-A and BUFFER-B, which are in the 2 windows of the current frame."
  (interactive)
  (if (= (length (window-list)) 2)
      (let* ((W1 (selected-window))
             (W2 (other-window 1))
             (B1 (window-buffer  W1))
             (B2 (window-buffer  W2)))
        (ediff-buffers B1 B2))
    (call-interactively 'ediff-buffers)))



;;; ---------- patch -------------------------

;; [06 gen 05]   i want to start it w/ 2 `dired' buffers/windows in the frame.
;; And the prompt should be aware of it.

;; Overriding standard function:
(defun ediff-directories (dir1 dir2 regexp)
  "Run Ediff on a pair of directories, DIR1 and DIR2, comparing files that have
the same name in both.  The third argument, REGEXP, is a regular expression
that can be used to filter out certain file names."
  (interactive
   (let ((dir-A
	  default-directory
                                        ;(ediff-get-default-directory-name)
	  )
	 (dir-B
	  ;; realign buffers so that two visible bufs will be
	  ;; at the top
	  (save-window-excursion
	    (other-window 1)
	    default-directory		;(ediff-get-default-directory-name)
	    ))
	 f)
     (list (setq f (ediff-read-file-name "Directory A to compare:" dir-A nil))
	   (ediff-read-file-name "Directory B to compare:"
				 ;; '(if ediff-use-last-dir
				 ;; 				     ediff-last-dir-B
				 ;;                                     (ediff-strip-last-dir f))
				 dir-B
				 nil)
	   (read-string "Filter through regular expression: "
			nil 'ediff-filtering-regexp-history)
	   )))
  (ediff-directories-internal
   dir1 dir2 nil regexp 'ediff-files 'ediff-directories))

;;; --------------end patch -------------------



(defconst ediff-x-roots
  '(
    ""; "/x/cvs/xfree/xc/"
    ;; "/linux/13/x/xfree86/xc/";; programs/Xserver/


    ;"/linux/13/x/xfree86/build-xkb/";; programs/Xserver/
    ;"/tmp/xpatches/medved/"


    ;; [14 giu 05] i have to put back ...
    ;"/linux/13/x/xfree86/new/"
    ;"/x/cvs/xfree/xpatches/medved-plugin/"
    "~/xfree/xpatches/medved-plugin/"

    ;;"/linux/13/x/xfree86/build-medved/";; programs/Xserver/
    ;"/p/xfree-4.3.99.901-r4/work/"
    ;"/tmp/xpatches/xpatches/medved/"
    ))


(defun ediff-x (filename)
  "run `ediff' on file & its companion.
Filename is read (by `ffap'), and companion is searched for in
a list of diretories ... see `ediff-x-roots'."
  (interactive (list (thing-at-point 'filename)))
  (ediff
   (compose-path  (car ediff-x-roots) filename)
   (compose-path  (nth 1 ediff-x-roots) filename)
  ))



(when nil
  ;; Experiments with my feature
  (when
      (functionp 'set-frame-group-leader)
    (setq ediff-multiframe 't)

    ;; in lisp/ediff-wind.el
    ;; in (defun ediff-setup-control-frame (ctl-buffer designated-minibuffer-frame)
    (let ((base-frame-id (string-to-number
                          (aget
                           (frame-parameters)
                           'window-id))))
      (set-frame-group-leader nil base-frame-id)
      (message "Creating new frame, and grouping with %d" base-frame-id)
      (set-frame-group-leader ctl-frame base-frame-id))
  ))


(provide 'mmc-ediff)
