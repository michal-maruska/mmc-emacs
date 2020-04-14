(require 'mmc-display)

;;;### Autoload
(defun xterm (&optional arg command title)
  "open an xterm on the DISPLAY where FRAME is. With prefix, ask for the DISPLAY."
  (interactive "P")
  ;; without this message I get segfault! when byte-compiled, of course.
  (invoke-on-display arg
   (lambda ()
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
        "-geometry" "90x40"		;40 rows...
        ;; no scrollbar!
        "+sb"
        ;; "-sl" "500"
        ;; login shell? NO
        "+ls"
        "-j"
        ;; "-ls"
        ;; fixme: duplicated from ~/.Xdefaults
        ;"-fn"
        ;"-*-lucidatypewriter-medium-r-normal-*-18-*-*-*-*-*-*"
        ;;"-title" "emacs"
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
          ()))))
                                        ;) ;;" ")
   ;; (bury-buffer)
   ;; put the buffer to auto-desctroy list...
   ;; Xterm survives, but  rxvt does not!
                                        ;(run-with-timer 10 nil 'kill-buffer buffer) ; fixme: kill the bufer after ...
     ))


;; fixme: in mmc-keys?
(global-set-key [(alt ?x) ]  'xterm)

(provide 'mmc-xterm)
