;; mmc:
(require 'mmc-cli-options)
;; attention: this requires  url from w3. Gentoo declared it dead, and masks it!
(require 'mmc-url)

(require 'mmc-sed)
(require 'mmc-tempo)

(require 'mmc-outline)
(require 'mmc-infodock)

(require 'mmc-compile)

(require 'mmc-frame)
(require 'mmc-region)
(require 'mmc-syntax)
(require 'mmc-minibuffer)

(require 'mmc-xterm)
;; (autoload 'xterm "my-xterm.el" "" 't)

(require 'mmc-scroll-bar)
(require 'mmc-recenter)
(require 'mmc-kill-buffer)


(require 'mmc-modes)
(require 'mmc-ediff)
(require 'mmc-std)

;; (eval-after-load "dired")
(require 'mmc-dired)

(require 'mmc-keys)
(require 'mmc-skeleton)
(require 'mmc-help)
(require 'mmc-shell)


;; fixme:  why not in 22 ?
;; (unless emacs-22
;; only -devel ?
;; (require 'mmc-sawfish)
;; (require 'mmc-portage)
;; (require 'mmc-backup)

(require 'proc-menu)
(require 'mmc-paren)


(require 'mmc-ring)

;; todo:  move to mmc-emacs-config!

;; fixme: see `mmc-cli-options.el'
(add-to-list 'command-switch-alist
             ;(list
             (cons "-erc" 'relax))

(if (member "-erc" command-line-args)

    (unless running-xemacs
      (when (locate-library "erc")
        (require 'mmc-erc)
        (require 'erc)
        (wid-assign "c")
                                        ;(eval-after-load "erc" '(require 'my-erc))
        (setq erc-prompt-for-password nil)))
  ;; erc-opn
  ;; sawfish wid "c"
  )


(when (member "-gnus" command-line-args)
  (wid-assign "M")
  ;; after init!
  (require 'mmc-gnus)
  (add-hook 'after-init-hook 'gnus)
  )

(add-to-list 'command-switch-alist
             ;(list
             (cons "-desktop" 'relax))


;; 
(require 'uniquify)
(setq uniquify-buffer-name-style 'forward)

(if (condition-case nil
	(find-library "gnuserv")
      (error nil))

    (require 'mmc-gnuserv)
  (eval-after-load
      "gnuserv"
    '(require 'mmc-gnuserv)
    ))


(eval-after-load
    "iswitchb"
  '(load "mmc-patches"))

(eval-after-load
    "ibuffer"
  '(load "mmc-ibuffer"))
(global-set-key (kbd "C-x C-b") 'ibuffer)

(iswitchb-mode 1)

(require 'mmc-session)
