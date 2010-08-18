;; http://ruska.dyndns.org/comp/emacs/local/my-thingatpt.el

;;; Commentary:
;; put it in a dir in your load-path and
;;        (require 'my-thingatpt)
;;  in your ~/.emacs


;;; Code:
(require 'thingatpt)



;;; Add a new `thing' definition:
;;; `integer'
(put 'integer 'end-op
     (lambda () (skip-chars-forward "[0-9]")))
(put 'integer 'beginning-op
     (lambda () (skip-chars-backward "[0-9]")))
(defun integer-at-point () (form-at-point 'integer))


;;; handy commands:
(defun increment-integer (arg)
  "modify the number under point"
  (interactive "p")
  (let ((bounds (bounds-of-thing-at-point 'integer))
        (integer (integer-at-point)))
    (kill-region (car bounds) (cdr bounds))
    (insert (number-to-string (+ arg integer)))))

(defun decrement-integer (arg)
  (interactive "p")
  (increment-integer (- arg)))

;;; hm, change it (if you need)!!
(global-set-key [(control ?<)] 'increment-integer)
(global-set-key [(control ?>)] 'decrement-integer)


(provide 'my-thingatpt)

;;  Symbols 
; 15674klk
