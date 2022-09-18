(require 'mmc-minibuffer)
;;; read numbers:
;; todo: match-string .. replace-match ..
(defun read-number-increment (&optional arg)
  (interactive)
  (or arg (setq arg 1))
  (let ((string (minibuffer-contents)))
    (delete-minibuffer-contents)
    (insert (int-to-string (+ (string-to-number string) arg)))))

(defun read-number-decrement (&optional arg)
  (interactive)
  (or arg (setq arg 1))
  (read-number-increment (- arg)))


(defconst read-number-map (make-sparse-keymap) "")
(let ((map read-number-map))
  (set-keymap-parent map minibuffer-local-map)

  (define-key map [(control ?<)] 'read-number-decrement) ;"C-n"
  (define-key map [(control ?>)] 'read-number-increment)

  (define-key map "<" 'read-number-decrement) ;"C-n"
  (define-key map ">" 'read-number-increment)
  ;;(define-key map [(control ?n)] 'read-number-decrement) ;"C-n"
  ;;(define-key map [(control ?p)] 'read-number-increment) ;"C-n"
  ;;(define-key map "C-p" 'read-number-decrement)
  )

;;fixme: use `def-advice'!
(defun read-number (prompt &optional init-state def history)
  ""
  (with-keymaps-switched* 'minibuffer-local-map read-number-map
                                        ;(lambda ()
      (let ((init
             (if (consp init-state)
                 (cadr init-state)
               init-state)))
        (string-to-number
         (read-string (format "%s (%s) " prompt def)
                      ;; initial?
                      "" ;(if (numberp init) (int-to-string init) init)
                      history def)))))

;(read-number "group:" 1 1 nil)

(provide 'mmc-read-number)
