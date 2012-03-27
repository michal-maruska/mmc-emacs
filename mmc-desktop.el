(require 'advice)
(require 'desktop)
(require 'timer)

;; why?
(require 'thingatpt)


;;; `reading'

(defvar my-desktop-keymap (make-sparse-keymap) "")

(define-key my-global-keymap "d" my-desktop-keymap)
(let ((map my-desktop-keymap))
  (define-key map "l" 'desktop-list)
  (define-key map "r" 'desktop-read)
  (define-key map "s" 'desktop-save)
  (define-key map "r" 'my-desktop-read))



;; fixme: evaluates twice the file.
(defmacro add-existing-file! (file list)
  "add to the list file, but only if it really exists."
  ;; not hygienic:
  `(let ((file ,file))
     (if (and (file-exists-p file)
	      (file-regular-p file))
	 (add-to-list ,list file))))

;; testing:
(when nil
  (setq file-list '())
  (add-existing-file "my-tempo.el" 'file-list)
  (add-existing-file "" 'file-list)
  (add-existing-file "my-tempo.e" 'file-list))




;;;
(defun possible-filenames()
  "find filenames, which relate to the point, mark?, buffer (& major mod) ...."
  (let ((file-list '())
	(file (thing-at-point 'filename)))
    ;; need a macro
    (add-existing-file file 'file-list)
    (when (eq major-mode 'dired-mode)
      ;(setq file (dired-get-filename nil 't))
      (add-existing-file (dired-get-filename nil 't) 'file-list))
    file-list))

;(possible-filenames)

(defun my-desktop-read (arg)
  "i want the possibility to say explicitely from what file to take the data"
  ;; the problem is, that the desktop-read  is not flexible !
  (interactive "p")
  (let ((orig-desktop-basefilename desktop-base-file-name) ; default filename
	default)
    (if arg
	;; get the filename
	(let ((default (or (car (possible-filenames))
			   orig-desktop-base-file-name))
	      )
	      ;; get defaults:
	  ;; (thing-at-point 'filename)
	  (setq desktop-base-file-name
		(file-name-nondirectory
		 (read-file-name
		  (concat "desktop file: (" default ") ")
		  "~/"
		  (file-name-nondirectory default)
		  't
		  ;orig-desktop-base-file-name
		  (file-name-nondirectory default)
		  )))))
    (desktop-read)
    ;; (setq desktop-read orig-desktop-base-file-name)
    ))

;;; for reference:    taken from desktop.el
(when nil
  (defun desktop-read-from (file)
    ""
    ;; here we go:
    (load file t t t)
    (run-hooks 'desktop-delay-hook)
    (setq desktop-delay-hook nil)
    (message "desktop loaded."))


;;; read-in:
  (defun desktop-read ()
    "read the desktop file and the files it specifies.
this is a no-op when emacs is running in batch mode."
    (interactive)
    (if noninteractive
	nil
      (let ((dirs '("./" "~/")))
	(while (and dirs
		    (not (file-exists-p (expand-file-name
					 desktop-base-file-name
					 (car dirs)))))
	  (setq dirs (cdr dirs)))
	(setq desktop-dirname (and dirs (expand-file-name (car dirs))))
	(if desktop-dirname
	    (desktop-read-from (expand-file-name desktop-base-file-name desktop-dirname))
	  (desktop-clear)))))
  )


(defadvice desktop-create-buffer (around desktop-protect activate)
  "if we fail, .emacs does not execute, so we lose functionality (when repairing desktop files)"
  ;; (catch
  (condition-case nil
      ad-do-it
    (error
     (progn
       (ding)
       ;; todo: be more verbose!
       (message "error: desktop-create-buffer failed")))))


;;; `writing'
;;; variables:
(when nil
  (mapcar
   (lambda (variable)
     (add-to-list 'desktop-globals-to-save variable))
   '(
     desktop-globals-to-save
					;     kill-ring
     )))



(setq desktop-base-file-name (concat ".emacs.desktop-" (number-to-string (emacs-pid))))

;;; this is timer:
(defun my-desktop-save ()
  "i keep the desktop of this session (read pid) separate. "
  (interactive)
  ;; fixme:
  ;(message "my-desktop-save! idle start: [%s].." start-idle-time)
  (message "auto-saving! start: [%s].." (current-time-string))
  (let* ((directory  (concat  (getenv "HOME") "/") )
	 (current (concat directory desktop-base-file-name))
	 (new (format "%s-%d" current (emacs-pid)))
	 (d-buffer "*desktop*"))
    (if (file-exists-p current) (rename-file current new 't))
    (if (not (buffer-live-p (get-buffer d-buffer)))
	(message "desktop buffer does not exist")
      (with-current-buffer d-buffer
	(set-buffer-file-coding-system 'emacs-mule)))
    (desktop-save (format "%s/" (getenv "HOME"))) ; (expand-file-name "~/"))  FIXME (de-save wants / end)
    (message "auto-saving! end:   [%s]" (current-time-string))))



;; timer
(when nil
  (run-with-idle-timer 60 't 'my-desktop-save)
  (run-with-idle-timer 55 't '(lambda () (message "idle too much!")))
  (run-with-idle-timer 20 't '(lambda () (let ((message-log-max 't)) (message "idle too much! [%s]" (current-time-string)))))
;; (cancel-timer (nth 9 timer-idle-list))  timer-list
;; 'my-desktop-save)
  (setcdr (nth 4 timer-idle-list))
  )



;;;  I want to ...
(when nil
  ;;
  (defvar start-idle-time nil "")
  (run-with-idle-timer 1 't
		       '(lambda ()
			  (setq start-idle-time (current-time-string))))
  )

;; timer
(defun timer-function (timer)
  (aref timer 5))


(unless running-xemacs
  (mapc
   (lambda (item)
     (if (equal (timer-function item)
		;;'(message "idle too much!")
		;; '(lambda () (message nil) (message "idle too much! %S" message-log-max))
		;'(lambda () (let ((message-log-max 't)) (message "idle too much!") (message-date)))
		(lambda nil (my-desktop-save))
		;;'(lambda () (message "idle too much!")(message-date))
		;;'(lambda nil (my-desktop-save))
		)
	 (cancel-timer item)))
   timer-idle-list))
;;
;; (cancel-timer (car timer-idle-list))
;;(my-desktop-save)

;; (mdb-clean-sources)

(defun list-desktops ()
  ""
  (interactive)
  (dired "~/.emacs.desktop*" "-tl"))


(defalias 'desktop-list 'list-desktops)

;;; TIMERED TASKS       FIXME !!!
(run-with-idle-timer
 ;; every 6 seconds??
 120 't
 (lambda ()
   (my-desktop-save)
   ;;(when (buffer-live-p ".known-files")
   ;; (with-current-buffer ".known-files"(save-buffer ))
   ;; (message "idle timer saved .known-files."))
   ))


(setq undo-ask-before-discard nil)



(provide 'mmc-desktop)
