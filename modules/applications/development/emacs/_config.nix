''
  (add-to-list 'custom-theme-load-path
               (file-name-directory (locate-library "catppuccin-theme")))
  (setq catppuccin-flavor 'macchiato)
  (load-theme 'catppuccin t)

  (require 'eglot)
  (add-to-list 'eglot-server-programs '(nix-mode . ("nixd")))
  (add-to-list 'eglot-server-programs '(lua-mode . ("lua-language-server")))
  (add-to-list 'eglot-server-programs '(sh-mode . ("bash-language-server" "start")))
  (add-to-list 'eglot-server-programs '(clojure-mode . ("clojure-lsp")))
  (add-to-list 'eglot-server-programs '(c-mode . ("clangd")))
  (add-to-list 'eglot-server-programs '(c++-mode . ("clangd")))
  (add-to-list 'eglot-server-programs '(java-mode . ("jdtls")))

  (add-hook 'nix-mode-hook #'eglot-ensure)
  (add-hook 'lua-mode-hook #'eglot-ensure)
  (add-hook 'sh-mode-hook #'eglot-ensure)
  (add-hook 'clojure-mode-hook #'eglot-ensure)
  (add-hook 'c-mode-hook #'eglot-ensure)
  (add-hook 'c++-mode-hook #'eglot-ensure)
  (add-hook 'java-mode-hook #'eglot-ensure)

  (setq completion-cycle-threshold 3
        tab-always-indent 'complete)

  (add-hook 'eglot-managed-mode-hook
            (lambda ()
              (flymake-mode 1)))

  (require 'treemacs)
  (setq treemacs-width 32
        treemacs-follow-mode t
        treemacs-project-follow-mode t
        treemacs-width-is-initially-locked t)
  (setq initial-buffer-choice (lambda () (get-buffer-create "*scratch*")))
  (add-hook 'emacs-startup-hook
            #'treemacs-add-and-display-current-project-exclusively)
  (global-set-key (kbd "C-c t") #'treemacs)

  (require 'project)
  (require 'vc)
  (require 'xref)
  (require 'magit)
  (global-set-key (kbd "C-c p") project-prefix-map)
  (global-set-key (kbd "C-c g") #'magit-status)
''
