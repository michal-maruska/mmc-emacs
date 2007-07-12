;;; quail/cyrillic.el -- Quail package for inputting Cyrillic characters

;; Copyright (C) 1997 Electrotechnical Laboratory, JAPAN.
;; Licensed to the Free Software Foundation.

;; Keywords: multilingual, input method, Cyrillic

;; This file is part of GNU Emacs.

;; GNU Emacs is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Code:

(require 'quail)

(quail-define-package
 "cyrillic-jcuken" "Cyrillic" "ЖЙ" nil
 "ЙЦУКЕН keyboard layout widely used in Russia (ISO 8859-5 encoding)"
 nil t t t t nil nil nil nil nil t)

;;  1! 2" 3' 4* 5: 6, 7. 8; 9( 0) -_ =+ Ё
;;   Й  Ц  У  К  Е  Н  Г  Ш  Щ  З  Х  ъ
;;    Ф  Ы  В  А  П  Р  О  Л  Д Ж  Э
;;     Я  Ч  С  М  И  Т  Ь  Б  Ю  /?

(quail-define-rules
 ("1" ?1)
 ("2" ?2)
 ("3" ?3)
 ("4" ?4)
 ("5" ?5)
 ("6" ?6)
 ("7" ?7)
 ("8" ?8)
 ("9" ?9)
 ("0" ?0)
; ("-" ?-)
; ("=" ?=)
 ("`" ?ё)
 ("q" ?й)
 ("w" ?ц)
 ("e" ?у)
 ("r" ?к)
 ("t" ?е)
 ("y" ?н)
 ("u" ?г)
 ("i" ?ш)
 ("o" ?щ)
 ("p" ?з)
 ("[" ?х)
 ("]" ?ъ)				; -----
 ("a" ?ф)
 ("s" ?ы)
 ("d" ?в)
 ("f" ?а)
 ("g" ?п)
 ("h" ?р)
 ("j" ?о)
 ("k" ?л)
 ("l" ?д)
 (";" ?ж)
; ("'" ?э)
; ("=" ?э)
 ("\\" ?\\)
 ("z" ?я)
 ("x" ?ч)
 ("c" ?с)
 ("v" ?м)
 ("b" ?и)
 ("n" ?т)
 ("m" ?ь)
 ("-" ?б)
 ("." ?ю)
 ("/" ?/)
 
 ("!" ?!)
 ("@" ?\")
 ("#" ?')
 ("$" ?*)
 ("%" ?:)
 ("^" ?,)
 ("&" ?.)
 ("*" ?\;)
 ("(" ?()
  (")" ?))
 ("_" ?_)
 ("+" ?+)

 ("~" ?Ё)
 ("Q" ?Й)
 ("W" ?Ц)
 ("E" ?У)
 ("R" ?К)
 ("T" ?Е)
 ("Y" ?Н)
 ("U" ?Г)
 ("I" ?Ш)
 ("O" ?Щ)
 ("P" ?З)
 ("{" ?Х)
 ("}" ?Ъ)
 ("A" ?Ф)
 ("S" ?Ы)
 ("D" ?В)
 ("F" ?А)
 ("G" ?П)
 ("H" ?Р)
 ("J" ?О)
 ("K" ?Л)
 ("L" ?Д)
 (":" ?Ж)
 ("\"" ?Э)
 ("|" ?|)
 ("Z" ?Я)
 ("X" ?Ч)
 ("C" ?С)
 ("V" ?М)
 ("B" ?И)
 ("N" ?Т)
 ("M" ?Ь)
 ("<" ?Б)
 (">" ?Ю)
 ("?" ??))

;;

(quail-define-package
 "cyrillic-macedonian" "Cyrillic" "ЖM" nil
 "ЉЊЕРТЗ-ЃЌ keyboard layout based on JUS.I.K1.004 (ISO 8859-5 encoding)"
 nil t t t t nil nil nil nil nil t)

;;  1! 2" 3# 4$ 5% 6& 7' 8( 9) 0= /? +* <>
;;   Љ  Њ  Е  Р  Т  З  У  И  О  П  Ш  Ѓ
;;    А  С  Д  Ф  Г  Х  Ј  К  Л  Ч  Ќ  Ж
;;     Ѕ  Џ  Ц  В  Б  Н  М  ,; .: -_

(quail-define-rules
 ("1" ?1)
 ("2" ?2)
 ("3" ?3)
 ("4" ?4)
 ("5" ?5)
 ("6" ?6)
 ("7" ?7)
 ("8" ?8)
 ("9" ?9)
 ("0" ?0)
 ("-" ?/)
 ("=" ?+)
 ("`" ?<)
 ("q" ?љ)
 ("w" ?њ)
 ("e" ?е)
 ("r" ?р)
 ("t" ?т)
 ("y" ?з)
 ("u" ?у)
 ("i" ?и)
 ("o" ?о)
 ("p" ?п)
 ("[" ?ш)
 ("]" ?ѓ)
 ("a" ?а)
 ("s" ?с)
 ("d" ?д)
 ("f" ?ф)
 ("g" ?г)
 ("h" ?х)
 ("j" ?ј)
 ("k" ?к)
 ("l" ?л)
 (";" ?ч)
 ("'" ?ќ)
 ("\\" ?ж)
 ("z" ?ѕ)
 ("x" ?џ)
 ("c" ?ц)
 ("v" ?в)
 ("b" ?б)
 ("n" ?н)
 ("m" ?м)
 ("," ?,)
 ("." ?.)
 ("/" ?-)
 
 ("!" ?!)
 ("@" ?\")
 ("#" ?#)
 ("$" ?$)
 ("%" ?%)
 ("^" ?&)
 ("&" ?')
 ("*" ?\()
 ("(" ?\))
 (")" ?=)
 ("_" ??)
 ("+" ?*)
 ("~" ?>)
 ("Q" ?Љ)
 ("W" ?Њ)
 ("E" ?Е)
 ("R" ?Р)
 ("T" ?Т)
 ("Y" ?З)
 ("U" ?У)
 ("I" ?И)
 ("O" ?О)
 ("P" ?П)
 ("{" ?Ш)
 ("}" ?Ѓ)
 ("A" ?А)
 ("S" ?С)
 ("D" ?Д)
 ("F" ?Ф)
 ("G" ?Г)
 ("H" ?Х)
 ("J" ?Ј)
 ("K" ?К)
 ("L" ?Л)
 (":" ?Ч)
 ("\"" ?Ќ)
 ("|" ?Ж)
 ("Z" ?Ѕ)
 ("X" ?Џ)
 ("C" ?Ц)
 ("V" ?В)
 ("B" ?Б)
 ("N" ?Н)
 ("M" ?М)
 ("<" ?\;)
 (">" ?:)
 ("?" ?_))

;;

(quail-define-package
 "cyrillic-serbian" "Cyrillic" "ЖS" nil
 "ЉЊЕРТЗ-ЂЋ keyboard layout based on JUS.I.K1.005 (ISO 8859-5 encoding)"
 nil t t t t nil nil nil nil nil t)

;;  1! 2" 3# 4$ 5% 6& 7' 8( 9) 0= /? +* <>
;;   Љ  Њ  Е  Р  Т  З  У  И  О  П  Ш  Ђ
;;    А  С  Д  Ф  Г  Х  Ј  К  Л  Ч  Ћ  Ж
;;     Ѕ  Џ  Ц  В  Б  Н  М  ,; .: -_

(quail-define-rules
 ("1" ?1)
 ("2" ?2)
 ("3" ?3)
 ("4" ?4)
 ("5" ?5)
 ("6" ?6)
 ("7" ?7)
 ("8" ?8)
 ("9" ?9)
 ("0" ?0)
 ("-" ?/)
 ("=" ?+)
 ("`" ?<)
 ("q" ?љ)
 ("w" ?њ)
 ("e" ?е)
 ("r" ?р)
 ("t" ?т)
 ("y" ?з)
 ("u" ?у)
 ("i" ?и)
 ("o" ?о)
 ("p" ?п)
 ("[" ?ш)
 ("]" ?ђ)
 ("a" ?а)
 ("s" ?с)
 ("d" ?д)
 ("f" ?ф)
 ("g" ?г)
 ("h" ?х)
 ("j" ?ј)
 ("k" ?к)
 ("l" ?л)
 (";" ?ч)
 ("'" ?ћ)
 ("\\" ?ж)
 ("z" ?ѕ)
 ("x" ?џ)
 ("c" ?ц)
 ("v" ?в)
 ("b" ?б)
 ("n" ?н)
 ("m" ?м)
 ("," ?,)
 ("." ?.)
 ("/" ?-)
 
 ("!" ?!)
 ("@" ?\")
 ("#" ?#)
 ("$" ?$)
 ("%" ?%)
 ("^" ?&)
 ("&" ?')
 ("*" ?\()
 ("(" ?\))
 (")" ?=)
 ("_" ??)
 ("+" ?*)
 ("~" ?>)
 ("Q" ?Љ)
 ("W" ?Њ)
 ("E" ?Е)
 ("R" ?Р)
 ("T" ?Т)
 ("Y" ?З)
 ("U" ?У)
 ("I" ?И)
 ("O" ?О)
 ("P" ?П)
 ("{" ?Ш)
 ("}" ?Ђ)
 ("A" ?А)
 ("S" ?С)
 ("D" ?Д)
 ("F" ?Ф)
 ("G" ?Г)
 ("H" ?Х)
 ("J" ?Ј)
 ("K" ?К)
 ("L" ?Л)
 (":" ?Ч)
 ("\"" ?Ћ)
 ("|" ?Ж)
 ("Z" ?Ѕ)
 ("X" ?Џ)
 ("C" ?Ц)
 ("V" ?В)
 ("B" ?Б)
 ("N" ?Н)
 ("M" ?М)
 ("<" ?\;)
 (">" ?:)
 ("?" ?_))

;;

(quail-define-package
 "cyrillic-beylorussian" "Cyrillic" "ЖB" nil
 "ЉЊЕРТЗ-ІЎ BEYLORUSSIAN (ISO 8859-5 encoding)"
 nil t t t t nil nil nil nil nil t)

;;  1! 2" 3# 4$ 5% 6& 7' 8( 9) 0= /? +* <>
;;   Љ  Њ  Е  Р  Т  З  У  И  О  П  Ш  І
;;    А  С  Д  Ф  Г  Х  Ј  К  Л  Ч  Ў  Ж
;;     Ѕ  Џ  Ц  В  Б  Н  М  ,; .: -_

(quail-define-rules
 ("1" ?1)
 ("2" ?2)
 ("3" ?3)
 ("4" ?4)
 ("5" ?5)
 ("6" ?6)
 ("7" ?7)
 ("8" ?8)
 ("9" ?9)
 ("0" ?0)
 ("-" ?/)
 ("=" ?+)
 ("`" ?<)
 ("q" ?љ)
 ("w" ?њ)
 ("e" ?е)
 ("r" ?р)
 ("t" ?т)
 ("y" ?з)
 ("u" ?у)
 ("i" ?и)
 ("o" ?о)
 ("p" ?п)
 ("[" ?ш)
 ("]" ?і)
 ("a" ?а)
 ("s" ?с)
 ("d" ?д)
 ("f" ?ф)
 ("g" ?г)
 ("h" ?х)
 ("j" ?ј)
 ("k" ?к)
 ("l" ?л)
 (";" ?ч)
 ("'" ?ў)
 ("\\" ?ж)
 ("z" ?ѕ)
 ("x" ?џ)
 ("c" ?ц)
 ("v" ?в)
 ("b" ?б)
 ("n" ?н)
 ("m" ?м)
 ("," ?,)
 ("." ?.)
 ("/" ?-)
 
 ("!" ?!)
 ("@" ?\")
 ("#" ?#)
 ("$" ?$)
 ("%" ?%)
 ("^" ?&)
 ("&" ?')
 ("*" ?\()
 ("(" ?\))
 (")" ?=)
 ("_" ??)
 ("+" ?*)
 ("~" ?>)
 ("Q" ?Љ)
 ("W" ?Њ)
 ("E" ?Е)
 ("R" ?Р)
 ("T" ?Т)
 ("Y" ?З)
 ("U" ?У)
 ("I" ?И)
 ("O" ?О)
 ("P" ?П)
 ("{" ?Ш)
 ("}" ?І)
 ("A" ?А)
 ("S" ?С)
 ("D" ?Д)
 ("F" ?Ф)
 ("G" ?Г)
 ("H" ?Х)
 ("J" ?Ј)
 ("K" ?К)
 ("L" ?Л)
 (":" ?Ч)
 ("\"" ?Ў)
 ("|" ?Ж)
 ("Z" ?Ѕ)
 ("X" ?Џ)
 ("C" ?Ц)
 ("V" ?В)
 ("B" ?Б)
 ("N" ?Н)
 ("M" ?М)
 ("<" ?\;)
 (">" ?:)
 ("?" ?_))

;;

(quail-define-package 
 "cyrillic-ukrainian" "Cyrillic" "ЖU" nil
 "ЄЇЕРТЗ-ІЎ UKRAINIAN (ISO 8859-5 encoding)

Sorry, but 'ghe with upturn' is not included in ISO 8859-5"
 nil t t t t nil nil nil nil nil t)

;;  1! 2" 3# 4$ 5% 6& 7' 8( 9) 0= /? +* <>
;;   Є  Ї  Е  Р  Т  З  У  И  О  П  Ш  І
;;    А  С  Д  Ф  Г  Х  Ј  К  Л  Ч  Ў  Ж
;;     Ѕ  Џ  Ц  В  Б  Н  М  ,; .: -_

(quail-define-rules
 ("1" ?1)
 ("2" ?2)
 ("3" ?3)
 ("4" ?4)
 ("5" ?5)
 ("6" ?6)
 ("7" ?7)
 ("8" ?8)
 ("9" ?9)
 ("0" ?0)
 ("-" ?/)
 ("=" ?+)
 ("`" ?<)
 ("q" ?є)
 ("w" ?ї)
 ("e" ?е)
 ("r" ?р)
 ("t" ?т)
 ("y" ?з)
 ("u" ?у)
 ("i" ?и)
 ("o" ?о)
 ("p" ?п)
 ("[" ?ш)
 ("]" ?і)
 ("a" ?а)
 ("s" ?с)
 ("d" ?д)
 ("f" ?ф)
 ("g" ?г)
 ("h" ?х)
 ("j" ?ј)
 ("k" ?к)
 ("l" ?л)
 (";" ?ч)
 ("'" ?ў)
 ("\\" ?ж)
 ("z" ?ѕ)
 ("x" ?џ)
 ("c" ?ц)
 ("v" ?в)
 ("b" ?б)
 ("n" ?н)
 ("m" ?м)
 ("," ?,)
 ("." ?.)
 ("/" ?-)
 
 ("!" ?!)
 ("@" ?\")
 ("#" ?#)
 ("$" ?$)
 ("%" ?%)
 ("^" ?&)
 ("&" ?')
 ("*" ?\()
 ("(" ?\))
 (")" ?=)
 ("_" ??)
 ("+" ?*)
 ("~" ?>)
 ("Q" ?Є)
 ("W" ?Ї)
 ("E" ?Е)
 ("R" ?Р)
 ("T" ?Т)
 ("Y" ?З)
 ("U" ?У)
 ("I" ?И)
 ("O" ?О)
 ("P" ?П)
 ("{" ?Ш)
 ("}" ?І)
 ("A" ?А)
 ("S" ?С)
 ("D" ?Д)
 ("F" ?Ф)
 ("G" ?Г)
 ("H" ?Х)
 ("J" ?Ј)
 ("K" ?К)
 ("L" ?Л)
 (":" ?Ч)
 ("\"" ?Ў)
 ("|" ?Ж)
 ("Z" ?Ѕ)
 ("X" ?Џ)
 ("C" ?Ц)
 ("V" ?В)
 ("B" ?Б)
 ("N" ?Н)
 ("M" ?М)
 ("<" ?\;)
 (">" ?:)
 ("?" ?_))

;;

(quail-define-package 
 "cyrillic-yawerty" "Cyrillic" "ЖЯ" nil
 "ЯВЕРТЫ Roman transcription (ISO 8859-5 encoding)

This layout is based on Roman transcription.
When preceded by a '/', the second and the third rows (number key row) change
as follows.

  keytop | Q  W  E  R  T  Y  U  I  O  P  A  S  D
 --------+---------------------------------------
  input  | Ђ  Ѓ  Є  Ѕ  І  Ї  Ј  Љ  Њ  Ћ  Ќ  Ў  Џ"
 nil t t t t nil nil nil nil nil t)

;;  1! 2ё 3ъ 4Ё 5% 6^ 7& 8* 9( 0) -_ Ч  Ю
;;   Я  В  Е  Р  Т  Ы  У  И  О  П  Ш  Щ
;;    А  С  Д  Ф  Г  Х  Й  К  Л  ;: '" Э
;;     З  Ь  Ц  Ж  Б  Н  М  ,< .> /?

;;  1! 2ё 3ъ 4Ё 5% 6^ 7& 8* 9( 0) -_ Ч  Ю
;;   Ђ  Ѓ  Є  Ѕ  І  Ї  Ј  Љ  Њ  Ћ  Ш  Щ
;;    Ќ  Ў  Џ  Ф  Г  Х  Й  К  Л  ;: '" Э
;;     З  Ь  Ц  Ж  Б  Н  М  ,< .> /?

(quail-define-rules
 ("1" ?1)
 ("2" ?2)
 ("3" ?3)
 ("4" ?4)
 ("5" ?5)
 ("6" ?6)
 ("7" ?7)
 ("8" ?8)
 ("9" ?9)
 ("0" ?0)
 ("-" ?-)
 (":" ?ч)
 ("`" ?ю)
 ("q" ?я)
 ("w" ?ж)
 ("e" ?е)
 ("|" ?э)
 ("r" ?р)
 ("t" ?т)
 ("y" ?ы)
 ("u" ?у)
 ("{" ?ю)

 ("i" ?и)
 ("o" ?о)
 ("<" ?ё); sorry 

 ("p" ?п)
 ("a" ?а)
 ("s" ?с)
 ("#" ?ш)

 ("d" ?д)
 ("*" ?щ)

 ("f" ?ф)
 ("g" ?г)
 ("h" ?х)
 ("j" ?й)
 ("k" ?к)
 ("l" ?л)
; (";" ?\;)
 ("'" ?')
 ("\\" ?э)
 ("z" ?з)
 ("x" ?ь)
 (";" ?ъ)

 ("c" ?ц)
 ("v" ?в)
 ("b" ?б)
 ("n" ?н)
 ("m" ?м)
 ("," ?,)
 ("." ?.)
 ("/" ?/)
 
 ("!" ?!)
 ("@" ?ё)
 ("$" ?Ё)
 ("%" ?%)
 ("^" ?^)
 ("&" ?&)
 ("*" ?*)
 ("(" ?\()
 (")" ?\))
 ("_" ?_)
 ("+" ?Ч)
 ("~" ?Ю)
 ("Q" ?Я)
 ("W" ?Ж)
 ("E" ?Е)
 ("R" ?Р)
 ("T" ?Т)
 ("Y" ?Ы)
 ("U" ?У)
 ("I" ?И)
 ("O" ?О)
 ("P" ?П)
 ("{" ?Ш)
 ("}" ?Щ)
 ("A" ?А)
 ("S" ?С)
 ("D" ?Д)
 ("F" ?Ф)
 ("G" ?Г)
 ("H" ?Х)
 ("J" ?Й)
 ("K" ?К)
 ("L" ?Л)
 (":" ?:)
 ("\"" ?\")
; ("|" ?Э)
 ("Z" ?З)
 ("X" ?Ь)
 ("C" ?Ц)
 ("V" ?В)
 ("B" ?Б)
 ("N" ?Н)
 ("M" ?М)
 ("<" ?<)
 (">" ?>)
 ("?" ??)
 
 ("/q" ?ђ)
 ("/w" ?ѓ)
 ("/e" ?є)
 ("/r" ?ѕ)
 ("/t" ?і)
 ("/y" ?ї)
 ("/u" ?ј)
 ("/i" ?љ)
 ("/o" ?њ)
 ("/p" ?ћ)
 ("/a" ?ќ)
 ("/s" ?ў)
 ("/d" ?џ)
 
 ("/Q" ?Ђ)
 ("/W" ?Ѓ)
 ("/E" ?Є)
 ("/R" ?Ѕ)
 ("/T" ?І)
 ("/Y" ?Ї)
 ("/U" ?Ј)
 ("/I" ?Љ)
 ("/O" ?Њ)
 ("/P" ?Ћ)
 ("/A" ?Ќ)
 ("/S" ?Ў)
 ("/D" ?Џ))

;; This was provided by Valery Alexeev <valery@domovoy.math.uga.edu>.

(quail-define-package
 "cyrillic-translit" "Cyrillic" "Жt" nil
 "Intuitively transliterated keyboard layout.
Most convenient for entering Russian but all cyrillic characters are included.
Should handle most cases. However:
  for ц (TSE) use \"c\", never \"ts\"
  щ (SHCHA = Bulgarian SHT) = \"shch\", \"sj\", \"/sht\" or \"/t\",
  э (REVERSE ROUNDED E) = \"e'\" or \"e`\"
  х (KHA) when after с (S) = \"x\" or \"kh\"
  ъ (HARD SIGN) = \"~\", Ъ (CAPITAL HARD SIGN) = \"~~\",
  ь (SOFT SIGN) = \"'\", Ь (CAPITAL SOFT SIGN) = \"''\",
  я (YA) = \"ya\", \"ja\" or \"q\".

Russian alphabet: a b v=w g d e yo=jo zh z i j=j' k l m n o p r s t
u f h=kh=x c ch sh shch=sj=/s=/sht ~ y ' e' yu=ju ya=ja=q

Also included are Ukrainian є (YE) = \"/e\" and ї (YI) = \"yi\", 
Belorussian ў (SHORT U) = \"u'\",
Serbo-Croatian ђ (DJE) = \"/d\", ћ (CHJE)= \"/ch\", 
Macedonian ѓ (GJE) = \"/g\", ѕ (DZE) = \"/s\", ќ (KJE) = \"/k\",
cyrillic і (I DECIMAL) = \"/i\", ј (JE) = \"/j\", 
љ (LJE) = \"/l\", њ (NJE) = \"/n\" and џ (DZE) =\"/z\"."
 nil t t t t nil nil nil nil nil t)

(quail-define-rules
 ("a" ?а)("b" ?б) ("v" ?в) ("w" ?в) ("g" ?г) ("d" ?д) 
 ("e" ?е) ("je" ?е) 
 ("yo" ?ё) ("jo" ?ё)
 ("zh" ?ж) ("z" ?з) ("i" ?и) 
 ("j" ?й) ("j'" ?й) ("j`" ?й) ("k" ?к) ("l" ?л)
 ("m" ?м) ("n" ?н) ("o" ?о) ("p" ?п) ("r" ?р) ("s" ?с) ("t" ?т) ("u" ?у)
 ("f" ?ф) ("x" ?х) ("h" ?х) ("kh" ?х)
 ("c" ?ц) ("ch" ?ч)
 ("sh" ?ш) 
 ("shch" ?щ) ("sj" ?щ) 
 ("/sht" ?щ) ("/t" ?щ) 
 ("~" ?ъ) ("y" ?ы) ("'" ?ь) ("`" ?ь) 
 ("e'" ?э) ("e`" ?э) ("@" ?э) 
 ("yu" ?ю) ("ju" ?ю) 
 ("ya" ?я) ("ja" ?я) ("q" ?я)

 ("A" ?А) ("B" ?Б) ("V" ?В) ("W" ?В) ("G" ?Г) ("D" ?Д) 
 ("E" ?Е) ("Je" ?Е) ("JE" ?Е)
 ("Yo" ?Ё) ("YO" ?Ё) ("Jo" ?Ё) ("JO" ?Ё) 
 ("Zh" ?Ж) ("ZH" ?Ж) ("Z" ?З) ("I" ?И) 
 ("J" ?Й) ("J'" ?Й) ("J`" ?Й) ("K" ?К) ("L" ?Л)
 ("M" ?М) ("N" ?Н) ("O" ?О) ("P" ?П) ("R" ?Р) ("S" ?С) ("T" ?Т) ("U" ?У)
 ("F" ?Ф) ("X" ?Х) ("H" ?Х) ("Kh" ?Х) ("KH" ?Х)
 ("C" ?Ц) ("Ch" ?Ч) ("CH" ?Ч) 
 ("Sh" ?Ш) ("SH" ?Ш) 
 ("Shch" ?Щ) ("SHCH" ?Щ) ("Sj" ?Щ) ("SJ" ?Щ) 
 ("/Sht" ?Щ) ("/SHT" ?Щ) ("/T" ?Щ) 
 ("~~" "Ъ") ("Y" ?Ы) ("''" "Ь") ("E'" ?Э) ("E`" ?Э) 
 ("Yu" ?Ю) ("YU" ?Ю) ("Ju" ?Ю) ("JU" ?Ю) 
 ("Ya" ?Я) ("YA" ?Я) ("Ja" ?Я) ("JA" ?Я) ("Q" ?Я)

 ("/e" ?є) ("yi" ?ї) ("u'" ?ў)
 ("/d" ?ђ) ("/ch" ?ћ)
 ("/g" ?ѓ) ("/s" ?ѕ) ("/k" ?ќ)
 ("/i" ?і) ("/j" ?ј) ("/l" ?љ) ("/n" ?њ) ("/z" ?џ)
 ("/E" ?Є) ("YE" ?Є) ("Yi" ?Ї) ("YI" ?Ї) ("U'" ?Ў) 
 ("/D" ?Ђ) ("/Ch" ?Ћ) ("/CH" ?Ћ)
 ("/G" ?Ѓ) ("/S" ?Ѕ) ("/K" ?Ќ) 
 ("/I" ?І) ("/J" ?Ј) ("/L" ?Љ) ("/N" ?Њ) ("/Z" ?Џ)
)

(quail-define-package
 "cyrillic-translit-bulgarian" "Cyrillic" "Жtb" nil
 "Intuitively transliterated keyboard layout optimized for Bulgarian.
The only difference with cyrillic-translit is that \"sht\" translates as
щ (SHCHA = Bulgarian SHT) insteat of шт (SH+T)."
 nil t t t t nil nil nil nil nil t)

(quail-define-rules
 ("a" ?а)("b" ?б) ("v" ?в) ("w" ?в) ("g" ?г) ("d" ?д) 
 ("e" ?е) ("je" ?е) 
 ("yo" ?ё) ("jo" ?ё)
 ("zh" ?ж) ("z" ?з) ("i" ?и) 
 ("j" ?й) ("j'" ?й) ("j`" ?й) ("k" ?к) ("l" ?л)
 ("m" ?м) ("n" ?н) ("o" ?о) ("p" ?п) ("r" ?р) ("s" ?с) ("t" ?т) ("u" ?у)
 ("f" ?ф) ("x" ?х) ("h" ?х) ("kh" ?х)
 ("c" ?ц) ("ch" ?ч)
 ("sh" ?ш) 
 ("shch" ?щ) ("sj" ?щ) 
 ("/sht" ?щ) ("/t" ?щ) ("sht" ?щ)
 ("~" ?ъ) ("y" ?ы) ("'" ?ь) ("`" ?ь) 
 ("e'" ?э) ("e`" ?э) ("@" ?э) 
 ("yu" ?ю) ("ju" ?ю) 
 ("ya" ?я) ("ja" ?я) ("q" ?я)

 ("A" ?А) ("B" ?Б) ("V" ?В) ("W" ?В) ("G" ?Г) ("D" ?Д) 
 ("E" ?Е) ("Je" ?Е) ("JE" ?Е)
 ("Yo" ?Ё) ("YO" ?Ё) ("Jo" ?Ё) ("JO" ?Ё) 
 ("Zh" ?Ж) ("ZH" ?Ж) ("Z" ?З) ("I" ?И) 
 ("J" ?Й) ("J'" ?Й) ("J`" ?Й) ("K" ?К) ("L" ?Л)
 ("M" ?М) ("N" ?Н) ("O" ?О) ("P" ?П) ("R" ?Р) ("S" ?С) ("T" ?Т) ("U" ?У)
 ("F" ?Ф) ("X" ?Х) ("H" ?Х) ("Kh" ?Х) ("KH" ?Х)
 ("C" ?Ц) ("Ch" ?Ч) ("CH" ?Ч) 
 ("Sh" ?Ш) ("SH" ?Ш) 
 ("Shch" ?Щ) ("SHCH" ?Щ) ("Sj" ?Щ) ("SJ" ?Щ) 
 ("/Sht" ?Щ) ("/SHT" ?Щ) ("/T" ?Щ) ("Sht" ?Щ) ("SHT" ?Щ) 
 ("~~" "Ъ") ("Y" ?Ы) ("''" "Ь") ("E'" ?Э) ("E`" ?Э) 
 ("Yu" ?Ю) ("YU" ?Ю) ("Ju" ?Ю) ("JU" ?Ю) 
 ("Ya" ?Я) ("YA" ?Я) ("Ja" ?Я) ("JA" ?Я) ("Q" ?Я)

 ("/e" ?є) ("yi" ?ї) ("u'" ?ў)
 ("/d" ?ђ) ("/ch" ?ћ)
 ("/g" ?ѓ) ("/s" ?ѕ) ("/k" ?ќ)
 ("/i" ?і) ("/j" ?ј) ("/l" ?љ) ("/n" ?њ) ("/z" ?џ)
 ("/E" ?Є) ("YE" ?Є) ("Yi" ?Ї) ("YI" ?Ї) ("U'" ?Ў) 
 ("/D" ?Ђ) ("/Ch" ?Ћ) ("/CH" ?Ћ)
 ("/G" ?Ѓ) ("/S" ?Ѕ) ("/K" ?Ќ) 
 ("/I" ?І) ("/J" ?Ј) ("/L" ?Љ) ("/N" ?Њ) ("/Z" ?Џ)
)



