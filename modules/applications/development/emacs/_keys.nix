''
  (define-key term-raw-escape-map (kbd "j") #'term-line-mode)
  (define-key term-raw-escape-map (kbd "k") #'term-char-mode)
  (define-key term-raw-escape-map (kbd "o") #'other-window)
  (define-key term-raw-escape-map (kbd "b") #'switch-to-buffer)

  (global-set-key (kbd "C-x k") #'kill-buffer-and-window)
  (global-set-key (kbd "C-c ]") #'tab-line-switch-to-next-tab)
  (global-set-key (kbd "C-c [") #'tab-line-switch-to-prev-tab)
  (global-set-key (kbd "C-c t") #'treemacs)
  (global-set-key (kbd "C-c e") #'macs-open-terminal)
  (global-set-key (kbd "C-c h") #'hermes-project-chat)
  (global-set-key (kbd "C-c b") #'fzf-switch-buffer)
  (global-set-key (kbd "C-c f") #'macs-fzf-find-file)
  (global-set-key (kbd "C-c r") #'fzf-grep)
  (global-set-key (kbd "C-c l") #'fzf-find-in-buffer)
  (global-set-key (kbd "C-c p") project-prefix-map)
  (global-set-key (kbd "C-c g") #'magit-status)
''