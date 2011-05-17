(require 'erc)
;; eval this  and    M-x erc-display-intersection   in an ERC channel buffer

(defun erc-nicks-of (channel)
  "get the `nicknames' as list of strings"
  (mapcar (lambda (info)
            (erase-text-properties (car info)))
          (erc-get-channel-members channel)))


;; 
(require 'cl) 

(defun string-list-intersection (a b)
  ""
  ;;(set:intersection
  (intersection a b :test 'string=))

(defun erc-intersection (channel channel-B)
  "compute intersection of nicknames in both channels"
  (string-list-intersection
   (erc-nicks-of channel)
   (erc-nicks-of channel-B)))

(defun erc-current-channel ()
  ""
  (erase-text-properties (erc-default-target)))


(defun erc-interactive-channel ()
  "use (interactive (erc-interactive-channel)) to get channel"
  (list (erc-current-channel)
        (erase-text-properties (erc-current-nick))))
  

(defun erc-fontify-nickname (nickname)
  ""
  (erc-put-text-property
   0  (length nickname)
   'face
   (string->face nickname)
   nickname)
  nickname)



'(with-output-to-temp-buffer-bury "*intersection*" 
      (mapc (lambda (other-channel)
              (let ((common (delete nick (erc-intersection channel other-channel))))
                (when common
                  (princ other-channel)
                  (princ "\t")
                  (mapc
                                        
                   (lambda (nick)
                     ;; how to print w/ text property (face)?
                     ;;(insert (erc-fontify-nickname nick))
                     (princ (erc-fontify-nickname nick))
                     (princ " "))
                   common)
                  (terpri))))
            other-channels))



(defun round-string (length string)
  ""
  (let ((len (length string)))
    (if (> len length)
        (substring string 0 length)
      (concat string
              (make-string (- length len) ?\ )))))



(defun transpose-alist-matrix (alist matrix)
  "we have the ALIST   key1 ---> v1 v2 v2  (key2 v5 v1 v1)
we want to have the alist of form
v1 ---> ((key1 1) (key2 2) ..)

MATRIX is a symbol
Transposed matrix"
  (mapc 
   ;; for each (key val1  .... valN)
   (lambda (item)
     (let ((key (car item)))
       ;; for each val1 ... valN
       (mapcar
        (lambda (value)
          ;; find the row:   valI -> key1 key2.....
          (let ((value-row (aget matrix value 't)))
            ;; 
            '(aput 
             'value-row
             key 
             (1+ (or (aget value-row key) 0))
             key
             )

            ;; simple:
            (push key value-row)
            
            (aput 'matrix
                  value value-row)))
        (cdr item)))) 
   alist)
  matrix)



(defun channel-user-matrix (channels users)
  ""
  ;; ( (channel user1... userN) ....)
  (let ((matrix '()))
  (mapc
   (lambda (channel)
     (aput 'matrix channel
           (string-list-intersection users (erc-nicks-of channel)))
     ;(let ((common (delete nick (erc-intersection channel other-channel))))
     )
   channels)
  matrix))


;; (let's make it complete)
(defun mapcar-nonil (function list)
  "Get the list of non-nil results of `mapcar', seems to be a frequent operation"
  (delq
   nil
   (mapcar
    function
    list)))


(defun alist->used-keys (alist)
  ""
  (mapcar-nonil
   (lambda (item)
     (if (null (cdr item))
         '()
       (car item)))
   alist))



(defun sort-alist-by-length (alist)
  "given ALIST ((key . value) ...), return it sorted by the length of the VALUE (as list)"
  (sort alist (lambda (a b)
                (> (length a) (length b)))))

;; nick -> 
;;
;(window-configuration-to-register
;(current-window-configuration)
;(compare-window-configurations 

(defun erc-display-intersection (channel nick)
  "display in a temp buffer a 'table'"
  (interactive (erc-interactive-channel))
  (let* ((other-channels (delete channel
                                 (mapcar 'buffer-name (erc-channel-list nil))))
         ;;  channel -> users
         (matrix
          (sort-alist-by-length
           (channel-user-matrix other-channels
                                (delete nick (erc-nicks-of channel)))))
         (used-channels (alist->used-keys matrix))
         ;; i want user->channels
         (inverted-matrix '()))
    ;; sort the channels by how many users on them

    ;; user -> channels:
    (setq inverted-matrix
          (sort-alist-by-length
           ;; fixme: the 1st order is not maintained. the  most-user could not be on that channel
           (transpose-alist-matrix matrix
                                   inverted-matrix)))

    ;; sort users by how many ...
    
    (let ((buffer (generate-new-buffer "*intersection*")))
      (defun erc-print (string)
        ""
        (append-to-buffer-end buffer string))

      
      ;;(with-temp-buffer
      ;;(with-current-buffer buffer
      (mapc
       (lambda (info)
         (let ((nick (car info))
               (channels (cdr info)))
           
           (erc-print (round-string 10 (erc-fontify-nickname nick)))
           (erc-print "\t")
           (mapc
            (lambda (channel)
              ;; how to print w/ text property (face)?
              ;;(erc-print (erc-fontify-nickname nick))
              (erc-print
               (round-string 10
                             (if (member channel channels)
                                 channel "")))
              (erc-print " "))
            used-channels)
           (erc-print "\n")))

       inverted-matrix)
      (switch-to-buffer-other-window buffer)
                                        ;(display-buffer buffer)
      (let ((q-map (make-sparse-keymap))
            )
        (define-key q-map "q" 'kill-buffer-and-window)
        (use-local-map  q-map))
      (bury-buffer buffer))))


;; 
(define-key erc-mode-map (kbd "\C-c?") 'erc-display-intersection)

(set-keymap-parent  erc-button-keymap erc-mode-map)

(provide 'erc-intersection)
