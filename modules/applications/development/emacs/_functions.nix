''
  (defun macs-open-terminal ()
    (interactive)
    (term (getenv "SHELL")))

  (defun macs-hermes-dashboard-command (host port &optional _command)
    (list (or (executable-find "hermes") "hermes")
          "serve" "--isolated" "--host" host "--port" (number-to-string port)))
  (advice-add 'hermes-dashboard-transport--command
              :override #'macs-hermes-dashboard-command)
  (setq hermes-dashboard-transport-start-mode 'spawn
        hermes-dashboard-transport-url "http://127.0.0.1:9120")

  (defconst macs-hermes-side-window-action
    '((display-buffer-in-side-window)
      (side . right)
      (slot . 0)
      (window-width . 0.25)
      (preserve-size . (t . nil))))
  (defun macs-hermes-buffer-p (buffer)
    (and (buffer-live-p buffer)
         (string-prefix-p "*Hermes" (buffer-name buffer))))
  (defun macs-hermes-pop-to-buffer (original buffer &optional norecord)
    (if (macs-hermes-buffer-p (get-buffer buffer))
        (pop-to-buffer buffer macs-hermes-side-window-action norecord)
      (funcall original buffer norecord)))
  (advice-add 'pop-to-buffer-same-window :around #'macs-hermes-pop-to-buffer)
  (add-to-list 'display-buffer-alist
               (cons "\\`\\*Hermes" macs-hermes-side-window-action))
''