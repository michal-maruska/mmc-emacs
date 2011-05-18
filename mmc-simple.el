;;; (c) M. Maruska
;;; Simple functions, of general interest

(defun relax (&rest rest)
  "do nothing")



(defvar running-xemacs (string-match "XEmacs\\|Lucid" emacs-version))
(defconst emacs-21
  (string-match "^2[124]\.*" emacs-version))

(defconst emacs-22
  (string-match "^22\.*" emacs-version))

(defconst emacs-24 (= emacs-major-version 24))

(if running-xemacs
    (defvar xemacs-version (construct-emacs-version-name) "") ;"21.2.b37" ;emacs-version
  )


;; fixme:  more standard name?
(defmacro run-wo-fail (&rest body)
  `(condition-case error-var                    ;error
      (progn
        ,@body
        )
    (error				;"Font `-*-lucidatypewriter-medium-r-normal-*-20-*-*-*-*-*-fontset-1' is not defined"
     (message "error occured, avoiding FAIL! %s" error-var) 't)))


;;
;;
(require 'advice)
(defun mapcar-nonil (function list)
  "Get the list of non-nil results of `mapcar', seems to be a frequent operation"
  (delq
   nil
   (mapcar
    function
    list)))


(defun list-search-positive (function list)
  "get the 1st non-nil result of function applied on element of LIST"
  ;;  ...see the `scheme' info-manual
  (let (found)
    ;; fixme:  catch/throw !!
    (while (and (not found)
		(consp list))
      (setq found (funcall function (car list))
	    ;; serial?
	    list (cdr list)))
    found))

;;; 23 Jun 01:  how many times have i used this?
(defsubst point-eol ()
  "like point-min"
  (save-excursion
    (end-of-line) (point)))

(defsubst point-bol ()
  "like point-max"
  (save-excursion
    (beginning-of-line) (point)))
;;;
(defun sbke ()
  "convenient abbrev"
  (interactive)
  (call-interactively 'save-buffers-kill-emacs))
;; better:
(defalias 'sbke 'save-buffers-kill-emacs)




;; I was quite surprised, that this kind of command was missing:  I bind it to \M-BS
(defun backward-kill-line (point)
  "kill the current line from cursos to the beginning (why isn't is standard function ?)"
  (interactive "d")
  (beginning-of-line)
  (delete-region  (point) point))

(global-set-key [(meta ?H)] 'fc-kill-to-beginning-of-line)
;; forcer (irc)
(defun fc-kill-to-beginning-of-line ()
  "Kill from the beginning of the line to point."
  (interactive)
  (kill-region (point-at-bol) (point)))

(defun kill-line-save (point)
  "kill line without killing, just push into the kill-ring."
  (interactive "d")
  (save-excursion
    ;;(beginning-of-line)
    (end-of-line)
    (copy-region-as-kill (point) point)))


(defun kill-backward-line-save (point)
  "kill line without killing, just push into the kill-ring."
  (interactive "d")
  (save-excursion
    (beginning-of-line)
    ;;(end-of-line)
    (copy-region-as-kill (point) point)))

(defun transpose-windows ()
  "transpose the 2 windows in the current frame"
  (interactive)
  (let* ((W1 (selected-window))
     (W2 (other-window 1))
     (B1 (window-buffer  W1))
     (B2 (window-buffer  W2)))
    (set-window-buffer W1 B2)
    (set-window-buffer W2 B1)))

(defun line-string ()
  "return the current line (where is the point) as string"
  (save-excursion
    (buffer-substring (point-bol) (point-eol))))

(defun line-string-at-marker (marker)
  "Get the `line-string' from the marker"
  (save-excursion
    (set-buffer (marker-buffer marker))
    (goto-char marker)
    (line-string)))

;; Capitalize ???

					;(defun my-rename-buffer (newname)
					;  "when reading the new name, INITIAL-CONTENTS is the current name"
					;  (interactive
					;   (list
					;    (read-string "Rename buffer (to new name): " (buffer-name)) ))
					;  (rename-buffer newname) )

;;(lookup-key minibuffer-local-completion-map " ")
					;(unless running-xemacs



(require 'rename-buffer)

(defun append-to-buffer-end (buffer string)
  "Append at the END of the BUFFER"
  (save-current-buffer
    (set-buffer buffer)
    (save-excursion
      ;; save point ??
    (goto-char (point-max))
    (insert string) )))


;;; keymaps
(require 'mmc-keys)

(define-key my-global-keymap "t" 'transpose-windows)

(defun substitute-key (key new-key map)
  ""
  (let ((function-or-keymap (lookup-key map key)))
    (if (and function-or-keymap
	     (not (lookup-key map new-key)))
	(define-key map new-key function-or-keymap)
      (message "cannot substitue"))))


(defun kill-sexp-save (arg)
  "Set mark ARG sexps from point.
The place mark goes is the same place \\[forward-sexp] would
move to with the same argument."
  (interactive "p")
  (save-excursion
    (let (start end)
    (forward-sexp arg)
    (setq end (point))
    (backward-sexp arg)
    (kill-ring-save (point) end))))

(global-set-key [(control shift delete)] 'kill-sexp-save)
					;(global-set-key [(control shift ?o)] 'other-window)
(global-set-key [(control ?O)] 'other-window)


;; todo: C-u prefix -> whole buffer
(defun delete-tail-from-region (start end)
  (interactive "r")
  (save-excursion
    (let ((regexp "[ 	]+$")
	  (to-string ""))
      (replace-regexp regexp to-string nil start end))))


      ;(goto-char start)
;    (while (re-search-forward regexp end t)
;      (replace-match to-string nil nil)) )))


(define-key my-global-keymap "$" 'delete-tail-from-region)

(defun drop-line (arg)
  "delete the ARG lines, and remain at the same column"
  (interactive "p")
  (let ((column (current-column)))
    (beginning-of-line)
    (kill-line arg)
    (forward-char (min column (- (point-eol) (point-bol))))))

(defun delete-head-from-region (start end)
  (interactive "r")
  (save-excursion
    (let ((regexp "^[ 	]+")
	  (to-string ""))
    (goto-char start)
    (while (re-search-forward regexp end t)
      (replace-match to-string nil nil)) )))

(define-key my-global-keymap "^" 'delete-head-from-region)






(defun kill-other-buffer-and-window (prefix)
  (interactive  "p")
  (other-window 1)
  ;; (if prefix (kill-buffer
  (kill-buffer-and-window))


(global-set-key [(control ?x) ?4 ?k] 'kill-other-buffer-and-window)
;; (global-set-key [(control ?x) ?4 ?k] 'kill-other-buffer-and-window)
(global-set-key [(control meta ?0)] 'delete-window)


;; (require 'assoc)
;; bad !!
'(defun overwrite-alist (from to)
  "overwrite alist TO with the contents of alist FROM, return the modified TO"
  (mapcar
   (lambda (item)
     (aput 'to (car item) (cdr item)))
   from)
  to)

(defun overwrite-alist (alist-symbol new-values)
  "NEW-VALUES is an alist.  "
  (let ((pair '()))
    (while new-values
      (setq pair (car new-values)
            new-values (cdr new-values))
                                        ;(set alist-symbol
      (aput alist-symbol (car pair) (cdr pair)))) ;)
  (symbol-value alist-symbol))

(put 'overwrite-alist 'lisp-indent-hook 1)



;;; just handy functions

;; mixing numbers w/ strings
(defun add-to-string (string number)
  "treat the STRING as number, add the NUMBER, and return result as string"
  (number-to-string (+ (string-to-number string) number)))




(defun alist-from-list (list)
  "Make an alist (from a list) just by consing the elements with themselves"
  ;; fixme: should be consed with nil ??
  (mapcar
   (lambda (atom)
   (cons atom atom))
   list))

(defun alistp (list)
  "is the list an alist --- look at the first element "
  (consp (car list)))
(defalias 'alist 'list)


;; fixme: ring !!!
(defun my-completing-read (prompt table &optional predicate require-match init hist def inherit-input-method ring)
  "I often have only a list ....(not Alist)
;; i want to accept symbols !!"
  ;; ??? we have to
  (if (and (fboundp 'history-clos-p) (history-clos-p hist))
      (setq ring (oref hist ring)
	    hist (oref hist e-history))) ;fixme: what is that?
  (let* ((my-table (cond ((vectorp table) table)
			 ((alistp table) table)
			 ((listp table)
			  (message "my-completing-read: plain list...converting")
			  (alist-from-list table))))
	 (current-ring ring)
	 (current-ring-position 0)
	 ;; (if (and
	 ;;(> (ring-length current-ring) 1)
	 ;; (string= default-buffer (ring-ref current-ring 1)))
	 ;;   1 0))
	 (default (or def (car-safe (car-safe my-table))))
	 (my-prompt
	  (if default (format "%s (default %s) " prompt default) prompt))
	 (result
	  (if running-xemacs
	      (completing-read  my-prompt my-table predicate require-match init hist default)
	    (completing-read  my-prompt my-table predicate require-match init hist default
			      inherit-input-method))))
    (if ring
	(ring-to-head ring result))
    result))


;;; Sets:
(defun my-intersection (list set)
  "in the order of list"
  (delq
   nil
   (mapcar
   (lambda (item)
     (if (member item set)
	 item nil))
   list)))

;;(my-intersection (list "a" "b" "c") (list "x" "y" "c") )
;; (my-subsetp '("a" "b") '("a" "x" "b"))
(defun my-subsetp (list set)
  ""
  (let (item (yes 't))
    (while list
    (setq item (car list)
	  list (cdr list))
    (unless (member item set)
      (setq yes nil
	    list nil)))
    yes))


(defconst quote-region-delimiters-alist
  `(
    (?\" "\"" "\"")
    (?\( "(" ")")
    (?\` "\`" "\'")
    )
  "")

(defun decode-last-key ()
  "get the ascii-code of the last key (throw away modifiers )"
  (interactive)
  (let ((a last-command-event))		;last-command-char
    (cond ((symbolp a)
	   a)
	  ((char-or-string-p a)
	   ;;(insert (logand  255))
	   (logand last-command-event 255))))) ;char


;;; misc
(defun quote-region (start end &optional delimiter)
  (interactive "r")
  (save-excursion
    (let ((last  (or delimiter (decode-last-key)))
          (start-char "'")
          (end-char "'")
          info)
      (if (setq info (aget quote-region-delimiters-alist last 't))
          (setq start-char (nth 0 info)
                end-char (nth 1 info)))
      (goto-char start)
      (insert start-char)
      (goto-char (1+ end))
      (insert end-char))))

(defun highlight-keyword ()
  "highlight the current symbol name (sexp in fact !!), in the elisp style:  `thus'"
  (interactive)
  ;;(mark-word)
  (let (start end)
    (save-excursion
      (backward-sexp 1)
      (setq start (point))
      (forward-sexp 1)
      (quote-region start (point) ?\`))))


(global-set-key [(alt ?h)] 'highlight-keyword)


(defun symbols-matching-re (re &optional dont-split)
  "Get a list of all symbols whose name matches RE, moreover, only the matched part (group 1)"
  (let (name
	(symbol-list '()))
    (mapatoms
     (lambda (atom)
       (setq name (symbol-name atom))
       (if (string-match re name)
	   (push
	    (if dont-split name (match-string 1 name))
	    symbol-list)
	 nil))
     obarray)
    symbol-list))



;; (defun read-face-name ()
;;   ""
;;   )
;; (read-face-name "face: ")
;; (symbols-matching-re "\\(.*-face\\)$")

(defun mode-symbols ()
  ""
  (symbols-matching-re "^\\(.*\\)-mode$"))





(defun hook-symbols ()
  ""
  (symbols-matching-re "^\\(.*\\)-hooks?$" 't))

(defun read-hook ()
  ""
  (intern (completing-read "hook: " (alist-from-list (hook-symbols)))))


(define-key my-global-keymap "'" 'quote-region)
(define-key my-global-keymap "`" 'quote-region)
(define-key my-global-keymap "(" 'quote-region)
(define-key my-global-keymap "\"" 'quote-region)




;; Stealt from  macro.el !

(defun map-lines (start end function)
  "for every line in the region START - END call the FUNCTION with
point at the beginning-of-line and 1 parameter-- the end. START is the beginning of the 1st line.
dots(...) get processed:
  xxxxx START ......
  ..............
  xxxx END xxxxxx"
  (save-excursion
    (let ((end-marker                   ; this is the beginning of the last line (on which the END is)
           (progn (goto-char end)
                  (beginning-of-line)
                  (point-marker)))
          next-line-marker
          (results ()))
      (goto-char start)
      ;; FIXME:  why ?
      ;; (if (not (bolp))
      ;;   (forward-line 1))
      ;;(setq next-line-marker (point-marker))
      (while (< (point) end-marker)
        (setq
         next-line-marker (save-excursion (forward-line 1) (point))
         results (cons
                  (funcall function (1- next-line-marker))
                  results))
        (goto-char next-line-marker))
      ;; The last line:
      ;; so we process even:   .....END xxxxx
      (if (< (point) end)
          (setq results (cons
                         (funcall function end)	; (point)
                         results)))
      results)))

(defun lines->list (start end)
  "return as list the string-lines"
  (let ((collected-lines '()))
    (map-lines start end
	       (lambda (end)
		 (push
		  (erase-text-properties
		   (buffer-substring (point)  end))
		  collected-lines)))
    (reverse collected-lines)))

; (lines->list (point-min) (point-max))




;; Xemacs has intervals .....
(defun find-largest-less (number list)
  ""
  (let ((position 0))
    (while (and (consp list)(< (car list) number))
      (setq list (cdr list)
	    position (1+ position)))
    position))


;; (find-largest-less 10 '(5 8 11 20))


;; toggle-truncate-lines
(when (or running-xemacs emacs-21 emacs-24)
  (defun hscroll-mode (&optional arg)
    (interactive)
    (setq truncate-lines
	  (or arg
	      (not truncate-lines)))))

(global-set-key [(control ?x) ?x ?|] 'hscroll-mode)


(defun major-mode-of (buffer)
  (variable-in-buffer buffer 'major-mode))

(defun major-modes-used (&optional buffer-list)
  "return the list of major-modes of BUFFER-LIST or (buffer-list)"
  (setq buffer-list (or buffer-list (buffer-list)))
  (let (major-modes-used)
    (mapcar-nonil
     (lambda (item)
       (add-to-list 'major-modes-used
		    (major-mode-of item)))
     buffer-list)
    major-modes-used))


(defun buffers-in-mode (mode &optional names?)
  "Get the list of buffers"
  (mapcar-nonil
   (lambda (item)
     (if (equal (major-mode-of item) mode);; (eval mode)
	 (if names? (buffer-name item) item)
       nil))
   (buffer-list)))
(defalias 'buffers-in-major-mode 'buffers-in-mode)


;; (buffers-in-mode 'mdb-mode)


;; i could  overlay->region ...commands
(defsubst narrow-to-overlay (overlay)
  (narrow-to-region
   (overlay-start overlay)
   (overlay-end overlay)))


(defun erase-text-properties (string)
  "strip text properties from string"
  (set-text-properties 0 (length string) () string)
  string)


(defun kill-matching-buffers (name-regexp)
  "delete buffers of the NAME-REGEXP"
  (let ((buffers (buffer-list)))
    (mapcar
     (lambda (item)
       (when (string-match name-regexp (buffer-name item))
	 (kill-buffer item)))
     buffers)))


;; fixme
;; (setq font-lock-keywords (cons 't (nthcdr 2 font-lock-keywords)))


;(add-to-list
; 'font-lock-keywords


(unless running-xemacs
  ;; (add-hook 'emacs-lisp-mode-hook 'turn-on-font-lock)
  (font-lock-add-keywords
   'emacs-lisp-mode
   '(("\\(FIXME\\)" 1 font-lock-th-face 't 't)))
  )
;; font-lock-keywords-alist

;; FIXME
;;  FIXME:
; (list "\\(fixme\\|alert\\)\\>"
;       (list 1 font-lock-section-face 't)))

;(assq 'emacs-lisp-mode font-lock-defaults-alist)

; (setq lisp-font-lock-keywords
;       (nconc lisp-font-lock-keywords
; 	     (list
; 	      ;; (list "michal")
; 	      ;; (list "\\<foo\\>"  (list 0 font-lock-section-face 't nil))
; 	      ;; (list "michal")

; 	      )))


;; font-lock-warning-face
;; (setq hbut-flash 'hbut-flash)



;; useless ?
(defun where-is-cursor ()
  ""
  (interactive)
  (let ((original-color
	 (frame-parameter (selected-frame) 'cursor-color))
	(u-sec 50))
  (set-cursor-color "Magenta") (sleep-for 0 u-sec)
  (set-cursor-color "Firebrick")(sleep-for 0 u-sec)
  (set-cursor-color "Blue")(sleep-for 0 u-sec)
  (set-cursor-color "MediumSpringGreen")(sleep-for 0 u-sec)
  (set-cursor-color "Cyan")(sleep-for 0 u-sec)
  (set-cursor-color "Coral")(sleep-for 0 u-sec)
  (set-cursor-color original-color)))

(global-set-key [(control ?x) ?W] 'where-is-cursor)




(defun my-kill-region (prefix)
  ""
  (interactive "p")
  (cond ((= prefix 0)
	 (kill-region (point) (mark)))
  ((= prefix 1)
   ;; word
   (kill-region (point) (mark)))
  ;; C-u:
  ((= prefix 4)
   ;; word
   (kill-region (point) (mark)))
  ))



(define-key  my-global-keymap ">"
  (lambda ()
    "erase the tail of buffer"
    (interactive)
    (kill-region (point) (point-max))))

;; Fixme
(defvar zombie-buffers ()
  "")

(defun kill-buffer-dont-ask ()		; just the (curret-bu
  "if not modified,"
  (interactive)
  (let* ((buffer (current-buffer))
	 (name (buffer-name buffer)))
  (rename-buffer (concat " " name))	; buffer
  (bury-buffer)
  (setq zombie-buffers (cons buffer zombie-buffers))))



;;; Read hostname:
(defvar hostname-history (make-symbol "hostname-history") "")
(defvar hostname-ring (make-ring 10) "")
(defvar hostname-list (list "linux3" "linux1") "")

;; (load "setx")
;; (setenv "DISPLAY" "linux6:0")
;;; 
;; i want to set easily the DISPLAY env- variable.
(defun setx (display)
  "set the environement, interactively "
  (setenv "DISPLAY" display))

(defun setx-interactively (prefix)
  "try to deduce from PREFIX, what the user wants"
  (interactive "P")
  (let ((display (frame-parameter (selected-frame) 'display)))
  (if prefix
      (setq display (read-display "set DISPLAY: " (getenv "DISPLAY"))))
  (setx display)
  (message "DISPLAY=%s" display)))

(define-key my-global-keymap "x" 'setx-interactively)










;; unused:
(defun read-hostname ()
  "Read a hostname"
  (my-completing-read "hostname: " hostname-list nil nil "" hostname-history nil nil hostname-ring))



(defvar display-history (make-symbol "display-history") "") ;;
(set display-history ())
(defvar display-ring (make-ring 10) "")
(defvar display-list () "")

;; Should be ..
(defun displays-from-hostnames (host-list)
  ""
  (mapcar
   (lambda (item)
     (concat item ":0"))
   host-list))

(setq display-list (displays-from-hostnames hostname-list))


;(defun read-display-complete () "")

(defun read-display (&optional prompt def table)
  ""
  (my-completing-read
   (or prompt "display: ")
   (or table display-list) nil nil "" display-history def nil display-ring))
;;(read-display)



(defadvice make-frame-on-display (before read-the-display activate);; first
  (interactive
   (list (read-display "new frame on: "))))
















(defun indent-defun ()
  ""
  (interactive)
  (save-excursion
    (mark-defun)
    (indent-region (point) (mark) nil)))



(defun kill-buffer-and-window ()
  "Kill the current buffer and delete the selected window."
  (interactive)
  (let ((buffer (current-buffer)))
    (kill-buffer buffer)
    (unless (buffer-live-p buffer)
      (delete-window (selected-window)))))

;; In hyperbole there is smth like this?
(defun eval-command-or-form (form-command)
  ""
  (if (functionp form-command)
      (funcall form-command)
    (eval form-command)))


(defun variable-in-buffer (buffer variable)
  ""
  (save-current-buffer
    (set-buffer buffer)
    ;;(assoc 'scan-mode minor-mode-alist)
    (symbol-value variable)))
;; (variable-in-buffer (current-buffer) 'major-mode)


;(major-mode-of "*grep*")

;; fixme: i need a (read-minor-mode)
(defun buffers-with-minor-mode (mode)
  ""
  (interactive (list (read-mode)))
  (let (buffers)
    (mapc
     (lambda (buffer)
       (if (variable-in-buffer buffer mode)
	   (setq buffers (cons buffer buffers))))
     (buffer-list))
    buffers))

;; (buffers-with-minor-mode 'foto-mode)
(defun read-mode (&optional prompt)
  "Read a symbol with `-mode' suffix (completion omits), "
  (intern (concat (completing-read (or prompt "mode: ") (alist-from-list (mode-symbols))) "-mode")))
; (read-mode)

(defvar read-minor-mode-history (make-symbol "read-minor-mode-history") "")
(defun read-minor-mode (&optional prompt)
  ""
  (intern
   (completing-read (or prompt "minor mode: ")
		    (alist-from-list
		     (mapcar
		      (lambda (item)
			(symbol-name (car item)))
		      minor-mode-alist)
		     )nil 't "" read-minor-mode-history)))

(defun kill-buffers-with-minor-mode (mode)
  "kill all buffers with the minor mode, but the current one"
  (interactive
   (list (read-minor-mode)))
  (let ((current-buffer (current-buffer))
	(killed-buffers (buffers-with-minor-mode mode)))
    ;;(not (eq current-buffer buffer))
    ;;(not (string= current-buffer (buffer-name buffer)))); ???
    (mapcar 'kill-buffer  killed-buffers)))




;;; [07 Oct 01]
(defun insert-filename (&optional filename)
  "insert at point a filename, possibly a completion of a gem"
  (interactive)
  ;(ffap-file-finder "prompt: ")

  (unwind-protect
      (let* ((guess (ffap-guesser))
            (dir (if (stringp guess)    ;could be `nil'
                     (file-name-directory guess)))
            (base (if (stringp guess)
                      (file-name-nondirectory guess)))
	    overlay)
	(ffap-highlight)
        
	(setq filename
              (if emacs-22
                  (ffap-read-file-or-url "Insert filename: " guess)
                (read-file-name "Insert filename: " dir base nil base)))
	;; (interactive "finsert filename: ")
	(if (setq overlay ffap-highlight-overlay)
	    (delete-region (overlay-start overlay) ;;kill-region
			   (overlay-end overlay)))
	(ffap-highlight t)
	(insert filename))
      (ffap-highlight t)))


(when nil
  (thing-at-point 'filename) (find-file-at-point)
  (ffap-prompter)
  (progn (ffap-guesser)(ffap-highlight))~/activity/sche
)

(define-key insert-keymap "f" 'insert-filename)
(define-key my-global-keymap [(control ?f)] 'insert-filename)




(defun next-word (arg)
  ""
  (interactive "p")
  (forward-word arg)
  (skip-chars-forward " "))



(if running-xemacs
    (global-set-key [(control meta ?F)]   'next-word)
  (global-set-key [(control meta shift ?f)]   'next-word))



(defun zap-upto-char (arg char)
  "Kill up to and including ARG'th occurrence of CHAR.
Case is ignored if `case-fold-search' is non-nil in the current buffer.
Goes backward if ARG is negative; error if CHAR not found."
  (interactive "p\ncZap to char: ")
  (kill-region (point) (progn
			 (search-forward (char-to-string char) nil nil arg)
;			 (goto-char (if (> arg 0) (1- (point)) (1+ (point))))
			 (1- (point)))))

(global-set-key [(control meta ?z)]   'zap-upto-char)




(defun buffer-string-of (buffer)
  ""
  (with-current-buffer buffer
    (buffer-string)))



(defun delete-substring (string substring)
  "Get the STRING with 1st occurence of SUBSTRING removed"
  (if (string-match (regexp-quote substring) string)
      (replace-match "" 't 't string)
    string))



(defun message-date ()
  ""
  (interactive)
  (message (current-time-string)))

(global-set-key [(alt ?d)]  'message-date)




;;; DISPLAY

(defun hostname ()
  ""
  (let ((fqhn (system-name)))
    (if (string-match "^\\([^.]*\\)\\." fqhn)
        (match-string 1 fqhn)
      fqhn)))
;(hostname)

;(with-display "linux6:0" (xterm))
;; The problem is  with the x-display variable: (can be shadowed by `old-display')
(defmacro with-display (x-display &rest body)
  "run BODY with the DISPLAY env-var set to X-DISPLAY, 't ->frame's one"
  `(let ((old-display (getenv "DISPLAY"))
	 (this-display (if (eq ,x-display 't)
			   (if running-xemacs
			       (frame-property (selected-frame) 'display  "0:0")
			     (frame-parameter (selected-frame) 'display))
			 ,x-display)))
     (if (string= this-display (concat (hostname) ":0"))
	 (setq this-display ":0"))
     (unwind-protect
	 (progn
	   (setenv "DISPLAY" this-display)
	   ;; ((command (format "guardafotoz %s >/dev/null 2&>1 &" id)))
	   ,@body)
       (setenv "DISPLAY" old-display))))
;; (frame-property (selected-frame) 'display  "0:0")
;;  (frame-properties (selected-frame)) 'display  "0:0")
(put 'with-display 'lisp-indent-function 1)


(defun unique (list)
  "the LIST must be sorted"
  (let (unique current last)
    (while (setq current (car list))
      (unless (string= current last)	;
	(setq unique (cons current unique)
	      last current))
      (setq list (cdr list)))
    (reverse unique)))




(defun switch-to-alternate-buffer (buffer)
  "Find file FILENAME, select its buffer, kill previous buffer.
If the current buffer now contains an empty file that you just visited
\(presumably by mistake), use this command to visit the file you really want."
  (interactive
   (list
   (read-buffer "alternate buffer: " (other-buffer) 't)))
  ;; from files.el:
  (and (buffer-modified-p) (buffer-file-name)
       ;; (not buffer-read-only)
       (not (yes-or-no-p (format "Buffer %s is modified; kill anyway? "
				 (buffer-name))))
       (error "Aborted"))
  (let ((obuf (current-buffer)))
    (switch-to-buffer buffer)
    (or (eq (current-buffer) obuf)
	(kill-buffer obuf))))



(defun last-key()
  ""
  (aref (this-command-keys-vector)
	(1- (length (this-command-keys-vector)))))




;;; discussion on irc resolve
(defun run-on-current-word(prefix function &rest args)
  ""
  ;; FIXME: i want to undo it and stay at the same place !!!
  (save-excursion
    (backward-word prefix)
    (apply function args)))

(defun capitalize-current-word (prefix)
  "capitalize the last word which starts before point"
  (interactive "p")
  (run-on-current-word prefix 'capitalize-word prefix))

(defun upcase-current-word (prefix)
  "capitalize the last word which starts _before_ point"
  (interactive "p")
  (run-on-current-word prefix 'upcase-word prefix))


(global-set-key   [(control ?C)] 'capitalize-current-word)
(global-set-key   [(control ?U)] 'upcase-current-word)



(defun multi-princ (&rest args)
  ""
  (mapcar 'princ
	  args))



(defun append-buffer-to-file (file)
  (interactive "F") 
  (append-to-file (point-min) (point-max) file))

(global-set-key "\C-x\M-w" 'append-buffer-to-file)




(defun list-non-nil (&rest args)
  "return list of ARGS removing nils"
  (delq nil (apply 'list args)))


'(defmacro list-non-nil (&rest args)
  "return list of ARGS removing nils"
  `(delq nil (list ,@args)))
;(list-non-nil 1 nil 2 3 )



(defun set-default-directory (dir)
  ""
  (interactive "Ddefault-directory: ")
  ;; (let ((dir (read-directory-name "default-directory: " default-directory)
  ;;))
  (setq default-directory dir))





(defun maybe-int-to-string (i)
  ""
  (if (integerp i)
      (int-to-string i)
    i))




(defun my-kill-line-old (arg)
  "Move to beginning of the line, and then kill the whole line"
  (interactive "p")
  (undo-group-boundary)
  (push-mark)
  (kill-region (point-at-bol)
               (progn
                 (if arg
                     (forward-visible-line (prefix-numeric-value arg))
                   (if (eobp)
                       (signal 'end-of-buffer nil))
                   (if (or (looking-at "[ \t]*$") (and kill-whole-line (bolp)))
                       (forward-visible-line 1)
                     (end-of-visible-line)))
                 (point)))
  (undo-group-boundary))

(global-set-key [(control ?K)] 'my-kill-line)

(defun my-kill-line (arg)
  "Move to beginning of the line, and then kill the whole line"
  (interactive "p")
  (beginning-of-line nil)
  (kill-line arg))



(defun window-half-height ()
  (max 1 (/ (1- (window-height (selected-window))) 2)))

(defun scroll-up-half ()
  (interactive)
  (scroll-up (window-half-height)))

(defun scroll-down-half ()
  (interactive)
  (scroll-down (window-half-height)))

(global-set-key (kbd "A-i") 'scroll-down-half)
(global-set-key (kbd "A-k") 'scroll-up-half)




(defun emacs-message-buffer-name ()
  (if running-xemacs " *Message-Log*" "*Messages*"))

(defun my-display-messages (prefix)
  "display the buffer with last messages, with prefix, position at the end (of the buffer)"
  (interactive "P")
  (let* ((bufname (emacs-message-buffer-name))
	 (window (display-buffer bufname)))
    (unless prefix
      (set-window-point window (with-current-buffer bufname (point-max))))))


(defun shell-command-to-string-no-nl (command)
  ""
  (let ((string (shell-command-to-string command)))
    (substring string 0 (1- (length string)))))

;;; end
(provide 'mmc-simple)

(defun byte-compile-this-file ()
  ""
  (interactive)
  (let ((file (buffer-file-name (current-buffer))))
    (byte-compile-file file)
    (load-file (concat file "c"))))