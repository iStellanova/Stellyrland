''
  (defun macs-open-terminal ()
    (interactive)
    (term (getenv "SHELL")))

  (setq hermes-dashboard-transport-url "http://127.0.0.1:9120")

  (defun macs-hermes-buffer-p (buffer)
    (and (buffer-live-p buffer)
         (string-prefix-p "*Hermes" (buffer-name buffer))))
  (defun macs-hermes-pop-to-buffer (original buffer &optional norecord)
    (if (macs-hermes-buffer-p (get-buffer buffer))
        (pop-to-buffer buffer nil norecord)
      (funcall original buffer norecord)))
  (advice-add 'pop-to-buffer-same-window :around #'macs-hermes-pop-to-buffer)
  (add-to-list 'display-buffer-alist
               '("\\`\\*Hermes"
                 (display-buffer-in-side-window)
                 (side . right)
                 (window-width . 0.25)))
''