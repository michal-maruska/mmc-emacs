
;; fixme: colors should coordinate!
(require 'mic-paren)

(when (or running-xemacs window-system)
  (paren-activate)

  (setq paren-display-message 'never)
  (set-face-background 'cursor "green")
  ;; (copy-face 'bold 'paren-face-match)
  (set-face-background 'paren-face-match "firebrick")
  ;;"forest green")
  (setq paren-match-face 'paren-face-match))

(provide 'mmc-paren)
