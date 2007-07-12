;; (erc-select)

;(require 'erc)
;(setq erc-modules '())  ;(fill track completion ring button)

;;; needed _before_  erc.el
(defun erc-update-header-line (symbol value)
  "customization hook for `erc-header-line-format'"
  ;;custom-set-default
  (set symbol value)
  (save-excursion
    (mapc
     (lambda (buffer)
       (with-current-buffer buffer
         (setq ;mode-line-format
          header-line-format
          (erc-prepare-mode-line-format value))
         (force-mode-line-update 't)))
     (erc-buffer-list))))

(custom-set-variables
 '(erc-header-line-format '("[IRC] " nick " on " target " " channel-modes " " channels topic) t))

(setq erc-auto-query 'bury)

;;; `soft' Customization:
(setq erc-server-history-list '("localhost" "vinge.freenode.net")) ;irc
(when t
  (setq erc-user-full-name "Michal Maruska (http://michal.maruska.dyndns.org/)")
  (setq erc-email-userid "erc@maruska.dyndns.org")
  )
(when nil
  (setq erc-user-full-name "Elisabetta de Carli")
  (setq erc-email-userid "")
  )

;;;
;(require 'erc-auto)
(run-wo-fail
 (require 'erc-ring)
 (erc-ring-mode 1))


;;;   color nicks
(require 'color-space)



(add-hook 'after-init-hook
  (lambda ()
    ;; i want to run it when the background color is set.
    (when (under-x)
      (sit-for 1)
      ;; ugly hack:  This _will_ happen after this hook.
      ;; consider initial-frame-alist !!!!
      (if (aget default-frame-alist 'background-color 'nil)
          (modify-frame-parameters (selected-frame)
                                   (list
                                    `(background-color
                                      . ,(aget default-frame-alist 'background-color 'nil)))))
      (message "Re-Calc the color grid")
      (color-grid-init))))

