    ;; ____________________________________________________________________________78
    ;; install-packages.el
    ;; The full description of what is done in this file is included in 
    ;; accompanying .org file (configuring-and-installing-emacs.org) that is
    ;; described here:
    ;; https://cissic.github.io/posts/configuring-and-installing-emacs/


    ;; Path to your Emacs directory:
    (setq my-emacs-dir "~/.emacs.d/")
    ;;;; (let (my-emacs-dir "~/.emacs.d/"))

;; Make a git commit of your repository.
;; 
(let ((default-directory my-emacs-dir)) ; run command `git add -u` in the context of my-emacs-dir
  (shell-command "git add -u"))
(let ((default-directory my-emacs-dir)) ; run command `git commmit` in the context of my-emacs-dir
  (shell-command
   "git commit -m 'Precautionary commit before running install-packages.el'"))

(when (< emacs-major-version 27)
  (package-initialize)) ;  set up the load-paths and autoloads for installed packages
(setq package-check-signature nil)

  ;;first, declare repositories
  (setq package-archives
	'(("gnu" . "http://elpa.gnu.org/packages/")  ;; default value of package-archives in Emacs 27.1
	  ("melpa" . "http://melpa.org/packages/")
	  ("melpa-stable" . "http://stable.melpa.org/packages/")
	  ("nongnu"       . "https://elpa.nongnu.org/nongnu/")
	  ))

;; Refresh the repositories to have the newest versions of the packages
(package-refresh-contents)

(setq my-packages
  '(

    auctex ; in order to have reftex working
    bash-completion
    calfw      ; calendar and...
    calfw-cal  ; agenda ...
    calfw-org  ; integration
    ; counsel ; for ivy
    cdlatex
    company
    chatgpt-shell
    dall-e-shell
    ;; ob-chatgpt-shell
    ;; ob-dall-e-shell
    dockerfile-mode
    emacs-everywhere
    engrave-faces
    expand-region
    fill-column-indicator
    ;flycheck
    ;flycheck-pos-tip
    flyspell
    ;; gptel ;; not working
    ;; google-this
    ido
    ; ivy
    ; jedi
    magit
    markdown-mode
    matlab-mode ; 
    modus-themes ; theme by Protesilaos Stavrou
    ;moe-theme ; https://github.com/kuanyui/moe-theme.el
    move-dup
    ;mh
    ;ob-async
    org   ; ver. 9.3  built-in in Emacs 27.1; this install version 9.6 from melpa
    org-ac
    org-ai
    ;org-download
    ; org-plus-contrib
    ;org-mime
    org-ref ; for handling org-mode references https://emacs.stackexchange.com/questions/9767/can-reftex-be-used-with-org-label
    org-special-block-extras
    ;ox-gfm
    ;ox-pandoc
    ; ox-ipynb -> manual-download
    ;pandoc-mode
    pdf-tools
    popup   ; for yasnippet
    ;projectile
    ;pyenv-mode
    ;Pylint  ; zeby dzialal interpreter python'a po:  C-c C-c 
    quelpa
    quelpa-use-package
    ;rebox2
    ;recentf
    session-async
    ;shell-pop
    smex
    ssh
    ; tramp  ; ver. 2.4.2 built-in in Emacs 27.1
    ;tao-theme ; https://github.com/11111000000/tao-theme-emacs
    texfrag
    ;treemacs
    ;use-package
    websocket
    workgroups2
    ;w3m
    yasnippet
    )
  ;; "A list of packages to be installed at Emacs launch."
  )

(defun my-packages-installed-p ()
  (cl-loop for p in my-packages
           when (not (package-installed-p p)) do (cl-return nil)
           finally (cl-return t)))

(unless (my-packages-installed-p)
  ;; check for new packages (package versions)
  (package-refresh-contents)
  ;; install the missing packages
  (dolist (p my-packages)
    (when (not (package-installed-p p))
      (package-install p))))

;; ; (jedi:install-server)

(message "All done in install-packages.")

(require 'quelpa-use-package)

(setq package-archives
      '(("melpa" . "https://melpa.org/packages/"))
      use-package-always-ensure t)

(package-initialize)

(require 'use-package-ensure)

(use-package quelpa
  :ensure)

(use-package quelpa-use-package
  :demand
  :config
  (quelpa-use-package-activate-advice))
