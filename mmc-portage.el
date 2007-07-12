
;;; alternative to  etc-update command in gentoo linux.

;; how to use:
;; 1/    select/locate files, which need update                              not completed

;; 2/    run ediff on the file and its most recent .... upgrade              OK

;; 3/    remove the  upgrade                                                 not supported


(defun etc-update:most-recent-copy (filename)
  "get the most recent suggested modification of filename (in gentoo)"
  (let ((dirname (file-name-directory filename))
        (basename (file-name-nondirectory filename)))
    (do ((i 1 (+ 1 i)))                 ; was: 0
        ((not (file-exists-p (concat dirname
                                     (format "._cfg%04d_" i)
                                     basename)))
         (let ((last (concat dirname
                             (format "._cfg%04d_" (- i 1))
                             basename)))
           (if (file-exists-p last)
               last
             nil))))))

; (etc-update:most-recent-copy "a")
; (etc-update:most-recent-copy "/etc/group")

(defun etc-update (filename)
  "run `ediff' on FILENAME and its suggested upgrade"
  (interactive
   ;; read the filename:    and possibly even the version ?
   (let* ((file buffer-file-name)
          (possible (etc-update:most-recent-copy file)))
     (cond (possible
            ;; (not current-prefix-arg)
            (list file))

           (file
            (let ((file-name (file-name-nondirectory file))
                  (file-dir  (file-name-directory file)))
              (list (read-file-name
                     "etc-update: " file-dir nil nil file-name)))))))

  (let ((upgrade (etc-update:most-recent-copy filename)))
    (if upgrade
        (ediff filename upgrade)
      (message "no upgrade available for %s" filename))))




(defun etc-update-clone (clone)
  "used in Dired, `update' the file under point, taken as a suggested upgrade"
  (interactive (list (dired-get-filename)))
  (let ((master (string-replace-match  "\\._cfg[[:digit:]]+_" (basename clone) ""))) ; {4} "\\._cfg\\d\\d\\d\\d_"
    (if master
        (etc-update master))))

(string-replace-match "\\._cfg[[:digit:]]+_" "._cfg0000_xinetd" "")

(defun etc-update-dired (dir)
  "get a dired buffer with  _cfg* files in DIR. To be used "
  (interactive "Ddirectory to etc-update: ")
  (find-dired dir "-maxdepth 1 -name '._cfg*'" )
  (define-key (current-local-map) "j" 'etc-update-clone) ; see find-dired.el `find-dired'
  ;(define-key dired-mode-map "g" 'etc-update-clone)
  ;(define-key map "g" 'revert-buffer)
  )

;;  find-ls-option


(require 'mmc-ediff)
;; i have got a global  ediff-keymap

(define-key ediff-keymap "g" 'etc-update-dired)
(define-key ediff-keymap "u" 'etc-update)
(define-key ediff-keymap "p" 'etc-update)

(provide 'mmc-portage)
