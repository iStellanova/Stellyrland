''
  ;;; -*- lexical-binding: t; -*-
  (setq inhibit-startup-screen t
        initial-buffer-choice t
        initial-scratch-message nil)
  (setq backup-directory-alist
        `(("." . ,(expand-file-name "backups/" user-emacs-directory))))
  (let ((autosave-dir (expand-file-name "autosave/" user-emacs-directory)))
    (make-directory autosave-dir t)
    (setq auto-save-file-name-transforms
          (append auto-save-file-name-transforms `((".*" ,autosave-dir t)))))

  (add-to-list 'custom-theme-load-path
               (file-name-directory (locate-library "catppuccin-theme")))
  (setq catppuccin-flavor 'macchiato)
  (load-theme 'catppuccin t)

  (require 'vertico)
  (vertico-mode 1)
  (setq completion-cycle-threshold 3
        tab-always-indent 'complete)
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

  (set-face-attribute 'line-number nil
                      :foreground (catppuccin-get-color 'overlay1)
                      :background (catppuccin-get-color 'base))
  (setq scroll-conservatively 101
        scroll-step 1)
  (setq display-line-numbers-type 'relative)
  (add-hook 'prog-mode-hook #'display-line-numbers-mode)
  (add-hook 'text-mode-hook #'display-line-numbers-mode)
  (add-hook 'prog-mode-hook #'hl-line-mode)
  (add-hook 'text-mode-hook #'hl-line-mode)
  (require 'ox-epub)
  (add-hook 'org-mode-hook #'visual-line-mode)
  (add-hook 'org-mode-hook (lambda () (wc-mode 1)))
  (add-hook 'special-mode-hook (lambda () (display-line-numbers-mode -1)))

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

  (setq neo-theme 'nerd-icons
        neo-vc-integration '(char face)
        neo-show-hidden-files t
        neo-window-width 32
        neo-window-fixed-size t)
  (defun emacs-neotree-show-current-project (&rest _)
    (interactive)
    (let* ((window (selected-window))
           (file (buffer-file-name))
           (project (project-current))
           (root (when project (project-root project))))
      (if root
          (progn
            (neotree-dir root)
            (when (and file (file-in-directory-p file root))
              (with-current-buffer neo-global--buffer
                (setq neo-buffer--expanded-node-list nil))
              (neotree-find file)))
        (neotree-show))
      (when (window-live-p window)
        (select-window window))))
  (unless (daemonp)
    (add-hook 'emacs-startup-hook #'emacs-neotree-show-current-project))
  (add-hook 'server-after-make-frame-hook #'emacs-neotree-show-current-project)
  (add-hook 'server-switch-hook #'emacs-neotree-show-current-project)
  (add-hook 'project-switch-project-hook #'emacs-neotree-show-current-project)
  (defvar emacs-neotree-followed-location nil)
  (defun emacs-neotree-follow-current-buffer (&optional frame)
    (let* ((window (if (framep frame) (frame-selected-window frame) (selected-window)))
           (buffer (window-buffer window))
           (file (buffer-file-name buffer)))
      (when (and file
                 (not (eq buffer neo-global--buffer))
                 (not (window-parameter window 'no-neotree-follow)))
        (with-current-buffer buffer
          (when-let* ((project (project-current nil))
                      (root (project-root project))
                      ((file-in-directory-p file root))
                      ((not (equal emacs-neotree-followed-location (cons root file)))))
            (setq emacs-neotree-followed-location (cons root file))
            (when (window-live-p neo-global--window)
              (with-selected-window neo-global--window
                (neotree-dir root)))
            (when (window-live-p neo-global--window)
              (with-current-buffer neo-global--buffer
                (setq neo-buffer--expanded-node-list nil))
              (neotree-find file))
            (when (window-live-p window)
              (select-window window)))))))
  (add-hook 'window-buffer-change-functions #'emacs-neotree-follow-current-buffer)
  (add-hook 'window-selection-change-functions #'emacs-neotree-follow-current-buffer)
  (defun emacs-neotree-refresh-after-save ()
    (when (and (fboundp 'neo-global--window-exists-p)
               (neo-global--window-exists-p))
      (with-selected-window neo-global--window
        (neotree-refresh))))
  (add-hook 'after-save-hook #'emacs-neotree-refresh-after-save)

  (require 'diff-hl)
  (global-diff-hl-mode 1)

''
