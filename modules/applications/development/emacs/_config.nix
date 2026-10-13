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
''
