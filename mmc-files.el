(require 'mmc-string)

;(setq temp (nth 5 (file-attributes "~/")))

;; use native:  build-path
(defun compose-path (&rest segments)
  ""
  (string-join
   segments "/"))

;(compose-path "a" "b")

(defun add-suffix-optionally (filename suffix)
  "add SUFFIX if not yet present"
  (if (string-match (concat (regexp-quote suffix) "$") filename)
      filename
    (concat filename suffix)))

(defun file-name-in-directory (dir filename)
  ""
  (concat dir "/" filename))

(defun find-subpath-in-paths (subpath path-list)
  ""
  (list-search-positive
   (lambda (item)
     (file-if-exists
      (file-name-in-directory item subpath)))
   path-list))


(provide 'mmc-files)
