(require 'package)
(setq package-enable-at-startup nil)
(package-initialize)

(require 'org) 
(require 'ox)
(require 'cl)
(require 'ox-beamer)
(setq org-export-async-debug nil) ;; no impact here. Do it in main init.el
(setq org-export-allow-bind-keywords t) ;; Important! In order to have #+BIND command working.

;; org-to-latex exporter to have nice code formatting
(setq org-latex-listings 'minted
      org-export-with-sub-superscripts 'nil
      org-latex-minted-options '(("bgcolor=lightgray") ("frame" "lines"))
      org-latex-packages-alist '(("" "minted"))
      org-latex-pdf-process
      '("pdflatex -shell-escape -interaction nonstopmode -output-directory %o %f"
        "pdflatex -shell-escape -interaction nonstopmode -output-directory %o %f"
        "pdflatex -shell-escape -interaction nonstopmode -output-directory %o %f"))
