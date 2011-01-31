;;;### Autoload
(defun xterm (&optional arg command title)
  "open an xterm on the DISPLAY where FRAME is. With prefix, ask for the DISPLAY."
  (interactive "P")
  (let (; (buffer (generate-new-buffer "xterm"))
        (display
         (if running-xemacs
             (frame-property (selected-frame) 'display "0:0")
           (frame-parameter (selected-frame) 'display)))
        (inside-emacs (getenv "INSIDE-EMACS")))
    (if arg
        (setq display (read-display "On display: " display)))
    (unwind-protect
        (progn
          (setenv "INSIDE_EMACS" nil)
          (with-display display
            (save-window-excursion
              ;;(shell-command
	      (apply
	       'start-process
	       "xterm"
	       nil

	       "rxvt"
					;(concat
					;(mapconcat
					; 'identity

					;(list
	       ;;"rxvt"
	       "-geometry" "100x60"
	       ;; no scrollbar!
	       "+sb"
	       ;; "-sl" "500"
	       ;; login shell? NO
	       "+ls"
	       "-j"
	       ;; "-ls"
	       "-fn"
	       ;; fixme: duplicated from ~/.Xdefaults
	       "-*-lucidatypewriter-medium-r-normal-*-18-*-*-*-*-*-*"
					;"-title" "emacs"
                  

	       ;; Old:
					;"xterm"; "/usr/local/bin/xterm" ;X11R6
					;"+sb -sl 5000"
					;"-geometry 90x52+10+0"
                                        ;		  "-j -ls "
                                        ;		  "-fn '-*-lucidatypewriter-medium-r-normal-*-20-*-*-*-*-*-*'"
                                        ;		  "-bg black"
                                        ;		  "-fg wheat"
					;(format "-title \"%s\"" (or title "exterm"))
	       (if command
		   (list "-e" command)
		 ())))
	       ;) ;;" ")
            ;; (bury-buffer)
            ;; put the buffer to auto-desctroy list...
            ;; Xterm survives, but  rxvt does not!
            ;(run-with-timer 10 nil 'kill-buffer buffer) ; fixme: kill the bufer after ...
            ))
      (setenv "INSIDE_EMACS" inside-emacs))))

;; fixme: in mmc-keys?
(global-set-key [(alt ?x) ]  'xterm)

(provide 'mmc-xterm)
