;;; This is to enter the URL for an `own' file.
;;; File-opening-completion is used to find
;;  the file on local FS, and URL is then created by rewriting.

(require 'url) ;; nil 'NOERROR)

;; todo:
;; have a `root' + read-root
;; then we look at the filename, substract `root' from it
;; and rewrite it to hostname+path.
;;


;; todo: Customize
;; (defcustom www-server-config :type directory)
(defvar www-server-config
  (list "/linux/2/var/www/maruska/htdocs"
        "ruska.dyndns.org")
  " (LOCAL-DIR  URL). Not alist yet.")



(defun insert-local-url (file)
  "insert an URL from my local File System"
  (interactive
   (list
    (read-file-name "Local file: " (nth 0 www-server-config))))
  (let ((host (nth 1 www-server-config))
        file-path)

    (string-match
     (concat (regexp-quote (nth 0 www-server-config))
             "\\(/.*\\)$")
                                        ;"~/h/maruska\\(/.*\\)$"
     file)
    (setq file-path (match-string 1 file))
    ;; FIXME: should use the `url'
    (insert (concat "http://" host "" file-path))))


(defun insert-local-url-michal ()
  "prompt for a file, and then insert a (public) URL for that."
  (interactive)
  (let ((www-server-config
         (list "/linux/2/var/www/maruska/michal"
               "michal.ruska.dyndns.org")))
    (call-interactively 'insert-local-url)))



;; (defconst www-server-root  "/linux/2/var/www/maruska/htdocs/")
;; "~/h/maruska/"


(global-set-key [(alt ?u)] 'insert-local-url)


;;; Is this copied from somewhere?

;; (w3-download-url
;; "http://linux1/embperl/tex/indirizzi/proposte.tex?uomo=12394&tipo=1200" "hello")
;; (www-url-find-file-noselect
;;  "http://linux1/embperl/tex/indirizzi/proposte.tex?uomo=12394&tipo=1200")

(defun www-url-find-file-noselect (path &rest args)
  "Find PATH without selecting its buffer.  Handle http urls."
  (if (listp path)
      (setq args (cdr path)
            path (car path)))
  (let ((inhibit-file-name-handlers
         (append '(dired-handler-fn efs-file-handler-function)
                 (and (eq inhibit-file-name-operation 'find-file-noselect)
                      inhibit-file-name-handlers)))
        (inhibit-file-name-operation 'find-file-noselect))
    (if (string-match "\\`www\\.\\|\\`https?:" path)
        (progn
          (require 'hsite)
          ;; Display url.
          (if (fboundp 'hact)
              (hact 'www-url path))
          ;; return same buffer
          (current-buffer))
      (apply 'find-file-noselect path args))))



(when nil
  (let ((url
         (url-generic-parse-url
          "http://linux1/embperl/tex/indirizzi/proposte.tex?uomo=12394&tipo=1200"))
        (url-http-asynchronous-p nil))
    (url-http  url 'insert-the-http-download (list (point-marker)))))


(defun insert-the-http-download (marker &rest args)
  "callback for URL to insert the downloade text at the MARKER."
  (search-forward-regexp "^$")

  (let ((http-buffer (current-buffer))
        (start (point))
        (end (point-max)))
    (set-buffer (marker-buffer marker))
    (insert-buffer-substring http-buffer start end)))

;; is that for gnome docs?
(defun search-selection-or-symbol (arg)
  "Prompt for a query term, and invoke web search in external browser"
  (interactive "p")
  (unless (and (local-variable-p 'search-prefix-default)
               search-prefix-default)
    (let* ((mode (symbol-name major-mode))
           (name (replace-regexp-in-string "-mode$" "" mode))
           (prefix (replace-regexp-in-string "-" " " name)))
      (set (make-local-variable 'search-prefix-default) prefix)))
  (let* ((prefix (if (= arg 1)
                     search-prefix-default
                   (setq search-prefix-default
                         (read-from-minibuffer "Set prefix: "
                                               search-prefix-default))))
         (query (read-from-minibuffer
                 "Search for: " (concat
                                 (if prefix (format "%s " prefix) "")
                                 (substring-no-properties
                                  (or (if (region-active-p)
                                          (buffer-substring (region-beginning)
                                                            (region-end))
                                        (thing-at-point 'symbol))
                                      "")))))
         (url (format "https://duckduckgo.com/?q=%s"
                      (url-hexify-string query))))
    (message "Searching %s" query)
    (browse-url url)))

(provide 'mmc-url)
