

;; processing   command line arguments, options:

;; add the switch to known ones:
(add-to-list 'command-switch-alist
      ;; relax --- function fired
	     (cons "-nodesktop" 'relax))
(add-to-list 'command-switch-alist
	     (cons "-gnus" 'relax))


(defvar mmc-nodesktop () "toggle from the CLI")
(setq mmc-nodesktop (member "-nodesktop" command-line-args))


(provide 'mmc-cli-options)
