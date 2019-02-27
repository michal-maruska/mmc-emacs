
(eval-when-compile
  (if running-xemacs
      (defun set-scrollbar-to-left ()
	""
	(set-specifier scrollbar-on-left-p  't))
    (defun set-scrollbar-to-left ()
					;(set-scroll-bar-mode `right)
      (set-scroll-bar-mode 'left)
      )))

;; mmc: Is this needed?
;; (make-face 'scroll-bar)

;; when i change this ^^, i have to toggle on/off !!!

(unless (or running-xemacs
            (not (under-x)))
  (scroll-bar-mode 1)
                                        ;(scroll-bar-mode 1)
                                        ; (setq scrollbars-visible-p 't)
  )


;; the bar ~~ portion   uses _only_ background.  the stuff around is always grey?

;; This is ok for Xlib !
;; unused 2013
(set-face-background 'scroll-bar "black")
;;(set-face-background 'scroll-bar "white")
;;
(set-face-foreground 'scroll-bar
                     ;"blue1"
                     "dark blue"
                                        ;"olive drab"
                     ;"green1"
                     ;"white"
                     )

;(set-face-background 'scroll-bar "white")
;(set-face-inverse-video-p 'scroll-bar 't)
;(set-face-foreground 'scroll-bar "red")


;(scroll-bar-foreground "red")

;; useless for scrollbar:
(unless running-xemacs
  (set-face-background 'tool-bar "black")
  (set-face-background 'border "green"))


;; 2013: ok:
(setq scroll-bar-width 10)
;; scroll-bar

;; fixme: I should add to
(overwrite-alist 'default-frame-alist
  '((scroll-bar-background . "black")
   ;;"blue"
   (scroll-bar-foreground . "blue")
   ))

;; CVS Emacs:
(modify-frame-parameters
 nil ;(selected-frame)
 `((scroll-bar-background . "red")
   ;;"blue"
   (scroll-bar-foreground . "blue")
   ))


(frame-parameter (selected-frame)
                 'scroll-bar-background
                 ;'scroll-bar-foreground
                 )
;;scroll-bar-background
;see my-frame.el for other `settings' .. width

(provide 'mmc-scroll-bar)

