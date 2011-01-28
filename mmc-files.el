(require 'mmc-string)

;(setq temp (nth 5 (file-attributes "~/")))

;; use native:  build-path
(defun compose-path (&rest segments)
  ""
  (string-join
   segments "/"))

;(compose-path "a" "b")


(provide 'mmc-files)
