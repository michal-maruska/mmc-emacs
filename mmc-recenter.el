

;; to understand why this is needed, read the docstring of
;; `recenter'
;; i admit, that this is most likely of no use to xterm/console users
;;      (which need the brutal behavior always)



;; [11 dic 03] 
(defun my-recenter (prefix)
  "my replacement for `recenter':  which does not redisplay frame by default
no prefix  current line at window center,
C-u        curline at top,
C-u C-u               bottom
C-u C-u C-u  erase & redraw
number    curline ... nth window line"
  (interactive "P")
  (cond
   ((null prefix)
    ;; don't flicker by default
    (recenter '(4)))
   ((equal prefix '(4))
    ;; current line at top:
    (recenter 1))
   ((equal prefix '(16))
    ;; erase & redraw
    (recenter -2))
   ((equal prefix '(64))
    ;; erase & redraw
    (recenter))
   (t
    (recenter prefix))))

(substitute-key-definition 'recenter 'my-recenter global-map)
(substitute-key-definition 'recenter-top-bottom 'my-recenter global-map)

(provide 'mmc-recenter)