(defun erc-match-message ()
  "Mark certain keywords in a region.
Use this defun with `erc-insert-modify-hook'."
  ;; This needs some refactoring.
  (goto-char (point-min))
  (let* ((to-match-nick-dep '("pal" "fool" "dangerous-host")) ; depends on nickname
	 (to-match-nick-indep '("keyword" "current-nick")) ;  doesn NOT depent on nickname
	 (vector (erc-get-parsed-vector (point-min)))
	 (nickuserhost (erc-get-parsed-vector-nick vector))
     (channel (if vector
                  (aref vector 2)
                nil))
	 (nickname (and nickuserhost
			(nth 0 (erc-parse-user nickuserhost))))
	 (old-pt (point))
	 (nick-beg (and nickname
                    ;(re-search-forward (regexp-quote nickname)
                    (search-forward nickname
					   (point-max) t)
			(match-beginning 0)))
	 (nick-end (when nick-beg
		     (match-end 0)))
	 (message (buffer-substring (if (and nick-end
					     (<= (+ 2 nick-end) (point-max)))
					(+ 2 nick-end)
				      (point-min))
				    (point-max))))

    ;;; implicit color
     (when (and nick-beg nick-end nickname)
       (erc-put-text-property
        nick-beg nick-end
        'face
        (string->face nickname)         ;new-
        (current-buffer)))

    (when vector
      (mapc
       (lambda (match-type)
         ;; 
         (goto-char (point-min))
         (let* ((match-prefix (concat "erc-" match-type))
                (match-pred (intern (concat "erc-match-" match-type "-p")))
                (match-htype (eval (intern (concat match-prefix
                                                   "-highlight-type"))))
                (match-regex (if (string= match-type "current-nick")
                                 (erc-current-nick)
                               (eval (intern (concat match-prefix "s")))))
                (match-face (intern (concat match-prefix "-face"))))
           (when (funcall match-pred nickuserhost message)
             (cond
              ((and (eq match-htype 'nick)
                    nick-end)
               (erc-put-text-property
                nick-beg nick-end
                'face match-face (current-buffer)))
              ((eq match-htype 'all)
               (erc-put-text-property
                (point-min) (point-max)
                'face match-face (current-buffer)))

              ((and (string= match-type "keyword")
                    (eq match-htype 'keyword))
               (mapc (lambda (elt)
                       (let ((regex elt)
                             (face match-face))
                         (when (consp regex)
;;---
                           (setq regex (car elt)) ;  (regexp #channel face)
                           (if (facep (cdr elt))
                               (setq face (cdr elt))
                             (if (string= (cdr elt) (downcase channel)) ; (lowercase 
                                 (setq regex '()))))
                         (when regex
;; ---                           
                           (goto-char (+ 2 (or nick-end
                                             (point-min))))
                           (while (re-search-forward regex nil t)
                           (erc-put-text-property
                            (match-beginning 0) (match-end 0)
                            'face face)))))
                     match-regex))
              ((and (string= match-type "current-nick")
                    (eq match-htype 'nick))
               (goto-char (+ 2 (or nick-end
                                   (point-min))))
               (while (re-search-forward match-regex nil t)
                 (erc-put-text-property (match-beginning 0) (match-end 0)
                                        'face match-face)))
              (t nil))
             (run-hook-with-args
              'erc-text-matched-hook
              (intern match-type)
              (or nickuserhost
                  (concat "Server:" (erc-get-parsed-vector-type vector)))
              message))))
       (if nickuserhost
           (append to-match-nick-dep to-match-nick-indep)
         to-match-nick-indep)))))



(define-key erc-mode-map (kbd "C-c f") 'color-norm)
(require 'erc-match)
(erc-match-mode 1)

(require 'erc-track)
(erc-track-mode 1)
(global-set-key (kbd "C-:") 'erc-track-switch-buffer)
(setq erc-track-exclude-types '("JOIN" "NICK" "PART" "QUIT"))
(setq erc-track-switch-direction 'oldest)


(defun erc-modified-channels-display ()
  "Set `erc-modified-channels-string'
according to `erc-modified-channels-alist'.
Use `erc-make-mode-line-buffer-name' to create buttons."
  (if (or
       (eq 'mostactive erc-track-switch-direction)
       (eq 'leastactive erc-track-switch-direction))
      (erc-track-sort-by-activest))
  (if (null erc-modified-channels-alist)
      (setq erc-modified-channels-string "")
    ;; erc-modified-channels-alist contains all the data we need.  To
    ;; better understand what is going on, we split things up into
    ;; four lists: BUFFERS, COUNTS, SHORT-NAMES, and FACES.  These
    ;; four lists we use to create a new
    ;; `erc-modified-channels-string' using
    ;; `erc-make-mode-line-buffer-name'.
    (let* ((buffers (mapcar 'car erc-modified-channels-alist)) ; last ..... 1st signalled
           (counts (mapcar 'cadr erc-modified-channels-alist))
           (faces (mapcar 'cddr erc-modified-channels-alist))
           (long-names (mapcar 'buffer-name buffers)) ;    last -> 1
           (short-names (if (functionp erc-track-shorten-function)
                            (funcall erc-track-shorten-function
                                     long-names)
                          long-names))
           strings)
      (while buffers
        ;; 1-> last
        (setq strings (cons (erc-make-mode-line-buffer-name
                             (car short-names)
                             (car buffers)
                             (car faces)
                             (car counts))
                            strings)
              short-names (cdr short-names)
              buffers (cdr buffers)
              counts (cdr counts)
              faces (cdr faces)))
      (setq erc-modified-channels-string
            ;; 
            (concat "[" (mapconcat 'identity strings ",") "] "))))) ; mmc removed  reverse



;(require 'erc-auto)
(require 'erc-pcomplete)
(erc-pcomplete-mode 1)
;(pcomplete-erc-setup)


(require 'erc-button)
(erc-button-mode -1)

;;

(setq erc-notice-highlight-type 'prefix)
;(erc-default-face

(define-key erc-mode-map (kbd "C-c f") 'color-norm)
(define-key erc-mode-map (kbd "C-c =") 'face-at-point)

'(if (under-x)
    (set-face-font 'default "-*-lucidatypewriter-medium-r-*-*-24-*-*-*-*-*-iso8859-*"))


;(my-read-buffer-name "irc: " (mapcar (lambda (buffer) (cons (buffer-name buffer) buffer)) (buffers-in-mode 'erc-mode)))

;(require isw
;(define-key erc-mode-map [(control ?c) ?b] 'erc-iswitchb)



(require 'erc-dcc)
(setq erc-dcc-verbose 'nil)


(require 'erc-stamp)
(erc-timestamp-mode 1)
(setq erc-timestamp-only-if-changed-flag nil
      erc-timestamp-format "%H:%M "
      erc-fill-prefix "      "
      erc-insert-timestamp-function 'erc-insert-timestamp-left)




(setq erc-header-line-format
      '("[IRC:] " nick " on " target " " channels " " topic))
;(erc-current-nick)



(defun add-string-properties (string properties)
  "add the PROPERTIES to entire STRING, return string"
  (add-text-properties 0 (length string) properties string)
  string)



(defun erc-switch-to-buffer ()
  "read events(chars), and switch to appropriate erc buffer"
  (interactive)
  (let ((buffers (erc-channel-list nil))
        buffer
        (index))
    (catch 'exit
      ;;  lookup-key 
      (while (let* ((event (read-event "channel #: "))
                    (char (char-to-string event)))
               (setq buffer
                     (cond ((string-match "[a-z]" char)
                            ;; letters -> ??
                            (aget '(("e" . "#emacs")
                                    ("a" . "#sane")
                                    ("C" . "#c")
                                    ("+" . "#c++")
                                    ("d" . "#darcs") ;ebian
                                    ("s" . "#scheme")
                                    ("g" . "#gtk+") ;entoo
                                    ("p" . "#postgresql")
                                    ("j" . "#java")
                                    ("w" . "#suspend2")
                                    ("D" . "#debian-devel")
                                    ("x" . "#xfs") ;free86-devel
                                    ("k" . "#kde")
                                    ("c" . "#scsh")
                                    ("f" . "#sawfish")
                                    ;("r" . "#arch")
                                    ("r" . "#freedesktop")
                                    ("z" . "#zsh")
                                    ("m" . "#math")
                                    )
                                  char 't)
                            ;; by 1st letter !

                            )
                           ((string-match "[0-9]" char)
                            (nth (string-to-int char) buffers))
                           ('t
                            (setq unread-command-events
                                  (list event))
                            (throw 'exit 1)
                            )))
               (switch-to-buffer buffer))))))

;(number "1")
;(string-to-int (char-to-string (read-event "channel #: ")))


(define-key erc-mode-map [(meta ?g)] 'erc-switch-to-buffer)
(define-key erc-mode-map [(alt ?v)] 'erc-switch-to-buffer)
(define-key erc-mode-map (kbd "\C-C\C-j") nil) ; i have mine ...

;;(kbd "\M-g")


;(binclock-to-binary -134217676)
;byte-optimize-binary-predicate



;;; trash:
'(defun erc-unmorse ()
  (goto-char (point-min))
  (when (re-search-forward "[.-]+\\([.-]+[/ ]\\)+[.-]+" nil t)
    (unmorse-region (match-beginning 0) (match-end 0))
    (insert " [morse]")))


(add-hook 'erc-send-pre-hook
          (lambda (str)
            (or (string-match "\\.$" str)
                (setq str (concat str ".")))))


;; '(erc-keywords (quote ("mmc" "x?emacs" "sawfish" "maruska")))

(setq erc-keywords
      '(("\\b\\(open\\)?afs\\b" . "#openafs")
        "\\bmmc\\b"
        "\\bmerriam\\b"
        "\\bxfree\\(86\\)?\\b"
        ;; "\\bschmorp\\b"
        "\\bkasal\\b"
        "\\bneilv\\b"
        ;"\\bJackaLX\\b"
        ;;("\\bx?emacs\\b" . "#emacs") ; too much 
        ("\\bxemacs\\b"  . "#emacs")
                                        ;("xfree" . "#xfree86")
                                        ;("\\bsawfish\\b" . "#sawfish")
        ("\\bpostgres\\(ql\\)\\b" . "#postgresql")
        ("\\bscheme\\b" . "#scheme")    ; #kde-devel  
        ("\\bscsh\\b" . "#scsh")
        "\\bmaruska\\b"
        ("\\bgauche\\b" . "#gauche")
        ;"\\b(iptables\\|firewall\\|netfilter)\\b"
        ))


(setf erc-default-coding-system (quote (utf-8 . utf-8)))
;(setf erc-encoding-coding-alist (quote (("#emacsfr" . iso-8859-15))))
;; only this?
(setq erc-encoding-coding-alist
      '(("#postgresql" . utf-8)
        ("#emacs" . compound-text)
        ("#debian-russian" . koi8-r)
        ("#gentoo-ru" . cyrillic-koi8)
        ("#russian" . cyrillic-koi8)
        ))

;prefer-coding-system
; locale-preferred-coding-systems
(aput 'locale-preferred-coding-systems
      "cyrillic.*" 'cyrillic-iso-8bit)

;;; my patches:

(defcustom erc-header-line-format
  '("[IRC] " nick " on " target
    " " channel-modes " " topic)
  "Format of the header-line in erc-mode.
Only used in Emacs 21. This variable is processed using
`erc-prepare-mode-line-format'."
  :group 'erc
  :set 'erc-update-header-line
  :type 'sexp)



;; my-version
(defun erc-prepare-mode-line-format (line)
  "Replace certain symbols in LINE by data acquired from the current
erc-mode buffer. The following symbols are recognized:
'away: String indicating away status or \"\" if you are not away
'channel-modes: The modes of the channel
'nick: The current nick name
'port: The session port
'status: \" (CLOSED) \" in case the process is no longer open/run
'target: The name of the target (channel or nickname or servername:port)
'target-and/or-server: In the server-buffer, this gets filled with the
		       value of erc-announced-server-name,
		       in a channel, the value of (erc-default-target) also
		       get concatenated.
'topic: The topic of the channel"
  (let ((away (when (and (boundp 'erc-process)
                         (processp erc-process))
                (with-current-buffer (process-buffer erc-process)
                  away))))
    (mapcar
     (lambda (sym)
       (cond ((eq sym 'nick)
              (add-string-properties (erc-current-nick) '(face erc-current-nick-face)))
             ((eq sym 'target)
              (let ((target (erc-default-target)))
                (if target
                    (add-string-properties target '(face erc-keyword-face))
                  (concat (erc-shorten-server-name
                           (if (boundp 'erc-announced-server-name)
                               erc-announced-server-name
                             erc-session-server))
                          ":" (erc-port-to-string erc-session-port)))))
             ((eq sym 'port)
              (erc-port-to-string erc-session-port))
             ((eq sym 'status)
              (if (erc-process-alive)
                  ""
                " (CLOSED) "))
             ((eq sym 'channel-modes)
              (concat (apply 'concat
                             "(+" channel-modes)
                      (if channel-user-limit
                          (format "l %.0f" channel-user-limit) ; Emacs has no BIGNUMs
                        "")
                      ")"))
             ((eq sym 'away)
              (if away
                  (concat " (AWAY since "
                          (format-time-string "%a %b %d %H:%M" away)
                          ") ")
                ""))
             ((eq sym 'topic)
              (erc-interpret-controls channel-topic))

             ((eq sym 'channels)
              (concat
               (mapconcat
                (lambda (buffer)
                  (erase-text-properties (buffer-name buffer))
                  (add-string-properties
                   (copy-sequence (buffer-name buffer)) '(face bg:erc-color-face3)))
                (erc-channel-list nil) "|" )
               " "))

             ((eq sym 'target-and/or-server)
              (let ((server-name (erc-shorten-server-name
                                  (if (boundp 'erc-announced-server-name)
                                      erc-announced-server-name
                                    erc-session-server))))
                (if (erc-default-target)
                    (concat (erc-default-target) "@" server-name)
                  server-name)))
             (t
              sym)))
     line)))


(defun unerc-region (beg end)
  (interactive "r")
  (save-excursion
    (save-restriction
      (narrow-to-region beg end)
      (goto-char (point-max))
      (beginning-of-line)
      (skip-chars-forward "^>")
      (forward-char 2)
      (delete-rectangle (point-min) (point)))))



(require 'erc-intersection)
;(define-key erc-mode-map (kbd "\C-c?") 'erc-display-intersection)
(define-key erc-mode-map [(control ?c) ?i] 'erc-nick-at-point)


;; Debugger entered--Lisp error: (error "SIGPIPE raised on process dcc-get; closed it")
;;  process-send-string(#<process dcc-get> "  T™")
;;  erc-dcc-get-filter(#<process dcc-get> "t\n#\n# CONFIG_BLUEZ is not set\n\n#\n# Kernel hacking\n#\n# CONFIG_DEBUG_KERNEL is not set\n\n#\n# Library routines\n#\nCONFIG_ZLIB_INFLATE=m\nCONFIG_ZLIB_DEFLATE=m\n")



(setq erc-fill-column (- (screen-width) 10))


(define-key erc-mode-map [(control ?a)] 'mmc-bol)

(require 'erc-kill)
(define-key erc-mode-map [(meta ?w)] 'erc-copy-region-wo-field)


(defun skip-text-property (prop max)
  ""
  (if (get-text-property (point) prop)
      (progn
        (goto-char (or (next-single-property-change (1+ (point)) prop nil max)
                   max))
        't)
    nil))

(defun mmc-bol ()
  (interactive)
  (erc-bol)
  (if (skip-text-property 'field (point-at-eol))
      (forward-char 1)))



(defun erc-insert-join-command ()
  "produce the IRC command to restore my connections. 1 server, though."
  (interactive)
  (insert
   (concat "/JOIN " (join-string (mapcar 'buffer-name (erc-channel-list nil)) ","))))

; /JOIN #sawfish,#scsh,#scheme,#gentoo,#postgresql,#emacs,#qt,#kde-devel,#kexi,#koffice,#arch,#zsh,#xemacs,#pthreads,#xfree86-devel,#gentoo-portage,#openafs,#berkeleydb,#coda


;;  \\(..\|..\|..\\)

;regexp-opt

;(mapconcat 'regexp-quote strings "\\|")


(setq erc-prompt-for-password nil)




;;;  `intensive' tracking
(defconst my-popup-erc-buffer-list '("cyfred")
  "erc channels, whose traffic i want to see, immediately")
;;"#gentoo"


(defun toggle-in-list (list-symbol atom)
  ""
  (if (member atom (symbol-value list-symbol))
      (set list-symbol
           (delete atom (symbol-value list-symbol)))
    (add-to-list list-symbol atom)))




(defun erc-add-channel-to-popup-list (channel &rest nick)
  ""
  (interactive (erc-interactive-channel))
  ;; toggle !!
  (toggle-in-list 'my-popup-erc-buffer-list channel)
  (message "intensive tracking: %s" my-popup-erc-buffer-list))

(define-key erc-mode-map (kbd "C-c !") 'erc-add-channel-to-popup-list)

(defun my-popup-erc-buffer ()
  "called from `erc-insert-post-hook', current-buffer is ..."
  (let ((this-channel (erc-default-target)))
    (if (member this-channel my-popup-erc-buffer-list)
        (display-buffer (current-buffer)))))


(add-hook 'erc-insert-post-hook 'my-popup-erc-buffer)

;;;  keywords
(defun erc-regexp-for-keywords-in (channel)
  ""
  (concat "\\("
          (mapconcat
           (lambda (keyword)
             (if (stringp keyword)
                 keyword
               (car keyword)))
           erc-keywords
           "\\|")
          "\\)"))

(defun erc-search-keyword-backward ()
  ""
  (interactive)
  (let ((regexp (erc-regexp-for-keywords-in (erc-current-channel))))
    ;(kill-new regexp)
    ;(call-interactively 'isearch-backward-regexp)))
    (search-backward-regexp regexp nil ))) ; noerror 't

(defun erc-search-keyword-forkward ()
  ""
  (interactive)
  (let ((regexp (erc-regexp-for-keywords-in (erc-current-channel))))
    (search-forward-regexp regexp nil 't)))

;;(kill-new regexp)
;;(call-interactively 'isearch-backward-regexp)))


(define-key erc-mode-map (kbd "C-c C-p") 'erc-search-keyword-backward)
(define-key erc-mode-map (kbd "C-c C-n") 'erc-search-keyword-forkward)

;(isearch-backward-regexp








;;; limit the size:

(setq erc-max-buffer-size 300000)
; *Maximum size of each ERC buffer.  Used only when auto-truncation is enabled.
;(see `erc-truncate-buffer' and `erc-insert-post-hook').

;; from erc.el
(add-hook 'erc-insert-post-hook 'erc-truncate-buffer nil nil)
; erc-insert-post-hook
;(make-local-hook 'erc-insert-post-hook)



(setq erc-auto-query 'window-noselect)


(defmacro asf-erc-bouncer-connect (command server port nick ssl pass)
  "Create interactive command `command', for connecting to an IRC server. The
    command uses interactive mode if passed an argument."
  (fset command
        `(lambda (arg)
           (interactive "p")
           (if (not (= 1 arg))
               (erc-select ,server ,port ,nick)
             (let ((erc-connect-function ',(if ssl
                                               'open-ssl-stream
                                             'open-network-stream)))
               (erc ,server ,port ,nick ,erc-user-full-name t ,pass))))))


;; hopefully o-r:
;; fixme: 
(load "~/activity/emacs/erc-passwords" 'no-error)
;; (let ((file (ffap-locate-file "erc-passwords"))
;;       )
;;   (if (file-readable-p file)
;;       (load file )))


(if (and (under-x)
	 (facep 'erc-default-face)
	 (face-foreground 'erc-default-face))

    (color-distance
     (color->rgb (face-foreground 'erc-default-face))
     (color->rgb (face-background 'modeline))))

;;; erc-track
;; mmc:      better face foreground in mode-line 
(defun erc-make-mode-line-buffer-name (string buffer &optional faces count)
  "Return STRING as a button that switches to BUFFER when clicked.
If FACES are provided, color STRING with them."
  ;; We define a new sparse keymap every time, because 1. this data
  ;; structure is very small, the alternative would require us to
  ;; defvar a keymap, 2. the user is not interested in customizing it
  ;; (really?), 3. the defun needs to switch to BUFFER, so we would
  ;; need to save that value somewhere.
  (let ((map (make-sparse-keymap))
	(name (if erc-track-showcount
		  (concat string
			  erc-track-showcount-string
			  (int-to-string count))
		(copy-sequence string))))
    (define-key map (vector 'mode-line 'mouse-2)
      `(lambda (e)
	 (interactive "e")
	 (save-selected-window
	   (select-window
	    (posn-window (event-start e)))
	   (switch-to-buffer ,buffer))))
    (put-text-property 0 (length name) 'local-map map name)
    (when (and faces erc-track-use-faces) ;(setq erc-track-use-faces 't)
      ;; (if (face-foreground ) (face-background 'modeline)
      (put-text-property 0 (length name) 'face
                         (if (eq faces 'erc-default-face)
                             ;'erc-pal-face ;erc-fool-face ;erc-current-nick-face
                             (list :foreground "dark red" :weight 'bold)
                             faces)
                         name))
    name))


(defun erc-match-message ()
  "Mark certain keywords in a region.
Use this defun with `erc-insert-modify-hook'."
  ;; This needs some refactoring.
  (goto-char (point-min))
  (let* ((to-match-nick-dep '("pal" "fool" "dangerous-host")) ; depends on nickname
	 (to-match-nick-indep '("keyword" "current-nick")) ;  doesn NOT depent on nickname
	 (vector (erc-get-parsed-vector (point-min)))
	 (nickuserhost (erc-get-parsed-vector-nick vector))
     (channel (aref vector 2))
	 (nickname (and nickuserhost
			(nth 0 (erc-parse-user nickuserhost))))
	 (old-pt (point))
	 (nick-beg (and nickname
                    ;(re-search-forward (regexp-quote nickname)
                    (search-forward nickname
					   (point-max) t)
			(match-beginning 0)))
	 (nick-end (when nick-beg
		     (match-end 0)))
	 (message (buffer-substring (if (and nick-end
					     (<= (+ 2 nick-end) (point-max)))
					(+ 2 nick-end)
				      (point-min))
				    (point-max))))

    ;;; implicit color
     (when (and nick-beg nick-end nickname)
       (erc-put-text-property
        nick-beg nick-end
        'face
        (string->face nickname)         ;new-
        (current-buffer)))

    (when vector
      (mapc
       (lambda (match-type)
         ;; 
         (goto-char (point-min))
         (let* ((match-prefix (concat "erc-" match-type))
                (match-pred (intern (concat "erc-match-" match-type "-p")))
                (match-htype (eval (intern (concat match-prefix
                                                   "-highlight-type"))))
                (match-regex (if (string= match-type "current-nick")
                                 (erc-current-nick)
                               (eval (intern (concat match-prefix "s")))))
                (match-face (intern (concat match-prefix "-face"))))
           (when (funcall match-pred nickuserhost message)
             (cond
              ((and (eq match-htype 'nick)
                    nick-end)
               (erc-put-text-property
                nick-beg nick-end
                'face match-face (current-buffer)))
              ((eq match-htype 'all)
               (erc-put-text-property
                (point-min) (point-max)
                'face match-face (current-buffer)))

              ((and (string= match-type "keyword")
                    (eq match-htype 'keyword))
               (mapc (lambda (elt)
                       (let ((regex elt)
                             (face match-face))
                         (when (consp regex)
;;---
                           (setq regex (car elt)) ;  (regexp #channel face)
                           (if (facep (cdr elt))
                               (setq face (cdr elt))
                             (if (string= (cdr elt) (downcase channel)) ; (lowercase 
                                 (setq regex '()))))
                         (when regex
;; ---                           
                           (goto-char (+ 2 (or nick-end
                                             (point-min))))
                           (while (re-search-forward regex nil t)
                           (erc-put-text-property
                            (match-beginning 0) (match-end 0)
                            'face face)))))
                     match-regex))
              ((and (string= match-type "current-nick")
                    (eq match-htype 'nick))
               (goto-char (+ 2 (or nick-end
                                   (point-min))))
               (while (re-search-forward match-regex nil t)
                 (erc-put-text-property (match-beginning 0) (match-end 0)
                                        'face match-face)))
              (t nil))
             (run-hook-with-args
              'erc-text-matched-hook
              (intern match-type)
              (or nickuserhost
                  (concat "Server:" (erc-get-parsed-vector-type vector)))
              message))))
       (if nickuserhost
           (append to-match-nick-dep to-match-nick-indep)
         to-match-nick-indep)))))



;; /JOIN #sawfish,#debian-kde,#gentoo,#scsh,#kahakai,#xlib,#emacs,#xfree86,#debian,#postgresql,#arch,#openafs,#scheme,#zsh,#xemacs,#pthreads,#sane,#xfree86-devel,#berkeleydb

(when nil
  (insert
   (concat
    ";; /JOIN "
    (mapconcat (lambda (info)
                 (buffer-name info))
               (erc-channel-list nil)
               ", ")))
  )

;; /JOIN #darcs, #gentoo-security, #gentoo-amd64, #gentoo-embedded, #gentoo-desktop-research, #breakmygentoo

;; /JOIN #lisp, #arch, #zsh, #xwin, #gtk+, #freedesktop, #kde-devel, #c++, #scsh, #xlib, #xfs, #elinks, #math, #swsusp, #postgresql, #emacs, #scheme, #gentoo, #sml, #sawfish
;; /JOIN #sawfish,#sml,#gentoo,#scheme,#emacs,#postgresql,#swsusp,#math,#elinks,#xfs,#xlib,#scsh,#c++,#kde-devel,#freedesktop,#gtk+,#xwin,#zsh,#arch,#lisp


;; cyrilic:
;  erc.el    target ..
; erc-parse-line-from-server  ....





;; errors:

(defun erc-wash-quit-reason (reason nick login host)
  "Remove duplicate text from quit REASON.
Specifically in relation to NICK (user@host) information.  Returns REASON
unmodified if nothing can be removed.
E.g. \"Read error to Nick [user@some.host]: 110\" would be shortened to
\"Read error: 110\". The same applies for \"Ping Timeout\"."
  (or (when (string-match (concat "^\\(Read error\\) to "
				  (regexp-quote nick) "\\[" (regexp-quote host) "\\]: "
				  "\\(.+\\)$") reason)
	(concat (match-string 1 reason) ": " (match-string 2 reason)))
      (when (string-match (concat "^\\(Ping timeout\\) for "
				  (regexp-quote nick) "\\[" (regexp-quote host) "\\]$") reason)
	(match-string 1 reason))
      reason))


(provide 'mmc-erc)
