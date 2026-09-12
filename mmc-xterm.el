(require 'mmc-display)

;;;### Autoload
(defun xterm (&optional arg command title)
  "open an xterm on the DISPLAY where FRAME is. With prefix, ask for the DISPLAY."
  (interactive "P")
  ;; without this message I get segfault! when byte-compiled, of course.
  (invoke-on-display arg
   (lambda ()
     (save-window-excursion
       (apply
        'start-process
        "xterm"
        nil
        "wezterm"
        ;; "--config" "dpi=98"
        "start"
        ;; inside dired, it was ~/... and didn't work.
        "--cwd" (expand-file-name default-directory)
        (if command
            (list "-e" command)
          ()))))
   ;; (bury-buffer)
   ;; put the buffer to auto-desctroy list...
   ;; Xterm survives, but  rxvt does not!
   ;; (run-with-timer 10 nil 'kill-buffer buffer) ; fixme: kill the bufer after ...
   ))


;; fixme: in mmc-keys?
(global-set-key [(alt ?x) ]  'xterm)
(define-key key-translation-map [(alt ?x) ] nil)

(provide 'mmc-xterm)
