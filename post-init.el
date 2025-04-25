;;; post-init.el --- DESCRIPTION -*- no-byte-compile: t; lexical-binding: t; -*-

;; ;; Ensure adding the following compile-angel code at the very beginning
;; ;; of your `~/.emacs.d/post-init.el` file, before all other packages.
;; (use-package compile-angel
;;   :ensure t
;;   :demand t
;;   :custom
;;   ;; Set `compile-angel-verbose` to nil to suppress output from compile-angel.
;;   ;; Drawback: The minibuffer will not display compile-angel's actions.
;;   (compile-angel-verbose t)
;; 
;;   :config
;;   ;; The following directive prevents compile-angel from compiling your init
;;   ;; files. If you choose to remove this push to `compile-angel-excluded-files'
;;   ;; and compile your pre/post-init files, ensure you understand the
;;   ;; implications and thoroughly test your code. For example, if you're using
;;   ;; `use-package', you'll need to explicitly add `(require 'use-package)` at
;;   ;; the top of your init file.
;;   (push "/pre-init.el" compile-angel-excluded-files)
;;   (push "/post-init.el" compile-angel-excluded-files)
;;   (push "/pre-early-init.el" compile-angel-excluded-files)
;;   (push "/post-early-init.el" compile-angel-excluded-files)
;; 
;;   ;; A local mode that compiles .el files whenever the user saves them.
;;   ;; (add-hook 'emacs-lisp-mode-hook #'compile-angel-on-save-local-mode)
;; 
;;   ;; A global mode that compiles .el files before they are loaded.
;;   (compile-angel-on-load-mode))

;; Auto-revert in Emacs is a feature that automatically updates the
;; contents of a buffer to reflect changes made to the underlying file
;; on disk.
(add-hook 'after-init-hook #'global-auto-revert-mode)

;;;;;;;   recentf - konfiguruję później
;; ;; recentf is an Emacs package that maintains a list of recently
;; ;; accessed files, making it easier to reopen files you have worked on
;; ;; recently.
;; (add-hook 'after-init-hook #'(lambda()
;;                                (let ((inhibit-message t))
;;                                  (recentf-mode 1))))
;; (add-hook 'kill-emacs-hook #'recentf-cleanup)

(use-package emacs
  ;; :init
  :config 
  ;; Recently opened files ->
  ;; (recentf-mode 1)
  (add-hook 'after-init-hook #'(lambda()
                               (let ((inhibit-message t))
                                 (recentf-mode 1))))  
  (setq recentf-max-menu-items 1000)
  (setq recentf-max-saved-items 1000)
  ;; in original emacs this binding is for "Find file read-only"
  (global-set-key "\C-x\ \C-r" 'recentf-open-files)

   (add-hook 'kill-emacs-hook #'recentf-cleanup)  
  
  ;; <- Recently opened files
)
;;;;;;;   <---- recentf - konfiguruję później



;; savehist is an Emacs feature that preserves the minibuffer history between
;; sessions. It saves the history of inputs in the minibuffer, such as commands,
;; search strings, and other prompts, to a file. This allows users to retain
;; their minibuffer history across Emacs restarts.
(add-hook 'after-init-hook #'savehist-mode)

;; save-place-mode enables Emacs to remember the last location within a file
;; upon reopening. This feature is particularly beneficial for resuming work at
;; the precise point where you previously left off.
(add-hook 'after-init-hook #'save-place-mode)

(add-hook 'after-init-hook #'delete-selection-mode)     ;; Replace selected text

;; ;; I think this feature is enabled by default
;; (define-key global-map (kbd "RET") 'newline-and-indent) ;; Auto-indent new lines

(add-hook 'after-init-hook #'global-display-line-numbers-mode) ;; line numbers on the left

(add-hook 'after-init-hook #'global-visual-line-mode)          ;; Truncate lines

; fix for python indentation problems after tangling of org-babel blocks
(use-package emacs
 :config
 (setq org-src-preserve-indentation     t
       org-edit-src-content-indentation 0)
  )

;; (setq org-src-preserve-indentation     t
;;       org-edit-src-content-indentation 0)

;; Enable `auto-save-mode' to prevent data loss. Use `recover-file' or
;; `recover-session' to restore unsaved changes.
(setq auto-save-default t)

(setq auto-save-interval 300)
(setq auto-save-timeout 30)

(setq auto-save-visited-interval 5)   ; Save after 5 seconds if inactivity
(auto-save-visited-mode 1)

(use-package corfu
  :ensure t
  :defer t
  :commands (corfu-mode global-corfu-mode)

  :hook ((prog-mode . corfu-mode)
         (shell-mode . corfu-mode)
         (eshell-mode . corfu-mode))

  :custom
  ;; Hide commands in M-x which do not apply to the current mode.
  (read-extended-command-predicate #'command-completion-default-include-p)
  ;; Disable Ispell completion function. As an alternative try `cape-dict'.
  (text-mode-ispell-word-completion nil)
  (tab-always-indent 'complete)

  ;; Enable Corfu
  :config
  (global-corfu-mode))

(use-package cape
  :ensure t
  :defer t
  :commands (cape-dabbrev cape-file cape-elisp-block)
  :bind ("C-c p" . cape-prefix-map)
  :init
  ;; Add to the global default value of `completion-at-point-functions' which is
  ;; used by `completion-at-point'.
  (add-hook 'completion-at-point-functions #'cape-dabbrev)
  (add-hook 'completion-at-point-functions #'cape-file)
  (add-hook 'completion-at-point-functions #'cape-elisp-block))

(use-package vertico
  ;; (Note: It is recommended to also enable the savehist package.)
  :ensure t
  :defer t
  :commands vertico-mode
  :hook (after-init . vertico-mode))

(use-package orderless
  ;; Vertico leverages Orderless' flexible matching capabilities, allowing users
  ;; to input multiple patterns separated by spaces, which Orderless then
  ;; matches in any order against the candidates.
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles partial-completion)))))

