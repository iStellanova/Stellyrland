''
  (defun macs-agent-shell-dot-subdir (subdir)
    (expand-file-name subdir (locate-user-emacs-file
                              (concat "agent-shell/"
                                      (replace-regexp-in-string
                                       "/" "-" (directory-file-name (agent-shell-cwd)))))))
  (setq agent-shell-dot-subdir-function #'macs-agent-shell-dot-subdir
        agent-shell-inhibit-system-sleep nil
        agent-shell-display-action
        '((display-buffer-in-side-window)
          (side . right)
          (window-width . 0.25)))
''
