(require 'mmc-string)

;(setq temp (nth 5 (file-attributes "~/")))

;; use native:  build-path
(defun compose-path (&rest segments)
  "Return path composed of all segments, by adding / separator."
  (string-join
   segments "/"))

;(compose-path "a" "b")

(defun add-suffix-optionally (filename suffix)
  "add SUFFIX if not yet present"
  (if (string-match (concat (regexp-quote suffix) "$") filename)
      filename
    (concat filename suffix)))

(defun file-name-in-directory (dir filename)
  "see `compose-path'"
  (compose-path dir filename))

;;  other code for find-file
(defun file-if-exists (filename)
  "return the FILENAME, if it exists (in the filesystem), otherwise NIL"
  (if (file-exists-p filename)
      filename))

(defun find-subpath-in-paths (subpath path-list)
  ""
  (list-search-positive
   (lambda (item)
     (file-if-exists
      (file-name-in-directory item subpath)))
   path-list))


(provide 'mmc-files)
