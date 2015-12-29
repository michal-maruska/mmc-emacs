(require 'mmc-simple)

(defun invoke-on-display (arg function)
  "prepare for invoking External X program, by function. @arg
can indicate to prompt to choose on which Display..."
  (let ((display
         (if running-xemacs
             (frame-property (selected-frame) 'display "0:0")
           (frame-parameter (selected-frame) 'display)))
	;;(buffer (generate-new-buffer "xterm"))
        (inside-emacs (getenv "INSIDE-EMACS")))
    (if arg
        (setq display (read-display "On display: " display)))
    (unwind-protect
        (progn
          (setenv "INSIDE_EMACS" nil)
	  ;; fixme: might use  env(1)
          (with-display display
	    (funcall function)))

      (setenv "INSIDE_EMACS" inside-emacs))))

(provide 'mmc-display)
