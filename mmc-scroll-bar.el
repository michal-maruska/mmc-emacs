
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

(unless running-xemacs
  (scroll-bar-mode 1)
;(scroll-bar-mode 1)
; (setq scrollbars-visible-p 't)
  )


;; the bar ~~ portion   uses _only_ background.  the stuff around is always grey?

;; This is ok for Xlib !
(set-face-background 'scroll-bar "red")
;;(set-face-background 'scroll-bar "white")



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

(unless running-xemacs
  (set-face-background 'tool-bar "pink")
  (set-face-background 'border "pink"))


(setq scroll-bar-width 10)
;; scroll-bar

;; fixme: I should add to

(overwrite-alist 'default-frame-alist
  '((scroll-bar-background . "red")
   ;;"blue"
   (scroll-bar-foreground . "white")
   ))

;; CVS Emacs:
(modify-frame-parameters
 nil ;(selected-frame)
 `((scroll-bar-background . "red")
   ;;"blue"
   (scroll-bar-foreground . "white")
   ))


(frame-parameter (selected-frame)
                 'scroll-bar-background
                 ;'scroll-bar-foreground
                 )
;;scroll-bar-background
;see my-frame.el for other `settings' .. width

(provide 'mmc-scroll-bar)

