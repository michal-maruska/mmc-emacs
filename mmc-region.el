
;; c-x r  \  indent
;;()

(require 'mmc-simple)
(defvar ctl-x-r-map (lookup-key global-map (kbd "C-x r"))
  "i really expected this pretty standard, why not?")

(unless (keymapp ctl-x-r-map)
  (setq ctl-x-r-map (make-sparse-keymap)))

(let ((map  ctl-x-r-map))
  (define-key map [(control ?w)] 'write-region)
  (if running-xemacs
      (progn
        (define-key map [?D] 'decode-coding-region)
        (define-key map [?E] 'encode-coding-region))
    (progn
      (define-key map [(shift ?d)] 'decode-coding-region)
      (define-key map [(shift ?e)] 'encode-coding-region)
      (define-key map [(control ?i)] 'indent-region)
      (define-key map "#" 'comment-region)

      (define-key map "q" 'fill-region)
      (define-key map [(meta ?l)] 'downcase-region)
      (define-key map [(meta ?u)] 'upcase-region)
      (define-key map [(meta ?c)] 'capitalize-region)
      
      (define-key map ";" 'comment-region)

      (define-key map (kbd "C-w") 'delete-region))))

;(ctl-x-r-map




; (global-set-key  [(control ?\( )] 'comment-region)

; (global-set-key  [(control ?\( )] 'up-list)

;; [07 nov 02]
; (require 'mmc-region)
(global-set-key [(control ?R)] ctl-x-r-map)
;(global-set-key "\C-r" 'isearch-backward)



(provide 'mmc-region)
