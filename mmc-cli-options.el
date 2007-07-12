

;; processing   command line arguments, options:

;; add the switch to known ones:
(setq command-switch-alist
      ;; relax --- function fired
      (append
       (list
	(cons "-nodesktop" 'relax)
	(cons "-gnus" 'relax)
        ;(cons "-erc" 'relax)
        )
       command-switch-alist))

(defvar nodesktop (member "-nodesktop" command-line-args) "")


(provide 'mmc-cli-options)
