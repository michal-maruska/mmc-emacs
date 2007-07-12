

;; note:  the backup directory is computed only the `first' time you save!

;; i need a more flexible:
;; auto-save-file-name-transforms

;; fixme: in mmc-emacs-config
(setq backup-directory-alist
      '(("/h/maruska/\\(.*\\)$" . ".emacs_backup/")
        ("/hm/\\(.*\\)$" . ".emacs_backup/")
        ("/linux/2/var/www/maruska/htdocs/" . ".emacs_backup/")
        ))

(setq backup-by-copying t    ; Don't delink hardlinks
      delete-old-versions t  ; Clean up the backups 
      version-control t      ; Use version numbers on backups,

      dired-kept-versions 2
      kept-new-versions 6    ; keep some new versions
      kept-old-versions 2)   ; and some old ones, too


; (".*" . "~/.emacs_backup")
; (string-match "/h/maruska/\\(.*\\)$" "/home/mmc/h/maruska/meeting/2002/index.html.ru")


(require 'mmc-files)

; backup-file-name-p
; file-name-sans-versions
(defun my-make-backup-file-name-function (file)
  "if possible, use the subdir ./.emacs_backup, otherwise the default name."
  (let* ((dir (file-name-directory file))
         (possible-backup-dir (compose-path dir ".emacs_backup")))
    (if (and (file-exists-p possible-backup-dir)
             (file-directory-p possible-backup-dir)
             (file-writable-p possible-backup-dir) ; we need also read it and scan (execute)!
             )
        (compose-path possible-backup-dir (file-name-nondirectory file))
      ;; the default one:
      (make-backup-file-name-1 file))))

(setq make-backup-file-name-function 'my-make-backup-file-name-function)
;(my-make-backup-file-name-function "/home/mmc/h/maruska/ep/pes_foto_java2")

(provide 'mmc-backup)