(use-package marginalia
  ;; Marginalia allows Embark to offer you preconfigured actions in more contexts.
  ;; In addition to that, Marginalia also enhances Vertico by adding rich
  ;; annotations to the completion candidates displayed in Vertico's interface.
  :ensure t
  :defer t
  :commands (marginalia-mode marginalia-cycle)
  :hook (after-init . marginalia-mode))

(use-package embark
  ;; Embark is an Emacs package that acts like a context menu, allowing
  ;; users to perform context-sensitive actions on selected items
  ;; directly from the completion interface.
  :ensure t
  :defer t
  :commands (embark-act
             embark-dwim
             embark-export
             embark-collect
             embark-bindings
             embark-prefix-help-command)
  :bind
  (("C-." . embark-act)         ;; pick some comfortable binding
   ("C-;" . embark-dwim)        ;; good alternative: M-.
   ("C-h B" . embark-bindings)) ;; alternative for `describe-bindings'

  :init
  (setq prefix-help-command #'embark-prefix-help-command)

  :config
  ;; Hide the mode line of the Embark live/completions buffers
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))

(use-package embark-consult
  :ensure t
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

(use-package consult
  :ensure t
  :bind (;; C-c bindings in `mode-specific-map'
         ("C-c M-x" . consult-mode-command)
         ("C-c h" . consult-history)
         ("C-c k" . consult-kmacro)
         ("C-c m" . consult-man)
         ("C-c i" . consult-info)
         ([remap Info-search] . consult-info)
         ;; C-x bindings in `ctl-x-map'
         ("C-x M-:" . consult-complex-command)
         ("C-x b" . consult-buffer)
         ("C-x 4 b" . consult-buffer-other-window)
         ("C-x 5 b" . consult-buffer-other-frame)
         ("C-x t b" . consult-buffer-other-tab)
         ("C-x r b" . consult-bookmark)
         ("C-x p b" . consult-project-buffer)
         ;; Custom M-# bindings for fast register access
         ("M-#" . consult-register-load)
         ("M-'" . consult-register-store)
         ("C-M-#" . consult-register)
         ;; Other custom bindings
         ("M-y" . consult-yank-pop)
         ;; M-g bindings in `goto-map'
         ("M-g e" . consult-compile-error)
         ("M-g f" . consult-flymake)
         ("M-g g" . consult-goto-line)
         ("M-g M-g" . consult-goto-line)
         ("M-g o" . consult-outline)
         ("M-g m" . consult-mark)
         ("M-g k" . consult-global-mark)
         ("M-g i" . consult-imenu)
         ("M-g I" . consult-imenu-multi)
         ;; M-s bindings in `search-map'
         ("M-s d" . consult-find)
         ("M-s c" . consult-locate)
         ("M-s g" . consult-grep)
         ("M-s G" . consult-git-grep)
         ("M-s r" . consult-ripgrep)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi)
         ("M-s k" . consult-keep-lines)
         ("M-s u" . consult-focus-lines)
         ;; Isearch integration
         ("M-s e" . consult-isearch-history)
         :map isearch-mode-map
         ("M-e" . consult-isearch-history)
         ("M-s e" . consult-isearch-history)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi)
         ;; Minibuffer history
         :map minibuffer-local-map
         ("M-s" . consult-history)
         ("M-r" . consult-history))

  ;; Enable automatic preview at point in the *Completions* buffer.
  :hook (completion-list-mode . consult-preview-at-point-mode)

  :init
  ;; Optionally configure the register formatting. This improves the register
  (setq register-preview-delay 0.5
        register-preview-function #'consult-register-format)

  ;; Optionally tweak the register preview window.
  (advice-add #'register-preview :override #'consult-register-window)

  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)

  :config
  (consult-customize
   consult-theme :preview-key '(:debounce 0.2 any)
   consult-ripgrep consult-git-grep consult-grep
   consult-bookmark consult-recent-file consult-xref
   consult--source-bookmark consult--source-file-register
   consult--source-recent-file consult--source-project-recent-file
   ;; :preview-key "M-."
   :preview-key '(:debounce 0.4 any))
  (setq consult-narrow-key "<"))

(use-package outline-indent
  :ensure t
  :defer t
  :commands outline-indent-minor-mode

  :custom
  (outline-indent-ellipsis " ▼ ")

  :init
  ;; The minor mode can also be automatically activated for a certain modes.
  (add-hook 'python-mode-hook #'outline-indent-minor-mode)
  (add-hook 'python-ts-mode-hook #'outline-indent-minor-mode)

  (add-hook 'yaml-mode-hook #'outline-indent-minor-mode)
  (add-hook 'yaml-ts-mode-hook #'outline-indent-minor-mode))

(use-package emacs
 :init
  (mapc #'disable-theme custom-enabled-themes)  ; Wyłącz wszystkie aktywne motywy
  
  ;; Add all your customizations prior to loading the themes
  (setq modus-themes-italic-constructs t
        modus-themes-bold-constructs nil
        modus-themes-region '(bg-only no-extend))
  
  (setq modus-themes-headings ; this is an alist: read the manual or its doc string
      '((1 . (rainbow overline background 1.5))
        (2 . (rainbow background 1.4))
        (3 . (rainbow bold 1.3))
        (4 . (semilight 1.2))
        (t . (semilight  1.1))))

  (setq modus-themes-scale-headings t)
  (setq modus-themes-org-blocks 'tinted-background)

  ;; Auxiliary function to toggle betwen bright and dark theme
  (defun toggle-theme ()
    (interactive)
    (if (eq (car custom-enabled-themes) 'modus-vivendi)
        (disable-theme 'modus-vivendi)
      (load-theme 'modus-vivendi :noconfirm)))
  
  (global-set-key [f6] 'toggle-theme)
  
  (load-theme 'modus-vivendi :noconfirm)  
)

;; (load-theme 'modus-operandi t)  ; Załaduj wbudowany motyw jasny
; (load-theme 'modus-vivendi t)  ; Załaduj wbudowany motyw ciemny
;;(load-theme 'leuven-dark t) ; tsdh-dark; leuven-dark

;; The undo-fu package is a lightweight wrapper around Emacs' built-in undo
;; system, providing more convenient undo/redo functionality.
(use-package undo-fu
  :defer t
  :commands (undo-fu-only-undo
             undo-fu-only-redo
             undo-fu-only-redo-all
             undo-fu-disable-checkpoint)
  :config
  (global-unset-key (kbd "C-z"))
  (global-set-key (kbd "C-z") 'undo-fu-only-undo)
  (global-set-key (kbd "C-S-z") 'undo-fu-only-redo))

;; The undo-fu-session package complements undo-fu by enabling the saving
;; and restoration of undo history across Emacs sessions, even after restarting.
(use-package undo-fu-session
  :defer t
  :commands undo-fu-session-global-mode
  :hook (after-init . undo-fu-session-global-mode))

(use-package eglot
  :ensure nil
  :defer t
  :commands (eglot
             eglot-ensure
             eglot-rename
             eglot-format-buffer))

(use-package easysession
  :ensure t
  :defer t
  :commands (easysession-switch-to
             easysession-save-as
             easysession-save-mode
             easysession-load-including-geometry)

  :custom
  (easysession-mode-line-misc-info t)  ; Display the session in the modeline
  (easysession-save-interval (* 10 60))  ; Save every 10 minutes

  :init
  ;; Key mappings:
  ;; C-c l for switching sessions
  ;; and C-c s for saving the current session
  (global-set-key (kbd "C-c l") 'easysession-switch-to)
  (global-set-key (kbd "C-c s") 'easysession-save-as)

  ;; The depth 102 and 103 have been added to to `add-hook' to ensure that the
  ;; session is loaded after all other packages. (Using 103/102 is particularly
  ;; useful for those using minimal-emacs.d, where some optimizations restore
  ;; `file-name-handler-alist` at depth 101 during `emacs-startup-hook`.)
  (add-hook 'emacs-startup-hook #'easysession-load-including-geometry 102)
  (add-hook 'emacs-startup-hook #'easysession-save-mode 103))

