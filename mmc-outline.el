;;; my-outline.el --- key-bindings

(require 'outline)

(eval-and-compile
  (when running-xemacs
    (define-minor-mode outline-minor-mode
      "Toggle Outline minor mode.
With arg, turn Outline minor mode on if arg is positive, off otherwise.
See the command `outline-mode' for more information on this mode."
      nil " Outl" (list (cons [menu-bar] outline-mode-menu-bar-map)
                        (cons outline-minor-mode-prefix
                              outline-mode-prefix-map))
      )))

;; allout.el
(when nil
   (require 'allout)
   (outline-init 't)
   )

;; fold.el
;; koutl-mode
;; hyperbole

;;; Commentary:

;;; Code:
(setq outline-minor-mode-prefix "\C-c\C-d")

;; remap ?
(unless (lookup-key outline-minor-mode-map (kbd outline-minor-mode-prefix))
  (define-key outline-minor-mode-map (kbd outline-minor-mode-prefix)
    (lookup-key outline-minor-mode-map (kbd "\C-c@"))))


;; lisp:
;; (setq outline-regexp "\\(;;;*\\) \\|(")
;;";;;;* \\|("
;; (setq outline-regexp "^[a-zA-Z_.]*:")
;; outline:
;; should be loaded after ?

(unless running-xemacs
  (set-default 'outline-regexp "\*")
  (setq outline-regexp "##*|<Location")
  (setq outline-regexp "\\*+")
  (set-default 'outline-regexp "\\*+")
)

;;; keymaps

(when 't
  (global-set-key [(meta ?P)] 'outline-previous-visible-heading)
  (global-set-key [(meta ?N)] 'outline-next-visible-heading)
  (global-set-key [(meta ?F)] 'outline-forward-same-level)
  (global-set-key [(meta ?B)] 'outline-backward-same-level)

;  (global-set-key [(meta ?M)] 'outline-back-to-heading)
  (global-set-key [(meta ?M)] 'outline-mark-subtree)
  (global-set-key [(meta ?U)] 'outline-up-heading)

  (global-set-key [(meta ?I)] 'show-children)
  (global-set-key [(meta ?K)] 'show-branches)
  (global-set-key [(meta ?L)] 'hide-leaves)

  (global-set-key [(meta ?A)] 'show-all)
  (global-set-key [(meta ?Y)] 'show-all)
  (global-set-key [(meta ?T)] 'hide-body)

  ;;
  (global-set-key [(meta ?E)] 'show-entry)
  (global-set-key [(meta ?C)] 'hide-entry)
  ;;
  (global-set-key [(meta ?D)] 'hide-subtree)
  (global-set-key [(meta ?S)] 'show-subtree) ; not so good:
  (global-set-key [(meta ?_)] 'show-entry)

  ;;(lookup-key outline-mode-map  [(meta ?S)])
  ;;(define-key outline-mode-map  [(meta ?S)] nil)

  (global-set-key [(meta ?O)] 'hide-other)
  (global-set-key [(meta ?Q)] (lambda ()
                                (hide-sublevels 1))))


(define-key outline-mode-prefix-map  [return ] 'outline-commands)
(global-set-key [(control meta ?-)] 'outline-commands)

(unless running-xemacs
  (set-default 'selective-display t)

  ;; (eval-after-load
  (require 'disp-table)
  (set-display-table-slot
   standard-display-table
   'selective-display
   ;[?M ?o ?r ?e ?. ?. ?.]
   [?\  ?. ?. ?.]
   ;[?\  46 46 46]
   ))


(defun outline-back-to-heading (&optional invisible-ok)
  "Move to previous heading line, or beg of this line if it's a heading.
Only visible heading lines are considered, unless INVISIBLE-OK is non-nil."
  (beginning-of-line)
  (or (outline-on-heading-p invisible-ok)
      (let (found)
        (save-excursion
          (while (not found)
            (or (re-search-backward (concat "^\\(" outline-regexp "\\)")
                                    nil t)
                ;; mmc:
                (goto-char (point-min)); (error "before first heading")
                )
            (setq found (and (or invisible-ok (not (outline-invisible-p)))
                             (point)))))
        (goto-char found)
        found)))

;;; comments
;; For _years_ i wanted to modify outline-minor-mode, so that comments starting at
;; the beginnin of line were left visible.  Now I add the codition that they don't
;; get marked as headers. Here's the code:
(defun outline-flag-region-make-overlay (from to)
  (let ((o (make-overlay from to)))
    (overlay-put o 'invisible 'outline)
    (overlay-put o 'isearch-open-invisible
                 'outline-isearch-open-invisible)
    o))

(defun cheese-outline-hide (to)
  ""
  (let ((beginning (point))
        (regexp (concat "^" (regexp-quote comment-start))))
    (while (re-search-forward regexp to 't)
      (goto-char (match-beginning 0))
      (if (> (- (point) beginning) 2)
          (outline-flag-region-make-overlay beginning
                                            (- (point) 1)))
                                        ;(goto-char
      (end-of-line)
      (setq beginning (point)))
    ;; the final part:
    (outline-flag-region-make-overlay beginning to)))


(defun outline-flag-region (from to flag)
  "Hides or shows lines from FROM to TO, according to FLAG.
If FLAG is nil then text is shown, while if FLAG is t the text is hidden."
  ;; mmc:
  (if (functionp 'remove-overlays)
      (remove-overlays from to 'invisible 'outline))
  (save-excursion
    (goto-char from)
    (end-of-line)
    ;;(if (functionp 'outline-discard-overlays)
    ;;  (outline-discard-overlays (point) to 'outline))
    (if flag
        ;; mmc: I want to leave the comments visible!
        ;; very ugly code:
        (if comment-start
            (cheese-outline-hide to)
          ;; original:
          (let ((o (make-overlay (point) to)))
            (overlay-put o 'invisible 'outline)
            (overlay-put o 'isearch-open-invisible
                         'outline-isearch-open-invisible))))
    (run-hooks 'outline-view-change-hook)))

;; stop
(if running-xemacs
    nil ;; (global-set-key [(meta shift ? )] 'outline-commands)
  (global-set-key [(meta shift ? )] 'outline-commands)
  )

;; (setq magic-mode-alist ())
;; fixme: I need something to go `after' auto-mode-alist, when `text-mode' is on
(add-to-list 'magic-fallback-mode-alist
             ;;magic-mode-alist
             '(detect-outline . outline-mode))

;; magic-fallback-mode-alist
;; (setq magic-mode-alist ())
(defun detect-outline ()
  (and (memq major-mode '(fundamental-mode text-mode))
       (save-excursion
         (goto-char (point-min))
         ;; (search (append "^" outline-regexp))))
         (search-forward-regexp "^\\*\\([^/]|*+\\)" 1000 t))))


;; used?
(defun beginning-of-def-as-outline ()
  "Easy way to make `beginning-of-defun' work in modes with outline support"
  (interactive)
  (forward-line -1)
  (outline-back-to-heading t))


(provide 'mmc-outline)
;;; my-outline.el ends here
