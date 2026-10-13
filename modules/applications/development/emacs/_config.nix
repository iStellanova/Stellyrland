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

  (require 'markdown-mode)
  (require 'eww)
  (defvar-local stellyr-markdown-preview-file nil)
  (defun stellyr-markdown-preview ()
    (interactive)
    (when (and stellyr-markdown-preview-file
               (file-exists-p stellyr-markdown-preview-file))
      (delete-file stellyr-markdown-preview-file))
    (let ((file (make-temp-file "stellyr-markdown-" nil ".html"))
          (output "*stellyr-markdown-preview*"))
      (markdown-standalone output (buffer-name))
      (with-current-buffer output
        (write-region (point-min) (point-max) file nil 'silent))
      (setq stellyr-markdown-preview-file file)
      (add-hook 'kill-buffer-hook
                (lambda ()
                  (when (and stellyr-markdown-preview-file
                             (file-exists-p stellyr-markdown-preview-file))
                    (delete-file stellyr-markdown-preview-file)))
                nil t)
      (eww-open-file file)))
  (define-key markdown-mode-map (kbd "C-c C-c p")
              #'stellyr-markdown-preview)
  (add-hook 'markdown-mode-hook #'visual-line-mode)
  (add-hook 'markdown-mode-hook #'flyspell-mode)
  (add-hook 'markdown-mode-hook
            (lambda ()
              (setq-local markdown-command "markdown_py")))

  (require 'treemacs)
  (setq treemacs-width 32
        treemacs-follow-mode t
        treemacs-project-follow-mode t
        treemacs-width-is-initially-locked t)
  (setq initial-buffer-choice (lambda () (get-buffer-create "*scratch*")))
  (add-hook 'emacs-startup-hook
            #'treemacs-add-and-display-current-project-exclusively)
  (global-set-key (kbd "C-c t") #'treemacs)

  (require 'diff-hl)
  (global-diff-hl-mode 1)
  (add-hook 'diff-hl-mode-hook
            (lambda ()
              (unless (display-graphic-p)
                (diff-hl-margin-mode 1))))

  (require 'term)
  (define-key term-raw-escape-map (kbd "j") #'term-line-mode)
  (define-key term-raw-escape-map (kbd "k") #'term-char-mode)
  (define-key term-raw-escape-map (kbd "o") #'other-window)
  (define-key term-raw-escape-map (kbd "b") #'switch-to-buffer)
  (defun stellyr-open-terminal ()
    (interactive)
    (term (getenv "SHELL")))
  (global-set-key (kbd "C-c e") #'stellyr-open-terminal)

  (require 'project)
  (require 'vc)
  (require 'xref)
  (require 'magit)
  (global-set-key (kbd "C-c p") project-prefix-map)
  (global-set-key (kbd "C-c g") #'magit-status)
''
