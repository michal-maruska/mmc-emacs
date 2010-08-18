(require 'time-stamp)

(require 'mmc-keys)


;; I wonder why this function is not standard in ..
(defun insert-date (arg)
  "insert the today's date at the point. To avoid the default format, use C-u/4 prefix, and edit the function name. To enclose use prefix"
  (interactive "P")
  (let ((command "time-stamp-yyyy-mm-dd") 
	(brackets (cons "[" "]")))
    ;; 
    (if (= (prefix-numeric-value arg) 4)
	(setq command (completing-read 
		       "command: "
		       obarray 'functionp 't "time-stamp-dd-mon-yy")))
    ;;(insert (time-stamp-dd-mon-yy))
    (insert
     (if arg (car brackets) "")
     (funcall (intern command))
     (if arg (cdr brackets) ""))))

(define-key my-global-keymap "D" 'insert-date)
(define-key global-map [(control ?A)] 'insert-date)


(defun time (form)
  "measure how much time the given FORM executes, sort of time(1) in Emacs, 
very old/simple/ don't use it"
  (let ((start (nth 1 (current-time))) 
	end)
    (eval form)
    (setq end (nth 1 (current-time)))
    (message "time: %d" (- end start))))

;(time '(cons 1 2))

; (time
;  (w3-parse-buffer  "page1.html")
;  )


(provide 'mmc-time)

