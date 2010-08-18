(require 'ispell)

(setq ispell-dictionary-alist
      (append ispell-dictionary-alist
	      '(("czech"				; czech.aff
		 "[A-Za-z‚ì‚¹‚è‚ø‚¾‚ı‚á‚í‚é‚ò‚»‚Ï‚ù‚ú‚Ì‚©‚È‚Ø‚®‚İ‚Á‚Í‚É‚Ò‚«‚Ï‚Ù‚Ú]" "[^A-Za-z‚ì‚¹‚è‚ø‚¾‚ı‚á‚í‚é‚ò‚»‚Ï‚ù‚ú‚Ì‚©‚È‚Ø‚®‚İ‚Á‚Í‚É‚Ò‚«‚Ï‚Ù‚Ú]"
		 "[']" nil ("-C") nil iso-latin-2)
		("italiano"				; czech.aff
		 "[A-Za-zàèéíòùÀÈÉÍÒÙ]" "[^A-Za-zàèéíòùÀÈÉÍÒÙ]"
		 "[']" nil ("-C") nil iso-latin-1)
		("russianb" "[ŒĞŒÑŒÒŒÓŒÔŒÕŒñŒÖŒ×ŒØŒÙŒÚŒÛŒÜŒİŒŞŒßŒàŒáŒâŒãŒäŒåŒæŒçŒèŒéŒìŒêŒëŒíŒîŒïŒ°Œ±Œ²Œ³Œ´ŒµŒ¡Œ¶Œ·Œ¸Œ¹ŒºŒ»Œ¼Œ½Œ¾Œ¿ŒÀŒÁŒÂŒÃŒÄŒÅŒÆŒÇŒÈŒÉŒÌŒÊŒËŒÍŒÎŒÏ]"
		 "[^ŒÑŒÒŒÓŒÔŒÕŒñŒÖŒ×ŒØŒÙŒÚŒÛŒÜŒİŒŞŒßŒàŒáŒâŒãŒäŒåŒæŒçŒèŒéŒìŒêŒëŒíŒîŒïŒ°Œ±Œ²Œ³Œ´ŒµŒ¡Œ¶Œ·Œ¸Œ¹ŒºŒ»Œ¼Œ½Œ¾Œ¿ŒÀŒÁŒÂŒÃŒÄŒÅŒÆŒÇŒÈŒÉŒÌŒÊŒËŒÍŒÎŒÏ]"
		 "[-]" t ("-d" "russian") nil koi8)
		)))
(setq ispell-dictionary "czech")

(setq ispell-silently-savep 't)

;(defun ispell-get-word (following &optional extra-otherchars)
;  "Return the word for spell-checking according to ispell syntax.
;If optional argument FOLLOWING is non-nil or if `ispell-following-word'
;is non-nil when called interactively, then the following word
;\(rather than preceding\) is checked when the cursor is not over a word.
;Optional second argument contains otherchars that can be included in word
;many times.
;
;Word syntax described by `ispell-dictionary-alist' (which see)."
;  (message "get-word 1")
;  (let* ((ispell-casechars (ispell-get-casechars))
;	 (ispell-not-casechars (ispell-get-not-casechars))
;	 (ispell-otherchars (ispell-get-otherchars))
;	 (ispell-many-otherchars-p (ispell-get-many-otherchars-p))
;	 (word-regexp (concat ispell-casechars
;			      "+\\("
;			      ispell-otherchars
;			      "?"
;			      (if extra-otherchars
;				  (concat extra-otherchars "?"))
;			      ispell-casechars
;			      "+\\)"
;			      (if (or ispell-many-otherchars-p
;				      extra-otherchars)
;				  "*" "?")))
;;	 (message "ahoj")
;;	 (message "get-word 2")
;	 did-it-once
;	 start end word)
;    (message word-regexp)
;    (message "get-word 3")
;    ;; find the word
;    (if (not (looking-at ispell-casechars))
;	(if following
;	    (re-search-forward ispell-casechars (point-max) t)
;	  (re-search-backward ispell-casechars (point-min) t)))
;    ;; move to front of word
;    (re-search-backward ispell-not-casechars (point-min) 'start)
;    (while (and (or (looking-at ispell-otherchars)
;		    (and extra-otherchars (looking-at extra-otherchars)))
;		(not (bobp))
;		(or (not did-it-once)
;		    ispell-many-otherchars-p))
;      (if (and extra-otherchars (looking-at extra-otherchars))
;	  (progn
;	    (backward-char 1)
;	    (if (looking-at ispell-casechars)
;		(re-search-backward ispell-not-casechars (point-min) 'move)))
;	(setq did-it-once t)
;	(backward-char 1)
;	(if (looking-at ispell-casechars)
;	    (re-search-backward ispell-not-casechars (point-min) 'move)
;	  (backward-char -1))))
;    ;; Now mark the word and save to string.
;    (or (re-search-forward word-regexp (point-max) t)
;	(error "No word found to check!"))
;    (setq start (match-beginning 0)
;	  end (point)
;	  word (buffer-substring start end))
;    (list word start end)))