(use-package ispell
  :ensure nil
  :defer t
  :commands (ispell ispell-minor-mode)
  :custom
  ;; Set the ispell program name to aspell
  (ispell-program-name "aspell")

  ;; Configures Aspell's suggestion mode to "ultra", which provides more
  ;; aggressive and detailed suggestions for misspelled words. The language
  ;; is set to "en_US" for US English, which can be replaced with your desired
  ;; language code (e.g., "en_GB" for British English, "de_DE" for German).
  (ispell-extra-args '("--sug-mode=ultra" "--lang=pl_PL")))

(use-package flyspell
  :ensure nil
  :defer t
  :commands flyspell-mode
  :hook
  ((prog-mode . flyspell-prog-mode)
   (text-mode . (lambda()
                  (if (or (derived-mode-p 'yaml-mode)
                          (derived-mode-p 'yaml-ts-mode)
                          (derived-mode-p 'ansible-mode))
                      (flyspell-prog-mode)
                    (flyspell-mode 1)))))
  :config
  ;; Remove strings from Flyspell
  (setq flyspell-prog-text-faces (delq 'font-lock-string-face
                                       flyspell-prog-text-faces))

  ;; Remove doc from Flyspell
  (setq flyspell-prog-text-faces (delq 'font-lock-doc-face
                                       flyspell-prog-text-faces)))

(use-package helpful
  :defer t
  :commands (helpful-callable
             helpful-variable
             helpful-key
             helpful-command
             helpful-at-point
             helpful-function)
  :bind
  ([remap describe-command] . helpful-command)
  ([remap describe-function] . helpful-callable)
  ([remap describe-key] . helpful-key)
  ([remap describe-symbol] . helpful-symbol)
  ([remap describe-variable] . helpful-variable)
  :custom
  (helpful-max-buffers 7))

;; Enables automatic indentation of code while typing
(use-package aggressive-indent
  :ensure t
  :defer t
  :commands aggressive-indent-mode
  :hook
  (emacs-lisp-mode . aggressive-indent-mode))

;; Highlights function and variable definitions in Emacs Lisp mode
(use-package highlight-defined
  :ensure t
  :defer t
  :commands highlight-defined-mode
  :hook
  (emacs-lisp-mode . highlight-defined-mode))

;; Prevent parenthesis imbalance
(use-package paredit
  :ensure t
  :defer t
  :commands paredit-mode
  :hook
  (emacs-lisp-mode . paredit-mode)
  :config
  (define-key paredit-mode-map (kbd "RET") nil))

;; For paredit+Evil mode users: enhances paredit with Evil mode compatibility
;; --------------------------------------------------------------------------
;; (use-package enhanced-evil-paredit
;;   :ensure t
;;   :defer t
;;   :commands enhanced-evil-paredit-mode
;;   :hook
;;   (paredit-mode . enhanced-evil-paredit-mode))

;; Displays visible indicators for page breaks
(use-package page-break-lines
  :ensure t
  :defer t
  :commands (page-break-lines-mode
             global-page-break-lines-mode)
  :hook
  (emacs-lisp-mode . page-break-lines-mode))

;; Provides functions to find references to functions, macros, variables,
;; special forms, and symbols in Emacs Lisp
(use-package elisp-refs
  :ensure t
  :defer t
  :commands (elisp-refs-function
             elisp-refs-macro
             elisp-refs-variable
             elisp-refs-special
             elisp-refs-symbol))

;; (setq custom-file null-device)

;; Allow Emacs to upgrade built-in packages, such as Org mode
(setq package-install-upgrade-built-in t)

;; Display the current line and column numbers in the mode line
(setq line-number-mode t)
(setq column-number-mode t)
(setq mode-line-position-column-line-format '("%l:%C"))

;; Display of line numbers in the buffer:
;; (display-line-numbers-mode 1)

(use-package which-key
  :ensure nil ; builtin
  :defer t
  :commands which-key-mode
  :hook (after-init . which-key-mode)
  :custom
  (which-key-idle-delay 1.5)
  (which-key-idle-secondary-delay 0.25)
  (which-key-add-column-padding 1)
  (which-key-max-description-length 40))

(unless (and (eq window-system 'mac)
             (bound-and-true-p mac-carbon-version-string))
  ;; Enables `pixel-scroll-precision-mode' on all operating systems and Emacs
  ;; versions, except for emacs-mac.
  ;;
  ;; Enabling `pixel-scroll-precision-mode' is unnecessary with emacs-mac, as
  ;; this version of Emacs natively supports smooth scrolling.
  ;; https://bitbucket.org/mituharu/emacs-mac/commits/65c6c96f27afa446df6f9d8eff63f9cc012cc738
  (setq pixel-scroll-precision-use-momentum nil) ; Precise/smoother scrolling
  (pixel-scroll-precision-mode 1))

;; Display the time in the modeline
(add-hook 'after-init-hook #'display-time-mode)

;; Paren match highlighting
(add-hook 'after-init-hook #'show-paren-mode)

;; Track changes in the window configuration, allowing undoing actions such as
;; closing windows.
(add-hook 'after-init-hook #'winner-mode)

;; Replace selected text with typed text
;; (delete-selection-mode 1)

(use-package uniquify
  :ensure nil
  :custom
  (uniquify-buffer-name-style 'reverse)
  (uniquify-separator "•")
  (uniquify-after-kill-buffer-p t)
  (uniquify-ignore-buffers-re "^\\*"))

;; Window dividers separate windows visually. Window dividers are bars that can
;; be dragged with the mouse, thus allowing you to easily resize adjacent
;; windows.
;; https://www.gnu.org/software/emacs/manual/html_node/emacs/Window-Dividers.html
(add-hook 'after-init-hook #'window-divider-mode)

;; Dired buffers: Automatically hide file details (permissions, size,
;; modification date, etc.) and all the files in the `dired-omit-files' regular
;; expression for a cleaner display.
(add-hook 'dired-mode-hook #'dired-hide-details-mode)

;; Hide files from dired
(setq dired-omit-files (concat "\\`[.]\\'"
                               "\\|\\(?:\\.js\\)?\\.meta\\'"
                               "\\|\\.\\(?:elc|a\\|o\\|pyc\\|pyo\\|swp\\|class\\)\\'"
                               "\\|^\\.DS_Store\\'"
                               "\\|^\\.\\(?:svn\\|git\\)\\'"
                               "\\|^\\.ccls-cache\\'"
                               "\\|^__pycache__\\'"
                               "\\|^\\.project\\(?:ile\\)?\\'"
                               "\\|^flycheck_.*"
                               "\\|^flymake_.*"))
(add-hook 'dired-mode-hook #'dired-omit-mode)

;; Configure Emacs to ask for confirmation before exiting
(setq confirm-kill-emacs 'y-or-n-p)

;; Enabled backups save your changes to a file intermittently
(setq make-backup-files t)
(setq vc-make-backup-files t)
(setq kept-old-versions 10)
(setq kept-new-versions 10)

(use-package emacs
  :bind
  ("C-+" . text-scale-increase)
  ("C--" . text-scale-decrease)
  ("<C-wheel-up>" . text-scale-increase)
  ("<C-wheel-down>" . text-scale-decrease))

(use-package emacs
  :custom
  (setq display-fill-column-indicator-column 81)
  (global-display-fill-column-indicator-mode t)
)

(use-package smart-shift
  :ensure t ; builtin
  :defer t
  :bind 
  (("M-p" . smart-shift-up)   
   ("M-n" . smart-shift-down)
   ;; ("M-s-<left>" . smart-shift-left)    
   ;; ("M-s-<right>" . smart-shift-right)
  ) 
   ;; C-x TAB:    left/right
)

;; windmove ->
;; Easy moving between windows
  
(use-package windmove
  :defer t
  :bind
  (("M-s-<left>"  . windmove-left)
   ("M-s-<right>" . windmove-right)
   ("M-s-<up>"    . windmove-up)
   ("M-s-<down>"  . windmove-down)   
  ) 
)

;; buffer-move - swap buffers easily
(use-package buffer-move
  :defer t)

;; Easy windows resize ->
(use-package emacs
  :bind
  (("C-s-<left>" . shrink-window-horizontally)
   ("C-s-<right>" . enlarge-window-horizontally))
  ;; (global-set-key        (kbd "C-s-<down>") 'shrink-window)
  ;; (global-set-key        (kbd "C-s-<up>") 'enlarge-window)
)

(use-package emacs
  :bind
  (("C-s-<down>" . shrink-window)
   ("C-s-<up>" . enlarge-window))
)
;; <- Easy windows resize

(use-package whitespace
  :defer t
  :init
  (setq whitespace-display-mappings '(
    (space-mark   ?\xA0  [?\u00A4]     [?_])     ;; spacja jako kropeczka
    (space-mark   ?\     [?\u00B7]     [?.])     ;; spacja jako kropeczka
    ;; (space-mark   ?\     [?\u0020]     [?.])  ;; spacja jako spacja
    (newline-mark ?\n    [?¶ ?\n])
    (tab-mark     ?\t    [?\u00BB ?\t] [?\\ ?\t])
  ))

  (setq whitespace-line-column 81)

  ;; (setq whitespace-style-1 '(face space-mark tab-mark lines-tail) )
  ;; (setq whitespace-style-2 '(face space-mark tab-mark newline-mark lines-tail) )
  (setq mb/whitespace-styles  '(
        (face  tab-mark lines-tail trailing)
        (face space-mark tab-mark newline-mark lines-tail)
        )
  )

  ;; (setq whitespace-style whitespace-style-1)

  ;; Don't enable whitespace for.
  (setq-default whitespace-global-modes
                '(not shell-mode
                      help-mode
                      magit-mode
                      magit-diff-mode
                      ibuffer-mode
                      dired-mode
                      occur-mode))

  (defun mb/whitespace-mode(no)
    (interactive)
    (setq whitespace-style (nth no mb/whitespace-styles))
    (whitespace-mode)
    (whitespace-mode)
   )

  ;; (custom-set-faces
  ;; '(whitespace-space ((t (:bold t :foreground "gray75"))))
  ;; '(whitespace-empty ((t (:foreground "firebrick" :background "SlateGray1"))))
  ;; '(whitespace-hspace ((t (:foreground "lightgray" :background "LemonChiffon3"))))
  ;; '(whitespace-indentation ((t (:foreground "firebrick" :background "beige"))))
  ;; ;; '(whitespace-line ((t (:foreground "black" :background "red"))))
  ;; '(whitespace-newline ((t (:foreground "orange" :background "blue"))))
  ;; '(whitespace-space-after-tab ((t (:foreground "black" :background "green"))))
  ;; '(whitespace-space-before-tab ((t (:foreground "black" :background "DarkOrange"))))
  ;; '(whitespace-tab ((t (:foreground "blue" :background "white"))))
  ;; '(whitespace-trailing ((t (:foreground "red" :background "yellow"))))
  ;; )
)

;; toc-org for table of contents in org-mode
(use-package org
  :pin gnu
  :defer t
  :mode (("\\.org$" . org-mode))
  :ensure org-contrib  ; in order to have ox-extra and :ignore: tag
  ;; :ensure org-special-block-extras ; in order to play with MB-org-special-block-extras
  :config
  (progn
    ;; config stuff
    (require 'ox-extra)
    (ox-extras-activate '(ignore-headlines))
  )

  ;; Proper export of =$n$-th=-like strings from org-mode to latex
  ;; This function stopped working aroung Emacs 30.1 and org 9.7.11
  (defun my-org-change-minus-syntax-fun ()
    (modify-syntax-entry ?- "."))

  (add-hook 'org-mode-hook #'my-org-change-minus-syntax-fun)
  

  
  ;; (add-hook #'org-mode-hook #'org-special-block-extras-mode)  
  ;; 
  ;; (add-to-list 'load-path "~/.emacs.d/myarch")
  ;; (require 'MB-org-special-block-extras)
)

;; (add-hook #'org-mode-hook #'org-special-block-extras-mode)

(use-package htmlize ;; needed to have org-special-block-extras exporting to html flawlessly
  :defer t
)

(use-package org-special-block-extras
  :ensure t  
  :hook (org-mode . org-special-block-extras-mode)
  ;; All relevant Lisp functions are prefixed ‘o-’; e.g., `o-docs-insert'.
  ;; :custom
  ;;   (o-docs-libraries
  ;;    '("~/org-special-block-extras/documentation.org")
  ;;    "The places where I keep my ‘#+documentation’")
)

;; toc-org for table of contents in org-mode
(use-package toc-org
  :commands toc-org-enable
  :hook (org-mode . toc-org-mode))

;; customized todo-done sequence
(use-package emacs

  :init
  (setq org-todo-keywords
    '(
  (sequence "TODO" "????" "POSTPONED" "|" "DONE")
  (sequence "TODO" "ABANDONED"  "|" "DEPRECATED" "DONE")
  (sequence "TODO" "????" "ABANDONED" "POSTPONED" "|" "DEPRECATED" "DONE")
  ))
  
  (setq org-todo-keyword-faces
  '(
  ("????"         . (:foreground "red" :weight bold))
  ("POSTPONED"    . (:foreground "orange" :weight bold))
  ("DONE"         . (:foreground "purple" :weight bold))
  ("ABANDONED"    . (:foreground "blue" :weight bold))
  ("DEPRECATED"   . (:foreground "blue" :weight bold))
  ("[OPTIONALLY]" . (:foreground "violet" :weight bold))
  ("[OPCJONALNIE]" . (:foreground "violet" :weight bold))
  )
  )
  
  (defun org-latex-format-headline-colored-keywords-function
      (todo _todo-type priority text tags _info)
    "Default format function for a headline.
  See `org-latex-format-headline-function' for details."
    (concat
     ;; (and todo (format "{\\bfseries\\sffamily %s} " todo))
    (cond
     ((string= todo "TODO")(and todo (format "{\\color{red}\\bfseries\\sffamily %s} " todo)))
     ((string= todo "????")(and todo (format "{\\color{red}\\bfseries\\sffamily %s} " todo)))
     ((string= todo "POSTPONED")(and todo (format "{\\color{blue}\\bfseries\\sffamily %s} " todo)))
     ((string= todo "DEPRECATED")(and todo (format "{\\color{blue}\\bfseries\\sffamily %s} " todo)))
     ((string= todo "DONE")(and todo (format "{\\color{green}\\bfseries\\sffamily %s} " todo)))
     )
     (and priority (format "\\framebox{\\#%c} " priority))
     text
     (and tags
  	(format "\\hfill{}\\textsc{ %s}"
  		(mapconcat #'org-latex--protect-text tags ":")))))
  
  (setq org-latex-format-headline-function 'org-latex-format-headline-colored-keywords-function)
  
  
  
  ;; toggle between TODO tag keywords for all subnodes of the current node
  (defun mb/org-toggle-org-keywords-right ()
      "Toggle between todo-done keywords for all subnodes of the current node."
      (interactive)
      (org-map-entries (lambda () (org-shiftright)) nil 'tree)
    )
  (defun mb/org-toggle-org-keywords-left ()
      "Toggle between todo-done keywords for all subnodes of the current node."
      (interactive)
      (org-map-entries (lambda () (org-shiftleft)) nil 'tree)
    )
)

(use-package engrave-faces
  :init
  (setq org-latex-src-block-backend 'engraved)
 
  (setq org-latex-engraved-preamble
	"\\usepackage{fvextra}

	[FVEXTRA-SETUP]

	% Make line numbers smaller and grey.
  \\renewcommand\\theFancyVerbLine{\\footnotesize\\color{black!40!white}\\arabic{FancyVerbLine}}

	\\usepackage{xcolor}

	% In case engrave-faces-latex-gen-preamble has not been run.
	\\providecolor{EfD}{HTML}{f7f7f7}
	\\providecolor{EFD}{HTML}{28292e}

	% Define a Code environment to prettily wrap the fontified code.
	\\IfPackageLoadedTF{tcolorbox}{}{\\usepackage[breakable,xparse]{tcolorbox}}
	\\DeclareTColorBox[]{Code}{o}%
	{colback=EfD!98!EFD, colframe=EfD!95!EFD,
	  fontupper=\\footnotesize\\setlength{\\fboxsep}{0pt},
	  colupper=EFD,
	  IfNoValueTF={#1}%
	  {boxsep=2pt, arc=2.5pt, outer arc=2.5pt,
	    boxrule=0.5pt, left=2pt}%
	  {boxsep=2.5pt, arc=0pt, outer arc=0pt,
	    boxrule=0pt, leftrule=1.5pt, left=0.5pt},
	  right=2pt, top=1pt, bottom=0.5pt,
	  breakable}

	[LISTINGS-SETUP]

        % this is LaTeX source code!!! comment with % sign!
        % \\newenvironment{ai}
        % {
        % \\begin{Code}
        % }
        % {
        % \\end{Code}
        % }
      "
      )

  (setq org-latex-engraved-options
    '(
      ("commandchars" . "\\\\\\{\\}")
      ("highlightcolor" . "white!95!black!80!blue")
      ("breaklines" . "true")
      ("breaksymbol" . "\\color{white!60!black}\\tiny\\ensuremath{\\hookrightarrow}")
      ("highlightcolor" . "lightgray")
      ("frame" . "single")
      ("numbers" . "left")
      )
    )  
  )

(use-package emacs
  :init
  ;; enabling org-babel
  (org-babel-do-load-languages
   'org-babel-load-languages '(
			       (C . t) ; enable processing C, C++, and D source blocks
			       (julia . t)
			       (js . t)
			       (latex . t)
			       (matlab . t)
			       (octave . t)
			       (org . t)
			       ;;(perl . t)
			       (plantuml . t)
			       (python . t)
			       ;; (scad . t) dodawane do listy przy wywołanu use-package scad-mode
			       (shell . t)
			       ))
  ;; no question about confirmation of evaluating babel code block
  (setq org-confirm-babel-evaluate nil)
)

(use-package scad-mode
  :ensure t
  :defer t  ;; Opóźnione ładowanie o 2 sekundy
  :config
  (with-eval-after-load 'org
    (add-to-list 'org-babel-load-languages '(scad . t))
    (org-babel-do-load-languages 'org-babel-load-languages org-babel-load-languages)))

(use-package emacs
 :init
  ;; Set your agenda files/directories (as a list of paths)
  (setq org-agenda-files '("~/org/agenda/" "~/.notes") )
)

;; (use-package emacs
;;   :init
;;   ;; enabling plantuml
;;   (setq plantuml-executable-path "plantuml")
;;   (setq org-plantuml-exec-mode 'plantuml)
;; 
;;   ; in order to recognize #+begin_src plantuml as a language
;;   ; now you can C-c C-' to edit source block in a separate buffer
;;   (add-to-list 'org-src-lang-modes '("plantuml" . fundamental))
;; )

(use-package plantuml-mode
  :defer t
  
  :init
  ;; Enable plantuml-mode for PlantUML files
  (add-to-list 'auto-mode-alist '("\\.plantuml\\'" . plantuml-mode))
  
  :config
  ;; Integration with org-mode
  (add-to-list  'org-src-lang-modes '("plantuml" . plantuml))
  
  ;; enabling plantuml
  ;; (setq plantuml-executable-path "plantuml")
  ;; (setq org-plantuml-exec-mode 'plantuml)

  ; in order to recognize #+begin_src plantuml as a language
  ; now you can C-c C-' to edit source block in a separate buffer
  ;; (add-to-list 'org-src-lang-modes '("plantuml" . fundamental))
)

(use-package emacs
  :init 
  ;; Recently opened files ->
  (recentf-mode 1)
  (setq recentf-max-menu-items 1000)
  (setq recentf-max-saved-items 1000)
  ;; in original emacs this binding is for "Find file read-only"
  (global-set-key "\C-x\ \C-r" 'recentf-open-files)
  ;; <- Recently opened files
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Useful global shortcuts (system-wide operations)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package emacs
  :init 
  (defun mb/browse-file-directory()
  (interactive)
  ;; (shell-command "dolphin .")  
  ;; (shell-command "thunar . &")  ; to uruchamia w shell-async!
  ;; (async-shell-command "thunar &")
  (start-process "my-browse" nil "setsid" "thunar")
  )

  (define-key global-map (kbd "<s-f12>") 'mb/browse-file-directory)

  ; Backspace/Insert remapping
  (global-set-key (kbd "C-d") 'delete-forward-char)
  (global-set-key (kbd "C-S-d") 'delete-backward-char)

  (defun mb/buffer-directory ()
    "Show current buffer's filepath (if exist)"
    (interactive)
    (if buffer-file-name
        (progn
        (kill-new (expand-file-name (file-name-directory buffer-file-name)))
        (message "Copied buffer directory to kill-ring:: %s" (file-name-directory buffer-file-name)))
      (message "Current buffer is not a file's buffer.")))

  (defun mb/buffer-absolute-path ()
    "Copy the absolute file path of the current buffer to the kill-ring."
    (interactive)
    (if buffer-file-name
        (progn
          (kill-new (expand-file-name buffer-file-name))
          (message "Copied buffer file path to kill-ring: %s" buffer-file-name))
      (message "Current buffer is not visiting a file.")))

)

    (use-package rainbow-delimiters
      :hook (prog-mode . rainbow-delimiters-mode))

(use-package octave
  :defer t
  :config
  (add-to-list 'auto-mode-alist '("\\.m\\'" . octave-mode))

  (add-hook 'octave-mode-hook
    (lambda () (progn (setq octave-comment-char ?%)
                      (setq comment-start "% ")
                      (setq comment-add 0))))
)

(use-package matlab
  :ensure matlab-mode
  :defer t
  :config
  (add-to-list
   'auto-mode-alist
   '("\\.m\\'" . matlab-mode))
  ; (setq matlab-indent-function t)
  (setq matlab-shell-command "matlab")

  ;; setup matlab in babel
  ; (setq org-babel-default-header-args:matlab
  ; '((:results . "output") (:session . "*MATLAB*")))
  
  ; (setq org-babel-default-header-args:matlab
  ; '())  
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Block of custom auxiliary code for managing filtering of
;; org-mode source of init.el content. Enables exporting init.el
;; for private/public purposes.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; (use-package emacs
;;  :init 
  (setq mb/tangle-for-private-purposes t)

  (defun mb/public/private-tangling-filter (outputFile)
   (if mb/tangle-for-private-purposes (concat (org-entry-get nil "PRJ-DIR" t) outputFile) "" )
  )

  (defun mb/toggle-public/private-tangling ()
    "Toggle the boolean value of VAR between t and nil.
     Display a message with the new value."
    (interactive)
    (setq mb/tangle-for-private-purposes
     (not mb/tangle-for-private-purposes))
    (message (concat "Private tangling is now "
  	   (if mb/tangle-for-private-purposes "enabled" "disabled") "." ))
  )

;; )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ;; Kod tymczasowy
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; (find-file "~/org/2025.03.20-konfiguracja-emacsa-od-podstaw---podejście-drugie/2025.03.20-konfiguracja-emacsa-od-podstaw---podejście-drugie.org")

;; (find-file "~/org/2025.03.20-konfiguracja-emacsa-od-podstaw---podejście-drugie/src/.memacs.d/post-init.el")

(setq display-fill-column-indicator-column 81)

(display-fill-column-indicator-mode)
(scroll-bar-mode t)

  ;; All done
  (message "All done in post-init.el.")
