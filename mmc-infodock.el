
;; taken from infodock !!!
;; licence was/is gpl

(defun resize-window (&optional arg)
  "Resize window _interactively_.  a kind of electric mode"
  (interactive "p")
  (if (one-window-p) (error "(resize-window): Cannot resize sole window."))
  (let* ((last-window (car (reverse (window-list (selected-frame) nil (frame-first-window )))))
         (flexible-lower-edge-p (eq (selected-window) last-window))
	 c)
    (or arg (setq arg 1))
    (catch 'done
      (while t
        (let* ((event (read-event (format
                                   "h=heighten,s=shorten,w=widen,n=narrow (by %d); 1-9=unit,f/o=other frame/win,q=quit"
                                   arg))))

          (if (symbolp event)
              (progn
                (cond
                 ((equalp event 'return) (throw 'done t))))
            (progn
              (setq c (char-to-string event)))
            (condition-case ()
                (cond
                                        ;((eq c ?f) (other-frame 1))

                 ((string-equal c (kbd "C-g")) (keyboard-quit))
                 ((string-equal c (kbd "C-m")) (keyboard-quit))

                 ((string-equal c "h") (enlarge-window arg))


                 ((string-equal c "n") (shrink-window arg))


                 ((string-equal c "k")
                  (if flexible-lower-edge-p
                      (shrink-window arg)
                    (enlarge-window arg)))
                 ((string-equal c "i")
                  (if flexible-lower-edge-p
                      (enlarge-window arg)
                    (shrink-window arg)))


                 ((string-equal c "o") (other-window 1))
                 ((string-equal c "q") (throw 'done t))

                 ((string-equal c "l") (enlarge-window-horizontally arg))
                 ((string-equal c "f") (enlarge-window-horizontally arg))
                 ((string-equal c "j") (shrink-window-horizontally arg))

                                        ;((and (> c ?0) (<= c ?9)) (setq arg (- c ?0)))
                 (t (progn
                                        ;(beep)
                      (setq unread-command-events (list event))
                      (throw 'done 1))))
              (error (progn
                       (beep)
                       (throw 'done t))))))))))
; (message "Finished resizing windows")


(define-key global-map [(control x) ?^] 'resize-window)
(provide 'mmc-infodock)

