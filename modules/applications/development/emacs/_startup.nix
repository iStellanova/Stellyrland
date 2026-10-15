''
  ;;; -*- lexical-binding: t; -*-
  (add-to-list 'custom-theme-load-path
               (file-name-directory (locate-library "catppuccin-theme")))
  (setq catppuccin-flavor 'macchiato)
  (load-theme 'catppuccin t)

  (require 'vertico)
  (vertico-mode 1)

  (global-completion-preview-mode 1)

  (when-let ((grammar-path (getenv "EMACS_TREESIT_GRAMMAR_PATH")))
    (add-to-list 'treesit-extra-load-path grammar-path))
  (require 'nix-ts-mode)
  (add-to-list 'auto-mode-alist '("\\.nix\\'" . nix-ts-mode))

  (savehist-mode 1)
  (recentf-mode 1)
  (save-place-mode 1)

  (require 'eglot)
  (add-to-list 'eglot-server-programs '(nix-ts-mode . ("nixd")))

  (add-hook 'nix-ts-mode-hook #'eglot-ensure)
  (add-hook 'sh-mode-hook #'eglot-ensure)
  (add-hook 'clojure-mode-hook #'eglot-ensure)

  (set-face-attribute 'line-number nil
                      :foreground (catppuccin-get-color 'overlay1)
                      :background (catppuccin-get-color 'base))
  (setq completion-cycle-threshold 3
        tab-always-indent 'complete
        scroll-conservatively 101
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
  (require 'indent-bars)
  (setq tab-line-close-tab-function 'kill-buffer)
  (add-hook 'prog-mode-hook #'tab-line-mode)
  (add-hook 'prog-mode-hook #'indent-bars-mode)
  (add-hook 'text-mode-hook #'tab-line-mode)
  (add-hook 'term-mode-hook #'tab-line-mode)

  (require 'markdown-mode)
  (add-hook 'markdown-mode-hook #'visual-line-mode)
  (add-hook 'markdown-mode-hook #'flyspell-mode)

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
  (setq initial-buffer-choice (lambda () (get-buffer-create "*scratch*")))
  (add-hook 'emacs-startup-hook
            #'treemacs-add-and-display-current-project-exclusively)

  (require 'diff-hl)
  (global-diff-hl-mode 1)

  (require 'term)
  (require 'hermes)
''