;;
;; (autoload 'sed-on-region "sed.el" "" 't)
;; (autoload 'latin->cyrillic "sed.el" "" 't)
;; (global-set-key [ (control ?x) ?| ] 'latin->cyrillic)



;; You need to set the SEDPATH environment !
;;

;; (defvar sed-on-region-history
;;   (make-symbol "sed-on-region-history")
;;   "")

(defconst maruska-sed-dir "/usr/share/maruska/sed/" "path to SED scripts")

(defun latin->cyrillic (start end)
  "convert (transliteration) buffer text to cyrillic."
  (interactive "r")
  (sed-on-region start end 't		;
		 (compose-path maruska-sed-dir
			       "russo-utf8.sed")
		 'utf-8 ;;cyrillic-iso-8bit
		 'iso-8859-1))

(defun cyrillic->latin (start end)
  ""
  (interactive "r")
  (sed-on-region start end 't (compose-path maruska-sed-dir "de_russo.sed")
		 'cyrillic-iso-8bit))


(defun utf-cyrillic->latin (start end)
  ""
  (interactive "r")
  (sed-on-region start end 't (compose-path maruska-sed-dir "de-russo-utf8.sed")
                 ;'utf-8
                 'no-conversion
                 ;'raw-text
                 ;'emacs-mule
                 'utf-8
                 ))



(global-set-key [f5] 'latin->cyrillic)
(global-set-key [(shift f5)] 'cyrillic->latin)

(global-set-key [(control f5)] 'utf-cyrillic->latin)


; (member 'cyrillic-iso-8bit coding-system-list)



(defun sed-on-region (start end &optional prefix sed-file coding-system
			    ouput-coding-system)
  "Process the region through SED(1) and replace with the result.
Coding system and the 'sed -f' file are read from minibuffer."
  (interactive                          ;"rp"
   (list (mark) (point)
         current-prefix-arg             ; prefix-arg
         (read-file-name "sed -f " (getenv "SEDPATH"))
         (read-coding-system "coding system (koi8): " 'koi8)))
  (message "sed-on-region %d %d" start end)
  ;; replace ??
  (let ((coding-system-for-read coding-system)
        (coding-system-for-write (or ouput-coding-system 'no-conversion)))
    ;; Could be different !!! coding-system
    (print prefix)
    (if prefix
        (progn
          (message "replace !")
          (shell-command-on-region
           start end
           (format "sed -f %s" sed-file)
           ;"cat > /tmp/sed.output"
           (current-buffer) prefix))
      (message "don't replace!")
      (shell-command-on-region
       start end
       (format "sed -f %s " sed-file)))))

;;doesn't work !!
(require 'mmc-region)
(define-key ctl-x-r-map "S" 'sed-on-region)

;(autoload 'sed-on-region "sed.el" "" 't)
;(autoload 'latin->cyrillic "sed.el" "" 't)
;(global-set-key [ (control ?x) ?| ] 'latin->cyrillic)


(provide 'mmc-sed)
