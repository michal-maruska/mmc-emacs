

(load "~/rpm-spec-mode.el" t)
;; http://www.emacswiki.org/emacs/RpmSpecMode
(autoload 'rpm-spec-mode "rpm-spec-mode.el" "RPM spec mode." t)
(add-to-list 'auto-mode-alist '("\\.spec$" . rpm-spec-mode))

(defun my-rpm-ffap (name)
  (ffap-locate-file name '("" ".gz" ".bz2")
		    '("./" "../SOURCES")))

(add-to-list 'ffap-alist
	     '(rpm-spec-mode . my-rpm-ffap))

