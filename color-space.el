;;; version   "$Revision: 1.10 $"

;;; how to use:
;; (require 'color-space)
;; patch the erc-match.el !!!




;;; Description:
;; 1/ we have a set of colors (i.e. we cannot create a random color, rgb point).
;; 2/ we want to hash strings to colors (uniformly; to distinct colors, and visible,
;;    i.e. in contrast w/ background

;; possible (and tried) solutions:

;; a/ hash into list of all colors.       bad
;; b/ try only colors distant from background.    bad

;; c/ the problem is that some color neighbourhoods are more densely populated.
;;     a simplified solution:     we guarantee the distance of 2 colors.

;; available functions:
;;  defined-colors
;;  color-values

;; d/ ok, this is a _valid_ notation for a color: "#XXXYYYZZZ"    

;; now i would have the entire space, and want to avoid certain 'holes'
;; (around background, and a set of known faces: friends ...)
;; so, having a map from a segment, i'd reserve the final part of the segment,
;; and when mapped to a forbidden hole, ... take from the final part.



;;; possible use:
;;    do the *implicit* colorization of nicknames.  (as XChat does)
;;    This file is in fact about having nice points in rgb space.

;; 


;;; dedication: to people behind www.wsws.org


;;; help functions (from my other files)
(defun erase-text-properties (string)
  "strip text properties from string"
  (set-text-properties 0 (length string) () string)
  string)


;;; Vectors:
(defun first-index-non-nil (vector index)
  "return the index of 1st non-nil element in VECTOR starting from INDEX" ; after ??
  (let ((try
         (do ((i index (1+ i)))
             ;;find-first
             ((or (equal i (length vector))
                  (aref vector i))
              i))))
    (if (equal try (length vector))
        (first-index-non-nil vector 0)
      try)))


(defun root (a b)
  "count the a^1/b in integers"
  (floor (expt a (/ 1 (float b)))))
;(root 9 2)

;;; color space:
(defun color->rgb (name)
  "get the (r g b)"
  ;; on failure ??
                                        ;(string-match "^RGB:\\(\\d\\)" "RGB:566656")
  (if (string-match "RGB:\\([[:digit:]]*\\)/\\([[:digit:]]*\\)/\\([[:digit:]]*\\)" name)
      (list (string-to-number (match-string 1 name))
            (string-to-number (match-string 2 name))
            (string-to-number (match-string 3 name)))
    (cdr (assoc (downcase name) color-name-rgb-alist))))


(defun background-rgb()
  "get the RGB values of current background (frame)"
  (color->rgb (frame-parameter (selected-frame) 'background-color)))

(defun color-distance (rgb-a rgb-b)
  "(square of) euclidean distince in the RGB space."
  ;(sqrt   ... 
  (+
   (expt (- (car rgb-b)
           (car rgb-a)) 2)
   (expt (- (cadr rgb-b)
           (cadr rgb-a)) 2)
   (expt (- (caddr rgb-b)
           (caddr rgb-a)) 2)))

;;(color-distance (background-rgb) (color->rgb "purple4"))
;; 2352
(defun  color-norm (color)
  "distance from background (squared)"
  (interactive
   (let ((face (face-at-point)))
     (if (eq (car face) 'bold)
         (setq face (cdr face)))
     (list
      (if (facep face)
          (face-foreground face)
        (plist-get face :foreground))))) ;; (plist-get '(bold :foreground "grey11" :weight bold) :foreground)
  (let ((value (color-distance (background-rgb) (color->rgb color)))
        )
    (if (interactive-p)
        (message "|%s|=%d" color value)
      value)))

(defconst color-minimum-distance 75000 "")

;;;  constructing a grid in the space
(defvar color-grid-distance (root (/ (expt 256 3) (length color-name-rgb-alist)) 3)
  "lenght of edge of the cubic `neighbourhood'. minimum distance between 2 colors is half of that.")
(defvar color-grid-size (1+ (/ 256 color-grid-distance)) "in 1 dimension")
;(* 8 29)
(defvar color-grid-volume (expt color-grid-size 3) "how many nodes in the grid")

(defvar color-grid-vector 'f "how to keep a 3d grid ? vector")

;;; mapping 3d into a (1d) vector
(defsubst cube-coordinate->array-coordinate (edge-lenght a b c)
  ""
  (+ a
     (* edge-lenght b)
     (* edge-lenght edge-lenght c)))


(defun list-add (coord-list max step)
  "add coordinate-wise w/ carry-over"
  (let ((a (car coord-list))
        (rest (cdr coord-list)))
  (setq a (+ a step))
  (if (<= a max)
      (cons a rest)
    (if (null rest)
        (throw 'overflow 1)
      (cons 0 (list-add rest max step))))))

;(list-add '(230 230 230) 255 30)


;; inline ?
(defsubst cube-coordinate->grid-coordinate (grid-precision coordinates)
  "given coordinates in a fixed cube, return grid-coordinates of a grid node,
which is a lower approximation"
  (mapcar
   (lambda (x)
     (/ x grid-precision))
   coordinates))

(defsubst grid-coordinate->cube-coordinate (grid-precision coordinates)
  "given coordinates in a the grid, return coordinates in the cube."
  (mapcar
   (lambda (x)
     (* x grid-precision))
   coordinates))



(defun rgb->grid-node (r g b)
  "for a value in RGB space, return an index in a vector. see `cube-coordinate->grid-coordinate'"
  (apply 'cube-coordinate->array-coordinate
         color-grid-size
         (cube-coordinate->grid-coordinate
          color-grid-distance (list r g b))))

;(new-rgb->grid-node 20 20 29)
;(rgb->grid-node 20 20 29)

;;; the squeezed vector
(require 'cl)
(defun squeeze-vector (vector)
  "given a VECTOR, return another vector, w/ only non-nil elements"
  ;; make a list
  (let ((non-nil '())
        (squeezed nil)
        i)
    ;(loop for c from 32 to 127
    (loop for i from 0 to (1- (length vector))
          ;for i across vector
          do (if (aref vector i)
              (push (aref vector i) non-nil)))
    (vconcat non-nil)))

(defvar color-grid-vector-squeezed 'f "")
(defvar color-grid-vector-squeezed-lenght 'f "")

(defun make-color-grid ()
  "make a vector, which represents (ordered) nodes of a grid inside the color RGB space. the nodes are names of the colors."
  ;;(defined-colors)
  (let ((vector (make-vector color-grid-volume nil))
        (bg-rgb (background-rgb)))
    (mapc
     (lambda (item)
       ;;(car color-name-rgb-alist)
       (let ((color (car item))
             (rgb-coordinates
              (if emacs-22
                  (mapcar (lambda (a)
                            (/ a 256))
                          (cdr item))
                (cdr item))))
         (if (> (color-distance bg-rgb rgb-coordinates)
                color-minimum-distance)
             (aset vector (apply 'rgb->grid-node rgb-coordinates) color))))
     color-name-rgb-alist)
    vector))


; (frame-parameter (selected-frame) 'background-color)

(defun color-grid-init ()
  ""
  (let ((colors-available (length color-name-rgb-alist)))
    ; (message "color-grid-init: for bg: %s or %s"
    ;      (frame-parameter (selected-frame) 'background-color) (aget default-frame-alist 'background-color))
    

    
    ;;    size is the # of nodes on edge(s)
    ;;  o-----o-----o-----o ...
    ;;  |\    |\
    ;;  | o---|-o
    ;;  o |   o |
    ;;   distance
    ;;  volume: total # of nodes
    (setq color-grid-distance (root (/ (expt 256 3) colors-available) 3)
          color-grid-size     (1+ (/ 256 color-grid-distance))
          color-grid-volume   (expt color-grid-size 3))

    ;; distribute the known/available colors, to the nodes:
    (setq color-grid-vector (make-color-grid))

    ;; make a vector of 'used' nodes
    (setq color-grid-vector-squeezed (squeeze-vector color-grid-vector)
          color-grid-vector-squeezed-lenght (length color-grid-vector-squeezed))))

(require 'advice)

;; should i make a hook ??
(defadvice set-background-color (after update-color-grid activate)
  "re-calculate the grid. b/c it depends on the background color"
  (message "set-background-color  after advice")
  (color-grid-init))


;; this is messy:
; (modify-frame-parameters (selected-frame) '((background-color . "Red")))


;;;  using the grid, to map strings -> colors:
(defun color->face (color)
  "given a COLOR, return a face, which is just `default' face w/ the COLOR as foreground"
  ;; this is a valid face(as text property specification), but `facep' doesn't support it ?
  ;; (facep (list :foreground-color "red" :bold 't))
  (list :foreground color :weight 'bold))         ;:bold 't obsolete

; color
;;(new-string->face "rw`")
;;; hi level

(defvar new-color-grid-distance)
(defvar new-color-grid-size)
(defvar new-color-grid-volume)
(defun new-color-init ()
  ""
  (setq new-color-grid-distance (root color-minimum-distance 3)
        new-color-grid-size     (/ 256 new-color-grid-distance)  ; 6 in a row |0---1-----...-----6--|255
        new-color-grid-volume   (expt new-color-grid-size 3))
  ;; modulo new-color-grid-volume.
  )



(defvar color-busy-points '() "")
; (setq color-busy-points '())
(defun find-free-point (start)
  ""
  (let ((point start))
    ;; a set of points, and ??
    (while (member point color-busy-points)
      (setq point (list-add point new-color-grid-size 1)))
    point))

(defun reserver-color-point (point)
  ""
  (push point color-busy-points))
; (length color-busy-points)

;(reserver-color-point (find-free-point '(0 4 6)))


(defvar string->color-hash (make-hash-table :test 'equal) "")

; new-color-grid-volume
(defun new-string->face (string)
  "'hash' the STRING to a face. The face is not a regular face.
Just a specification, which is *legal* for text properties !"
  (color->face
   (apply 'format "RGB:%02d/%02d/%02d"
          (grid-coordinate->cube-coordinate new-color-grid-distance

                                            (if (gethash string string->color-hash 'nil)
                                                (gethash string string->color-hash 'nil)
    
                                              (let* ((index (mod (sxhash string) new-color-grid-volume))
                                                     ;; car cadr 
                                                     (color (list (mod index new-color-grid-size)
                                                                  (mod (/ index new-color-grid-size) new-color-grid-size)
                                                                  (/ index new-color-grid-size  new-color-grid-size)))
                                                     (good (find-free-point color)))
                                                (reserver-color-point good)
                                                (puthash string good string->color-hash) 
                                                good))))))
;;(put-text-property (point) (+ 10 (point)) 'face '(:foreground "RGB:68/42/10"))

(defun list-rgb-colors-display ()
  ""
  (interactive)
  (let ((temp-buffer (get-buffer-create "*rgb-colors*"))
        (color '(0 0 0)))
    (display-buffer temp-buffer)
    (with-current-buffer temp-buffer
      (erase-buffer)
      (catch 'overflow
        (while 't
          (let ((color-string (apply 'format "RGB:%02d/%02d/%02d"
                                    (grid-coordinate->cube-coordinate new-color-grid-distance color)))
                )
          (insert (apply 'format "\n%02d %02d %02d: ||=%d"
                         (append color (list (color-norm color-string)))))
          (beginning-of-line 1)
          (put-text-property (point) (+ 10 (point))
                             'face
                             (color->face
                              color-string))
          (beginning-of-line 2)
          (setq color (list-add color new-color-grid-size 1))))))))


;(gethash "lucijan" string->color-hash)
;(new-string->face "lucijan")
;(new-string->face "yesod")
;;`"#XXXYYYZZZ"
;; RGB:XX/YY/ZZ
;(new-string->face "kensanata")


;         (aref color-grid-vector-squeezed
;               (mod (sxhash string)
;                    color-grid-vector-squeezed-lenght)))

         ;(aref color-grid-vector (first-index-non-nil color-grid-vector (mod (sxhash string) color-grid-volume))))
         ;; `todo:' find a suitable (visible) color
         ;; i.e. go ahead, discarding poorly visible  colors.
         ;(real-index start-index)
                                        ;(car (nth start-index color-name-rgb-alist))

;; 66/115
(defun string->face (string)
  "'hash' the STRING to a face. The face is not a regular face.
Just a specification, which is *legal* for text properties !"
  (let* ((color
         (aref color-grid-vector-squeezed
               (mod (sxhash string)
                    color-grid-vector-squeezed-lenght)))

         ;(aref color-grid-vector (first-index-non-nil color-grid-vector (mod (sxhash string) color-grid-volume))))
         ;; `todo:' find a suitable (visible) color
         ;; i.e. go ahead, discarding poorly visible  colors.
         ;(real-index start-index)
                                        ;(car (nth start-index color-name-rgb-alist))
         (face (color->face color)))
    face))




;;; patch erc-match.el  ("Revision: 1.17")


;; (defun erc-match-message ()
;; ......
;; Right AFTER:
;;          (message (buffer-substring (if (and nick-end
;;                                              (<= (+ 2 nick-end) (point-max)))
;;                                         (+ 2 nick-end)
;;                                       (point-min))


;; ADD this code required code:
;; ------------

;;     ;; first, implicit colorization
;;     (when (and nick-beg nick-end nickname)
;;       (erc-put-text-property
;;        nick-beg nick-end
;;        'face
;;        (string->face nickname) (current-buffer)))
;;     ;; after that, explicit:
;;----------------------------


;; btw. i've made another modification ot erc-match.el:
;; (search-forward nickname (point-max) t)

;;; another bugfix:   just push the limit :).
;; there was a problem w/ coloring _long_ nicks.
(defun erc-is-valid-nick-p (nick)
  "Check if NICK is a valid IRC nickname."
  (and (<= (length nick) 29)
       (string-match (concat "^" erc-valid-nick-regexp "$") nick)))


;; another bug in  erc.el  is due to (message XXX) where XXX can contain "%".



;;; debugging (good for general consumption)
(defun face-at-point ()
  "shows face under point"
  (interactive)
  (if (interactive-p)
      (princ (plist-get (text-properties-at (point)) 'face))
    (plist-get (text-properties-at (point)) 'face)))

(defvar last-color-measured ;"black"
  (frame-parameter (selected-frame) 'background-color)
  "should be (only) in the closure of `color-distance-from-previous'")

(defun color-distance-from-previous ()
  ""
  (interactive)
  (let ((current-color
         (plist-get 
          (plist-get (text-properties-at (point)) 'face)
          :foreground)))
    (message (format "|%s - %s| = %d" last-color-measured current-color
                     (color-distance
                      (color->rgb last-color-measured)
                      (color->rgb current-color))))
    (setq last-color-measured current-color)))

;(define-key erc-mode-map (kbd "C-c f") 'color-norm)
; 'face-at-point
;(define-key erc-mode-map  (kbd "C-c d") 'color-distance-from-previous)


(defun sphere-point (point radius)      ;point (r g b)
  ""
  (let ((norm (color-distance '(0 0 0) point))
        (r (car point))
        (g (cadr point))
        (b (caddr point))
        (rrad (* radius radius))
        )
    (list
     (root (/ (* r r rrad) norm) 2)
     (root (/ (* g g rrad) norm) 2)
     (root (/ (* b b rrad) norm) 2))))
;(color-distance '(0 0 0) (sphere-point '(10 50 5) 20))


;; it is linear programming !!!




(provide 'color-space)
