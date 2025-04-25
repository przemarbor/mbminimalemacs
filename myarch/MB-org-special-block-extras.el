;;; MB-org-special-block-extras.el --- custom variation
;;; org-special-block-extras.el package

;; Copyright (c) 2023 MB
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'org-special-block-extras)

(org-defblock pbox (title "")
	             (background-color nil
	              frame-color nil
	              title-background-color nil
		      title-color nil
		      )
 "Enclose text in a box, possibly with a title.
  Parametrized version of the original 'box' block from Al-hassy's
  org-special-block-extras.el.

  HTML export is just copied from original function.
  It is not implemented properly!
 "
 
 (apply #'concat
 (pcase backend
    (`html `("<div style=\"padding: 1em; background-color: "
    ,(org-special-block-extras--subtle-colors (format "%s" (or background-color "green")))
    ";border-radius: 15px; font-size: 0.9em"
    "; box-shadow: 0.05em 0.1em 5px 0.01em #00000057;\">"
    "<h3>" ,title "</h3>"
    ,contents "</div>"))

 (`latex `("\\begin{tcolorbox}[title={" ,title "}"
 ",colback=" ,(pp-to-string (or background-color 'red!5!white))
 ",colframe=" ,(pp-to-string (or frame-color red!75!black))
 ",colbacktitle=" ,(pp-to-string (or title-background-color yellow!50!red)) 
 ",coltitle=" ,(pp-to-string (or title-color red!25!black))
 ", fonttitle=\\bfseries,"
 "subtitle style={boxrule=0.4pt, colback=yellow!50!red!25!white}]"
 ,contents
 "\\end{tcolorbox}")))))



(org-defblock cbox (title "")
	             (background-color nil)
    "Variation on 'box block' for fast declaration of latex boxes
     differing in color of the background.

     HTML export is just copied from original function.
     It is not implemented properly!
    "
 
 (apply #'concat
 (pcase backend
    (`html `("<div style=\"padding: 1em; background-color: "
    ,(org-special-block-extras--subtle-colors (format "%s" (or background-color "green")))
    ";border-radius: 15px; font-size: 0.9em"
    "; box-shadow: 0.05em 0.1em 5px 0.01em #00000057;\">"
    "<h3>" ,title "</h3>"
    ,contents "</div>"))

 (`latex `("\\begin{tcolorbox}[title={" ,title "}"
 ",colback=" ,(pp-to-string (or background-color 'red!5!white))
 ",colframe=black"
 ",colbacktitle=" ,(pp-to-string (or background-color yellow!50!red)) 
 ",coltitle=black"
 ", fonttitle=\\bfseries,"
 "subtitle style={boxrule=0.4pt, colback=yellow!50!red!25!white}]"
 ,contents
 "\\end{tcolorbox}")))))





(provide 'MB-org-special-block-extras)

;;; MB-org-special-block-extras.el ends here
