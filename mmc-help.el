;;; Help

(defun find-function-by-key ()
  "very handy, isn't it?"
  (interactive)
  (find-function (key-binding (read-key-sequence "key: "))))

(define-key help-map "E" 'find-function-by-key)
(define-key help-map "a" 'apropos)
(define-key help-map "o" 'top-level)
;find-function-by-key

(global-set-key [(control return)] 'dabbrev-expand)

(defun my-explain-keys ()
  "Read key-sequences and describe their binding. The problem is to stay in the buffer (modes...) and swith to.."
  ;; TODO: i could stop after reading (C-g)
  (interactive)
  (let ((trials 20)
        key modifiers
        (buffer (get-buffer-create "*explain-keys*"))
        function
        (current-buffer (current-buffer)))
    (display-buffer buffer)
    (with-current-buffer buffer
      (erase-buffer))
    (bury-buffer buffer)
    (while (and
            (> trials 0)
            (not (equal key ""))) ;; [(control ?g)]
      (setq key (read-key-sequence "key sequence: " 't 't 't 't)
            function (key-binding key)
            modifiers (event-modifiers (aref key 0)))
      ;;(lookup-key key)
      (with-current-buffer buffer
        (insert (key-description key))
        (insert "\t\t")
        (pp function buffer)
        ;;(describe-key-briefly key 't)
        (insert "\n"))
      (sleep-for 0)
      (redraw-frame (selected-frame))   ;redisplay-device
      (setq trials (1- trials)))
    (beep)))


(key-binding "\C-a")

;; problematic: (maybe no more)
(unless running-xemacs
  (if (under-x)
      (global-set-key [(control ?h) (shift ?k)] 'my-explain-keys)))


; prefix-help-command
(defun describe-prefix-bindings-and-continue ()
  ""
  (interactive)
  (describe-prefix-bindings)
  (message "ok")
  (setq unread-command-events "C-x"))

(setq prefix-help-command 'describe-prefix-bindings-and-continue)
; unread-command-events
(setq apropos-do-all 't)




(provide 'mmc-help)
