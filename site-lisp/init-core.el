;; Generic configuration.
(use-package emacs
  :init
  (defun my-backward-kill-word-or-region (&optional arg)
	"If mark is active acts as `C-w' otherwise as `backward-kill-word'."
	(interactive "p")
	(if mark-active
		(kill-region (mark) (point))
      (backward-kill-word arg)))

  (defun my-smart-tab (&optional arg)
    (interactive "p")
    (call-interactively
     (cond ((<= (current-column) (current-indentation))
            #'indent-for-tab-command)
		   ((and (fboundp 'tempel-expand)
				 (tempel--prefix-bounds))
            #'tempel-expand)
           (t #'indent-for-tab-command))))
  (call-interactively #'my-smart-tab)

  :hook
  ((prog-mode org-mode markdown-mode yaml-mode) . (lambda ()
													(setq-local show-trailing-whitespace t)))
  :custom
  (tab-width 4)  ; number spaces per a tab
  (ring-bell-function 'ignore) ; stop ring bell alarms
  (fill-column 80) ; 80 characters per a line
  (comment-fill-column 80)
  (set-mark-command-repeat-pop t) ; don't repeat C-u prefix on mark commands (i.e. C-u C-SPC)
  (warning-minimum-level :error) ; don't show warnings
  (truncate-lines t)

  :config
  (fset 'yes-or-no-p 'y-or-n-p) ; type y/n instead of yes/no
  (put 'upcase-region 'disabled nil) ; don't confirm on upcase command
  (put 'downcase-region 'disabled nil) ; don't confirm on downcase command
  (column-number-mode) ; show column number on modeline

  :bind
  ("C-w" . my-backward-kill-word-or-region)
  ("TAB" . my-smart-tab)
  ([remap kill-buffer] . kill-this-buffer)
  )

;; Line-numbers on the fringe side.
(use-package display-line-numbers
  :hook ((prog-mode conf-mode yaml-mode markdown-mode org-mode) . display-line-numbers-mode)
  :custom
  (display-line-numbers-type t))

;; Disable tool bar.
(use-package tool-bar
  :config
  (tool-bar-mode -1))

;; Enable menu-bar on MACOS graphic only.
(use-package menu-bar
  :unless (and (eq system-type 'darwin) (display-graphic-p))
  :config
  (menu-bar-mode -1))

;; Disable scroll bar.
(use-package scroll-bar
  :config
  (scroll-bar-mode -1))

;; Stop the cursor blinking.
(use-package frame
  :custom
  (visible-cursor nil) ; for terminal
  :config
  (blink-cursor-mode -1) ; for gui
  )

;; Use command as meta and use ctrl as alt on MACOS.
(use-package ns-win
  :if (eq system-type 'darwin)
  :custom
  (mac-command-modifier 'meta)
  (mac-option-modifier 'control))

(use-package bookmark
  :custom
  (bookmark-default-file (expand-file-name "bookmarks" my-emacs-config-directory)))

;; Command hints.
(use-package which-key :straight t
  :config
  (which-key-mode 1))

;; Do not store backup files.
(use-package files
  :custom
  (make-backup-files nil))

;; Override selection on yank.
(use-package delsel
  :config (delete-selection-mode))

;; Highlight TODO,BUG,FIXME,NOTE,etc. comment keywords.
(use-package hl-todo :straight t
  :config (global-hl-todo-mode))

;; Store and restore last edit position of a file.
(use-package saveplace
  :config
  (save-place-mode 1))

;; Store recent edit file names.
(use-package recentf
  :bind
  ("C-c br" . consult-recent-file)
  :config
  (recentf-mode 1))

;; Keep yank history after exiting Emacs.
(use-package undohist :straight t
  :custom
  (undohist-ignored-files '("COMMIT_EDITMSG") ; disable warning on temp files
  :config
  (undohist-initialize)))

;; Check spelling using `hunspell'.
(use-package flyspell
  :init
  (defun my-flyspell-toggle ()
    (interactive)
    (if (symbol-value flyspell-mode)
		(progn
		  (message "Flyspell off")
		  (flyspell-mode -1))
	  (progn
		(message "Flyspell on")
		(if (derived-mode-p 'prog-mode)
			(flyspell-prog-mode)
		  (flyspell-mode))
		(flyspell-buffer))))

  :hook
  (git-commit-setup . flyspell-mode) ; check COMMIT_EDITMSG buffer for spelling

  :bind
  ("C-c ts" . my-flyspell-toggle))

;; Echo area documentation hints.
(use-package eldoc
  :custom
  (eldoc-echo-area-use-multiline-p nil) ; do not enlarge echo area.
  )

;; Compile/recompile using Makefile mostly.
(use-package complile
  :bind
  ("C-c cr" . recompile))

;; Open URL at point in the browser. The `C-c C-o' shortcut is compatible with
;; `markdown-mode' and `org-mode'.
(use-package browse-url
  :bind
  ("C-c C-o" . browse-url-at-point))

;; Copy to clipboard on terminal.
(use-package xclip :straight t
  :unless (display-graphic-p)
  :config
  (xclip-mode 1))

;; Tmux integration.
(use-package ttymux
  :straight '(ttymux
              :type git
              :host github
              :repo "illia-danko/ttymux.el")
  :unless (display-graphic-p)
  :config
  (ttymux-mode 1))

(provide 'init-core)
