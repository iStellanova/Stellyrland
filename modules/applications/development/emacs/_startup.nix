''
  ;;; -*- lexical-binding: t; -*-
  ;; Startup
  (setq inhibit-startup-screen t
        initial-buffer-choice t
        initial-scratch-message nil)

  ;; Theme
  (add-to-list 'custom-theme-load-path
               (file-name-directory (locate-library "catppuccin-theme")))
  (setq catppuccin-flavor 'macchiato)
  (load-theme 'catppuccin t)

  ;; Completion
  (require 'vertico)
  (vertico-mode 1)
  (setq completion-cycle-threshold 3
        tab-always-indent 'complete)
  (global-completion-preview-mode 1)

  ;; Nix and tree-sitter
  (when-let ((grammar-path (getenv "EMACS_TREESIT_GRAMMAR_PATH")))
    (add-to-list 'treesit-extra-load-path grammar-path))
  (require 'nix-ts-mode)
  (add-to-list 'auto-mode-alist '("\\.nix\\'" . nix-ts-mode))

  ;; Persistent editor state
  (savehist-mode 1)
  (recentf-mode 1)
  (save-place-mode 1)

  ;; Language servers
  (require 'eglot)
  (add-to-list 'eglot-server-programs '(nix-ts-mode . ("nixd")))

  (add-hook 'nix-ts-mode-hook #'eglot-ensure)
  (add-hook 'sh-mode-hook #'eglot-ensure)
  (add-hook 'clojure-mode-hook #'eglot-ensure)

  ;; Editor display and scrolling
  (set-face-attribute 'line-number nil
                      :foreground (catppuccin-get-color 'overlay1)
                      :background (catppuccin-get-color 'base))
  (setq scroll-conservatively 101
        scroll-step 1)
  (add-hook 'display-line-numbers-mode-hook
            (lambda ()
              (setq display-line-numbers
                    (and display-line-numbers-mode 'relative))))
  (add-hook 'prog-mode-hook #'display-line-numbers-mode)
  (add-hook 'text-mode-hook #'display-line-numbers-mode)
  (add-hook 'prog-mode-hook #'hl-line-mode)
  (add-hook 'text-mode-hook #'hl-line-mode)
  (add-hook 'special-mode-hook (lambda () (display-line-numbers-mode -1)))

  ;; Tabs and indentation
  (use-package indent-bars
    :custom
    (indent-bars-display-on-blank-lines t)
    (indent-bars-prefer-character t)
    (indent-bars-defer-setup t)
    :hook
    (prog-mode . indent-bars-mode))
  ;; Nix uses spaces and a two-column indent; set both before bars initialize.
  (add-hook 'nix-ts-mode-hook
            (lambda ()
              (setq-local indent-tabs-mode nil
                          indent-bars-spacing-override
                          nix-ts-mode-indent-offset)))
  (setq tab-line-close-tab-function 'kill-buffer)
  (add-hook 'prog-mode-hook #'tab-line-mode)
  (add-hook 'text-mode-hook #'tab-line-mode)

  ;; Markdown
  (require 'markdown-mode)
  (add-hook 'markdown-mode-hook #'visual-line-mode)
  (add-hook 'markdown-mode-hook #'flyspell-mode)

  ;; Project tree
  (require 'treemacs-project-follow-mode)
  (require 'treemacs-nerd-icons)
  (treemacs-nerd-icons-config)
  (set-face-attribute 'treemacs-git-modified-face nil
                      :foreground (catppuccin-get-color 'peach))
  (treemacs-filewatch-mode 1)
  (treemacs-follow-mode 1)
  (treemacs-project-follow-mode 1)
  (setq treemacs-width 32
        treemacs-width-is-initially-locked t)
  (add-hook 'emacs-startup-hook
            #'treemacs-add-and-display-current-project-exclusively)

  ;; Diff indicators
  (require 'diff-hl)
  (global-diff-hl-mode 1)

  ;; Remote programs through TRAMP
  (require 'tramp)
  (add-to-list 'tramp-remote-path 'tramp-own-remote-path)

  ;; Agent integration
  (require 'agent-shell)
''
