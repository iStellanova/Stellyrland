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
  (tab-bar-mode -1)
  (require 'tab-line)
  (setq tab-line-close-tab-function 'kill-buffer)
  (add-hook 'prog-mode-hook #'tab-line-mode)
  (add-hook 'text-mode-hook #'tab-line-mode)
  (add-hook 'term-mode-hook #'tab-line-mode)
  (add-hook 'find-file-hook
            (lambda ()
              (when buffer-file-name
                (tab-line-mode 1))))
  (global-set-key (kbd "C-x k") #'kill-buffer-and-window)
  (global-set-key (kbd "C-c ]") #'tab-line-switch-to-next-tab)
  (global-set-key (kbd "C-c [") #'tab-line-switch-to-prev-tab)

  (require 'markdown-mode)
  (add-hook 'markdown-mode-hook #'visual-line-mode)
  (add-hook 'markdown-mode-hook #'flyspell-mode)

  (require 'treemacs)
  (require 'treemacs-nerd-icons)
  (treemacs-nerd-icons-config)
  (set-face-attribute 'treemacs-git-modified-face nil
                      :foreground (catppuccin-get-color 'peach))
  (treemacs-filewatch-mode 1)
  (setq treemacs-width 32
        treemacs-follow-mode t
        treemacs-project-follow-mode t
        treemacs-width-is-initially-locked t)
  (setq initial-buffer-choice (lambda () (get-buffer-create "*scratch*")))
  (add-hook 'emacs-startup-hook
            #'treemacs-add-and-display-current-project-exclusively)
  (global-set-key (kbd "C-c t") #'treemacs)

  (require 'diff-hl)
  (require 'diff-hl-margin)
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
  (defun macs-open-terminal ()
    (interactive)
    (term (getenv "SHELL")))
  (global-set-key (kbd "C-c e") #'macs-open-terminal)

  (require 'project)
  (require 'fzf)
  (setq fzf/window-height 20
        fzf/args "-x --ansi --color=dark --print-query --margin=1,0 --no-hscroll"
        fzf/args-for-preview
        "--preview 'bat --color=always --theme=\"Catppuccin Macchiato\" --paging=never --style=numbers --line-range=:500 {}'"
        fzf/grep-command "rg --no-heading --color never --line-number")
  (defun macs-fzf-find-file ()
    (interactive)
    (let ((window
           (get-window-with-predicate
            (lambda (candidate)
              (and (not (window-minibuffer-p candidate))
                   (not (window-parameter candidate 'window-side)))))))
      (unless window
        (user-error "No main editor window available"))
      (select-window window)
      (let ((default-directory
             (if-let ((project (project-current)))
                 (project-root project)
               default-directory))
            (process-environment (copy-sequence process-environment)))
        (setenv "FZF_DEFAULT_COMMAND"
                "fd --type f --hidden --exclude .git")
        (fzf t))))
  (global-set-key (kbd "C-c b") #'fzf-switch-buffer)
  (global-set-key (kbd "C-c f") #'macs-fzf-find-file)
  (global-set-key (kbd "C-c r") #'fzf-grep)
  (global-set-key (kbd "C-c l") #'fzf-find-in-buffer)
  (global-set-key (kbd "C-c p") project-prefix-map)
  (global-set-key (kbd "C-c g") #'magit-status)
''
