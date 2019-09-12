
;;;  `ibuffer'


(defun ibuffer-limit-by-mode (mode)
  "Toggle current view to buffers with major mode MODE.
To disable the limit, call this function again."
  (interactive
   (cons
    (if (ibuffer-get-qualifier 'mode)
        nil
    (read-mode "Limit by major mode: "))
    nil))
  (cond (mode
         (ibuffer-add-qualifier 'mode mode)
         (message "View limited by major mode: %s" mode))
        (t
         (ibuffer-remove-qualifier 'mode)
         (message "Limiting by major mode disabled.")))
  (ibuffer-update-mode-name)
  (ibuffer-update nil t))


;;; `iswitchb'
(defun iswitchb-post-command ()
  "Run after command in `iswitchb-buffer'. mmc version"
  (iswitchb-exhibit)
  ;; mmc: when the results is now 1, preview it immediately.
  (if (= (length iswitchb-matches) 1)
      (display-buffer (car iswitchb-matches))))

(defun iswitchb-select-buffer-other-window ()
  "Select the buffer named by the prompt. But in another window."
  (interactive)
  (setq iswitchb-method 'otherwindow)
  (exit-minibuffer))

;;
(add-hook 'iswitchb-define-mode-map-hook
  (lambda ()
    (let ((map iswitchb-mode-map))
      (define-key map "?" 'iswitchb-completion-help)
      (define-key map "\C-s" 'iswitchb-next-match)
      (define-key map "\C-r" 'iswitchb-prev-match)
      (define-key map "\t" 'iswitchb-complete)

      (define-key map "\C-j" 'iswitchb-select-buffer-text)
      (define-key map "\M-m" 'iswitchb-select-buffer-other-window)
      (define-key map "\C-t" 'iswitchb-toggle-regexp)
      (define-key map "\C-x\C-f" 'iswitchb-find-file)
      ;;(define-key map "\C-a" 'iswitchb-toggle-ignore)
      (define-key map "\C-c" 'iswitchb-toggle-case)
      (define-key map "\C-k" 'iswitchb-kill-buffer)
      (define-key map "\C-m" 'iswitchb-exit-minibuffer)
      )))



;;; Show the buffer when asking whether to reload.
(defun find-file-noselect (filename &optional nowarn rawfile wildcards)
  "Read file FILENAME into a buffer and return the buffer.
If a buffer exists visiting FILENAME, return that one, but
verify that the file has not changed since visited or saved.
The buffer is not selected, just returned to the caller.
Optional second arg NOWARN non-nil means suppress any warning messages.
Optional third arg RAWFILE non-nil means the file is read literally.
Optional fourth arg WILDCARDS non-nil means do wildcard processing
and visit all the matching files.  When wildcards are actually
used and expanded, return a list of buffers that are visiting
the various files."
  (setq filename
        (abbreviate-file-name
         (expand-file-name filename)))
  (if (file-directory-p filename)
      (or (and find-file-run-dired
               (run-hook-with-args-until-success
                'find-directory-functions
                (if find-file-visit-truename
                    (abbreviate-file-name (file-truename filename))
                  filename)))
          (error "%s is a directory" filename))
    (if (and wildcards
             find-file-wildcards
             (not (string-match "\\`/:" filename))
             (string-match "[[*?]" filename))
        (let ((files (condition-case nil
                         (file-expand-wildcards filename t)
                       (error (list filename))))
              (find-file-wildcards nil))
          (if (null files)
              (find-file-noselect filename)
            (mapcar #'find-file-noselect files)))
      (let* ((buf (get-file-buffer filename))
             (truename (abbreviate-file-name (file-truename filename)))
             (attributes (file-attributes truename))
             (number (nthcdr 10 attributes))
             ;; Find any buffer for a file which has same truename.
             (other (and (not buf) (find-buffer-visiting filename))))
        ;; Let user know if there is a buffer with the same truename.
        (if other
            (progn
              (or nowarn
                  find-file-suppress-same-file-warnings
                  (string-equal filename (buffer-file-name other))
                  (message "%s and %s are the same file"
                           filename (buffer-file-name other)))
              ;; Optionally also find that buffer.
              (if (or find-file-existing-other-name find-file-visit-truename)
                  (setq buf other))))
        ;; Check to see if the file looks uncommonly large.
        (when (not (or buf nowarn))
        ;;
          (abort-if-file-too-large (nth 7 attributes) "open" filename))
        (if buf
            ;; We are using an existing buffer.
            (let (nonexistent)
              (or nowarn
                  (verify-visited-file-modtime buf)
                  (cond ((not (file-exists-p filename))
                         (setq nonexistent t)
                         (message "File %s no longer exists!" filename))
                        ;; Certain files should be reverted automatically
                        ;; if they have changed on disk and not in the buffer.
                        ((and (not (buffer-modified-p buf))
                              (let ((tail revert-without-query)
                                    (found nil))
                                (while tail
                                  (if (string-match (car tail) filename)
                                      (setq found t))
                                  (setq tail (cdr tail)))
                                found))
                         (with-current-buffer buf
                           (message "Reverting file %s..." filename)
                           (revert-buffer t t)
                           (message "Reverting file %s...done" filename)))
                        ((progn
                           (display-buffer buf)
                           (yes-or-no-p
                            (if (string= (file-name-nondirectory filename)
                                         (buffer-name buf))
                                (format
                                 (if (buffer-modified-p buf)
                                     "File %s changed on disk.  Discard your edits? "
                                   "File %s changed on disk.  Reread from disk? ")
                                 (file-name-nondirectory filename))
                              (format
                               (if (buffer-modified-p buf)
                                   "File %s changed on disk.  Discard your edits in %s? "
                                 "File %s changed on disk.  Reread from disk into %s? ")
                               (file-name-nondirectory filename)
                               (buffer-name buf)))))
                         (with-current-buffer buf
                           (revert-buffer t t)))))
              (with-current-buffer buf

                ;; Check if a formerly read-only file has become
                ;; writable and vice versa, but if the buffer agrees
                ;; with the new state of the file, that is ok too.
                (let ((read-only (not (file-writable-p buffer-file-name))))
                  (unless (or nonexistent
                              (eq read-only buffer-file-read-only)
                              (eq read-only buffer-read-only))
                    (when (or nowarn
                              (let ((question
                                     (format "File %s is %s on disk.  Change buffer mode? "
                                             buffer-file-name
                                             (if read-only "read-only" "writable"))))
                                (y-or-n-p question)))
                      (setq buffer-read-only read-only)))
                  (setq buffer-file-read-only read-only))

                (unless (or (eq (null rawfile) (null find-file-literally))
                            nonexistent
                            ;; It is confusing to ask whether to visit
                            ;; non-literally if they have the file in
                            ;; hexl-mode or image-mode.
                            (memq major-mode '(hexl-mode image-mode)))
                  (if (buffer-modified-p)
                      (if (y-or-n-p
                           (format
                            (if rawfile
                                "The file %s is already visited normally,
and you have edited the buffer.  Now you have asked to visit it literally,
meaning no coding system handling, format conversion, or local variables.
Emacs can only visit a file in one way at a time.

Do you want to save the file, and visit it literally instead? "
                                "The file %s is already visited literally,
meaning no coding system handling, format conversion, or local variables.
You have edited the buffer.  Now you have asked to visit the file normally,
but Emacs can only visit a file in one way at a time.

Do you want to save the file, and visit it normally instead? ")
                            (file-name-nondirectory filename)))
                          (progn
                            (save-buffer)
                            (find-file-noselect-1 buf filename nowarn
                                                  rawfile truename number))
                        (if (y-or-n-p
                             (format
                              (if rawfile
                                  "\
Do you want to discard your changes, and visit the file literally now? "
                                "\
Do you want to discard your changes, and visit the file normally now? ")))
                            (find-file-noselect-1 buf filename nowarn
                                                  rawfile truename number)
                          (error (if rawfile "File already visited non-literally"
                                   "File already visited literally"))))
                    (if (y-or-n-p
                         (format
                          (if rawfile
                              "The file %s is already visited normally.
You have asked to visit it literally,
meaning no coding system decoding, format conversion, or local variables.
But Emacs can only visit a file in one way at a time.

Do you want to revisit the file literally now? "
                            "The file %s is already visited literally,
meaning no coding system decoding, format conversion, or local variables.
You have asked to visit it normally,
but Emacs can only visit a file in one way at a time.

Do you want to revisit the file normally now? ")
                          (file-name-nondirectory filename)))
                        (find-file-noselect-1 buf filename nowarn
                                              rawfile truename number)
                      (error (if rawfile "File already visited non-literally"
                               "File already visited literally"))))))
              ;; Return the buffer we are using.
              buf)
          ;; Create a new buffer.
          (setq buf (create-file-buffer filename))
          ;; find-file-noselect-1 may use a different buffer.
          (find-file-noselect-1 buf filename nowarn
                                rawfile truename number))))))

;; pre 24.*
(unless (boundp 'find-library--load-name)
  (defun find-library--load-name (library)
    (let ((name library))
      (dolist (dir load-path)
        (let ((rel (file-relative-name library dir)))
          (if (and (not (string-match "\\`\\.\\./" rel))
                   (< (length rel) (length name)))
              (setq name rel))))
      (unless (equal name library) name))))

;; in git!
(defun find-library-name (library)
  "Return the absolute file name of the Emacs Lisp source of LIBRARY.
LIBRARY should be a string (the name of the library)."
  ;; If the library is byte-compiled, try to find a source library by
  ;; the same name.
  (if (string-match "\\.el\\(c\\(\\..*\\)?\\)\\'" library)
      (setq library (replace-match "" t t library)))
  (or
   (when (file-name-absolute-p library)
     (let ((rel (find-library--load-name library)))
       (when rel
         (or
          (locate-file rel
                       (or find-function-source-path load-path)
                       (find-library-suffixes))
          (locate-file rel
                       (or find-function-source-path load-path)
                       load-file-rep-suffixes)))))

   (locate-file library
                (or find-function-source-path load-path)
                (find-library-suffixes))
   (locate-file library
                (or find-function-source-path load-path)
                load-file-rep-suffixes)

   (error "Can't find library %s" library)))



;; Fix ffap-URL to ignore <> in the c-mode.
;;  #include <stdio>  would mailto:stdio.
(defun ffap-url-at-point ()
  "Return URL from around point if it exists, or nil."
  ;; Could use w3's url-get-url-at-point instead.  Both handle "URL:",
  ;; ignore non-relative links, trim punctuation.  The other will
  ;; actually look back if point is in whitespace, but I would rather
  ;; ffap be less aggressive in such situations.
  (and
   ffap-url-regexp
   (or
    ;; In a w3 buffer button?
    (and (eq major-mode 'w3-mode)
         ;; interface recommended by wmperry:
         (w3-view-this-url t))
    ;; Is there a reason not to strip trailing colon?
    (let ((name (ffap-string-at-point 'url)))
      (cond
       ((string-match "^url:" name) (setq name (substring name 4)))
       ((and (string-match "\\`[^:</>@]+@[^:</>@]+[[:alnum:]]\\'" name)
             ;; "foo@bar": could be "mailto" or "news" (a Message-ID).
             ;; Without "<>" it must be "mailto".  Otherwise could be
             ;; either, so consult `ffap-foo-at-bar-prefix'.
             (let ((prefix (if (and (equal (ffap-string-around) "<>")
                                    ;; Expect some odd characters:
                                    (string-match "[$.0-9].*[$.0-9].*@" name))
                               ;; Could be news:
                               ffap-foo-at-bar-prefix
                             "mailto")))
               (and prefix (setq name (concat prefix ":" name))))))
       ((ffap-newsgroup-p name) (setq name (concat "news:" name)))
       ((and (string-match "\\`[[:alnum:]]+\\'" name) ; <mic> <root> <nobody>
             (not (member major-mode
                          '(c-mode
                            c++-mode)))
             (equal (ffap-string-around) "<>")
             ;; (ffap-user-p name):
             (not (string-match "~" (expand-file-name (concat "~" name))))
             )
        (setq name (concat "mailto:" name)))
       )
      (and (ffap-url-p name) name)
      ))))

(defun ido-visit-buffer (buffer method &optional record)
  "Switch to BUFFER according to METHOD.
Record command in `command-history' if optional RECORD is non-nil."
  (if (bufferp buffer)
      (setq buffer (buffer-name buffer)))
  (let (win newframe)
    (cond
     ((eq method 'kill)
      (if record
          (ido-record-command 'kill-buffer buffer))
      (kill-buffer buffer))

     ;; mmc:
     ((or (eq ido-exit 'other-window)
          (eq method 'other-window))
      (if record
          (ido-record-command 'switch-to-buffer buffer))
      (switch-to-buffer-other-window buffer))

     ((eq method 'display)
      (display-buffer buffer))

     ((eq method 'other-frame)
      (switch-to-buffer-other-frame buffer)
      (select-frame-set-input-focus (selected-frame)))

     ((eq method 'display-other-frame)
      (display-buffer-other-frame buffer))

     ((and (memq method '(raise-frame maybe-frame))
           window-system
           (setq win (ido-buffer-window-other-frame buffer))
           (or (eq method 'raise-frame)
               (y-or-n-p "Jump to frame? ")))
      (setq newframe (window-frame win))
      (select-frame-set-input-focus newframe)
      (select-window win))

     ;; (eq method 'selected-window)
     (t
      ;;  No buffer in other frames...
      (if record
          (ido-record-command 'switch-to-buffer buffer))
      (switch-to-buffer buffer)
      ))))

(defun ido-buffer-internal (method &optional fallback prompt default initial switch-cmd)
  ;; Internal function for ido-switch-buffer and friends
  (if (not ido-mode)
      (progn
        (run-hook-with-args 'ido-before-fallback-functions
                            (or fallback 'switch-to-buffer))
        (call-interactively (or fallback 'switch-to-buffer)))
    (setq ido-fallback nil)
    (let* ((ido-context-switch-command switch-cmd)
           (ido-current-directory nil)
           (ido-directory-nonreadable nil)
           (ido-directory-too-big nil)
           (ido-enable-virtual-buffers (and ido-use-virtual-buffers
                                            (not (eq ido-use-virtual-buffers 'auto))))
           (require-match (confirm-nonexistent-file-or-buffer))
           (buf (ido-read-internal 'buffer (or prompt "Buffer: ") 'ido-buffer-history default
                                   require-match initial))
           filename)

      ;; Choose the buffer name: either the text typed in, or the head
      ;; of the list of matches

      (cond
       ((eq ido-exit 'find-file)
        (ido-file-internal
         (if (memq method '(other-window other-frame)) method ido-default-file-method)
         nil nil nil nil ido-text))

       ((eq ido-exit 'insert-file)
        (ido-file-internal 'insert 'insert-file nil "Insert file: " nil ido-text 'ido-enter-insert-buffer))

       ((eq ido-exit 'fallback)
        (let ((read-buffer-function nil))
          (setq this-command (or ido-fallback fallback 'switch-to-buffer))
          (run-hook-with-args 'ido-before-fallback-functions this-command)
          (call-interactively this-command)))

       ;; Check buf is non-nil.
       ((not buf) nil)
       ((= (length buf) 0) nil)

       ;; View buffer if it exists
       ((get-buffer buf)
        (add-to-history 'buffer-name-history buf)
        (if (eq method 'insert)
            (progn
              (ido-record-command 'insert-buffer buf)
              (push-mark
               (save-excursion
                 (insert-buffer-substring (get-buffer buf))
                 (point))))
          (ido-visit-buffer buf
                            ;; mmc:
                            (if (eq ido-exit 'other-window)
                                'other-window
                              method)
                             t)))

       ;; check for a virtual buffer reference
       ((and ido-enable-virtual-buffers
             ido-virtual-buffers
             (setq filename (assoc buf ido-virtual-buffers)))
        (ido-visit-buffer (find-file-noselect (cdr filename)) method t))

       ((and (eq ido-create-new-buffer 'prompt)
             (null require-match)
             (not (y-or-n-p (format-message
                             "No buffer matching `%s', create one? " buf))))
        nil)

       ;; buffer doesn't exist
       ((and (eq ido-create-new-buffer 'never)
             (null require-match))
        (message "No buffer matching `%s'" buf))

       ((and (eq ido-create-new-buffer 'prompt)
             (null require-match)
             (not (y-or-n-p (format-message
                             "No buffer matching `%s', create one? " buf))))
        nil)

       ;; create a new buffer
       (t
        (add-to-history 'buffer-name-history buf)
        (setq buf (get-buffer-create buf))

        (if (fboundp 'set-buffer-major-mode)
            (set-buffer-major-mode buf))
        (ido-visit-buffer buf method t))))))

;; cmake:
(require 'cmake-mode)
(defconst cmake-regex-close-paren
  (rx-to-string `(and bol (* space) ,cmake-regex-paren-right)))

(defun cmake-indent ()
  "Indent current line as CMake code."
  (interactive)
  (unless (cmake-line-starts-inside-string)
    (if (bobp)
        (cmake-indent-line-to 0)
      (let (cur-indent)
        (save-excursion
          (beginning-of-line)
          (let ((point-start (point))
                (case-fold-search t)  ;; case-insensitive
                token)
            ; Search back for the last indented line.
            (cmake-find-last-indented-line)
            ; Start with the indentation on this line.
            (setq cur-indent (current-indentation))
            ; Search forward counting tokens that adjust indentation.
            (while (re-search-forward cmake-regex-token point-start t)
              (setq token (match-string 0))
              (when (or (string-match (concat "^" cmake-regex-paren-left "$") token)
                        (and (string-match cmake-regex-block-open token)
                             (looking-at (concat "[ \t]*" cmake-regex-paren-left))))
                (setq cur-indent (+ cur-indent cmake-tab-width)))
              (when (string-match (concat "^" cmake-regex-paren-right "$") token)
                (setq cur-indent (- cur-indent cmake-tab-width)))
              )
            (goto-char point-start)
            ;; If next token closes the block, decrease indentation
            (when (or (looking-at cmake-regex-close)
                      ;; mmc: add another case:
                      (looking-at cmake-regex-close-paren))
              (setq cur-indent (- cur-indent cmake-tab-width)))
            )
          )
        ; Indent this line by the amount selected.
        (cmake-indent-line-to (max cur-indent 0))
        )
      )
    )
  )

(provide 'mmc-patches)
