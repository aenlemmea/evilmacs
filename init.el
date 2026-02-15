;;; init.el --- Main Emacs configuration -*- lexical-binding: t; -*-

;; ===========================================
;; UI Display Settings
;; ===========================================
(add-hook 'window-setup-hook #'toggle-frame-maximized)
(setopt display-time-default-load-average nil)

(setq inhibit-startup-message t
      initial-scratch-message ""
      initial-buffer-choice nil
      display-line-numbers-type 'relative)

(blink-cursor-mode 0)                    ;; Disable blinking cursor
(global-display-line-numbers-mode 1)

(fringe-mode '(32 . 32))
(setq flymake-fringe-indicator-position nil)

(when (display-graphic-p)
  (context-menu-mode))                   ;; Right-click menu in GUI mode

;; ===========================================
;; Package Setup
;; ===========================================

(require 'package)

(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/") t)

;; Initialize package system (since you disabled it in early-init)
(package-initialize)

;; Bootstrap use-package if missing
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)


;; ===========================================
;; Tabs, Indents, and Offsets
;; ===========================================

;; (setq c-ts-mode-indent-style 'k&r)  ;; Set style to K&R instead of GNU (Treesitter)
;; (setq c-ts-mode-indent-offset 2)    ;; Set the indent offset. Default (2) (Treesitter)
(setq-default tab-width 4)

;; ===========================================
;; File & Backup Behavior
;; ===========================================

(setq make-backup-files nil)            ;; No backup files
(setq backup-inhibited t)               ;; Extra safeguard
(setq auto-save-default nil)            ;; No auto-save files
(setq auto-save-list-file-prefix nil)   ;; No auto-save list files
(setq auto-save-list-file-name nil)
(setq create-lockfiles nil)             ;; No lockfiles

(setq version-control nil)               ;; Don't keep numbered backups
(setq auto-save-interval 0)              ;; Disable autosave timer (keystroke count)
(setq auto-save-timeout 0)               ;; Disable autosave timer (idle time)
(setq tramp-backup-directory-alist nil)  ;; Disable backups on remote files

;; ===========================================
;; Session Management
;; ===========================================

(setq session-initialize nil)   ;; Disable session saving
(desktop-save-mode 0)          ;; Disable desktop save mode (session saving)

;; ===========================================
;; General Behavior
;; ===========================================

;; Prevent cc-mode from being loaded. Don't ask
;; (with-eval-after-load 'cc-mode
;;  (advice-add 'c-mode :override #'fundamental-mode)
;;  (advice-add 'c++-mode :override #'fundamental-mode))

(add-hook 'c-mode-common-hook (lambda () (abbrev-mode -1))) ;; Disable abbrev for CC-Mode

(when (fboundp 'windmove-default-keybindings)
  (windmove-default-keybindings))

(setopt sentence-end-double-space nil)
(setopt switch-to-buffer-obey-display-actions t)
(setopt mouse-wheel-tilt-scroll t)
(setopt mouse-wheel-flip-direction t)
(fido-vertical-mode 1)
(global-unset-key (kbd "C-M-i")) ;; Have to do this due to virtual machine!

;; ===========================================
;; Custom Save & Quit
;; ===========================================

(defun save-and-quit-safe ()
  "Save all modified buffers, then quit Emacs.
   Does not ask about saving, but still asks if active processes exist."
  (interactive)
  (save-some-buffers t)
  (save-buffers-kill-terminal))

(global-set-key (kbd "C-x C-c") 'save-and-quit-safe)

;; ===========================================
;; Text Mode
;; ===========================================

(add-hook 'text-mode-hook 'visual-line-mode)

;; ===========================================
;; Tree-sitter Mode Preferences
;; ===========================================

;; (setq major-mode-remap-alist
;;      '((c-mode      . c-ts-mode)
;;        (c++-mode    . c++-ts-mode)
;;        (go-mode     . go-ts-mode)))

;; ===========================================
;; Eglot & Company (LSP and Completion)
;; ===========================================

(use-package company
  :ensure t
  :config
  (global-company-mode 1)
  (setq company-idle-delay 0)
  (setq company-minimum-prefix-length 1)
  (setq company-backends '((company-capf company-dabbrev-code company-dabbrev)))
  (setq company-format-margin-function #'company-text-icons-margin))

(setq eglot-events-buffer-size 0)  ;; Disable events buffer
(setq eglot-sync-connect nil)      ;; Don't block Emacs waiting for server
(setq eglot-connect-timeout 10)    ;; Timeout after 10 seconds
 
(with-eval-after-load 'eglot
    (fset #'jsonrpc--log-event #'ignore))
 
(setq eglot-ignored-server-capabilities '(:documentOnTypeFormattingProvider))
(defun my-eglot-format-buffer-on-save ()
  "Format buffer with eglot if managed."
  (when (eglot-managed-p)
    (eglot-format-buffer)))

(add-hook 'c-mode-hook 'eglot-ensure)
(add-hook 'c++-mode-hook 'eglot-ensure)
(add-hook 'go-mode-hook 'eglot-ensure)

(add-hook 'c++-mode-hook 
          (lambda () 
            (add-hook 'before-save-hook #'my-eglot-format-buffer-on-save nil t)))
(add-hook 'c-mode-hook 
          (lambda () 
            (add-hook 'before-save-hook #'my-eglot-format-buffer-on-save nil t)))
(add-hook 'go-mode-hook 
          (lambda () 
            (add-hook 'before-save-hook #'my-eglot-format-buffer-on-save nil t)))

;; ;; Eglot for C++ and Go Treesitter

;; (add-hook 'c++-ts-mode-hook 
;;           (lambda () 
;;             (add-hook 'before-save-hook #'my-eglot-format-buffer-on-save nil t)))
;; (add-hook 'c-ts-mode-hook 
;;           (lambda () 
;;             (add-hook 'before-save-hook #'my-eglot-format-buffer-on-save nil t)))
;; (add-hook 'go-ts-mode-hook 
;;           (lambda () 
;;             (add-hook 'before-save-hook #'my-eglot-format-buffer-on-save nil t)))
;; 
;; (add-hook 'c++-ts-mode-hook 'eglot-ensure)
;; (add-hook 'c-ts-mode-hook 'eglot-ensure)
;; (add-hook 'go-ts-mode-hook 'eglot-ensure)

;; ===========================================
;; File Associations for Treesitter
;; ===========================================

;; ;; Go files
;; (add-to-list 'auto-mode-alist '("\\.go\\'" . go-ts-mode))
;; 
;; ;; C files
;; (add-to-list 'auto-mode-alist '("\\.c\\'" . c-ts-mode))
;; 
;; ;; C++ files
;; (add-to-list 'auto-mode-alist '("\\.h\\'" . c++-ts-mode)) ;; Could also be C
;; (dolist (pattern '("\\.cc\\'" "\\.cpp\\'" "\\.cxx\\'" "\\.hh\\'" "\\.hpp\\'" "\\.hxx\\'"))
;;   (add-to-list 'auto-mode-alist (cons pattern 'c++-ts-mode)))

;; ===========================================
;; Go Mode 
;; ===========================================

(use-package go-mode
  :ensure t
  :mode "\\.go\\'")

;; ===========================================
;; Dired Customizations
;; ===========================================

(setq dired-listing-switches "-alh")      ;; Human-readable sizes
(setq dired-dwim-target t) 
(setq dired-kill-when-opening-new-dired-buffer t)

;; ===========================================
;; Dired Clean Navigation Setup
;; ===========================================

;;; --- File Navigation Setup ---

(with-eval-after-load 'meow
  (define-key meow-normal-state-keymap (kbd "@") #'dired-jump)
  (define-key meow-normal-state-keymap (kbd "_") #'dired))

;; Create file or directory from Dired using +
(defun my-dired-create-file-or-dir (name)
  "Create a file or directory.
If NAME ends with '/', create a directory.
Otherwise create an empty file."
  (interactive "FCreate file or directory: ")
  (if (string-suffix-p "/" name)
      (progn
        (make-directory name t)
        (revert-buffer))
    (progn
      (write-region "" nil name)
      (revert-buffer))))

(with-eval-after-load 'dired
  (define-key dired-mode-map (kbd "+") 'my-dired-create-file-or-dir))

;; ===========================================
;; Meow Mode
;; ===========================================

(defun meow-setup ()
  (setq meow-cheatsheet-layout meow-cheatsheet-layout-qwerty)
  (meow-motion-define-key
   '("j" . meow-next)
   '("k" . meow-prev)
   '("<escape>" . ignore))
  (meow-leader-define-key
   ;; Use SPC (0-9) for digit arguments.
   '("1" . meow-digit-argument)
   '("2" . meow-digit-argument)
   '("3" . meow-digit-argument)
   '("4" . meow-digit-argument)
   '("5" . meow-digit-argument)
   '("6" . meow-digit-argument)
   '("7" . meow-digit-argument)
   '("8" . meow-digit-argument)
   '("9" . meow-digit-argument)
   '("0" . meow-digit-argument)
   '("/" . meow-keypad-describe-key)
   '("?" . meow-cheatsheet))
  (meow-normal-define-key
   '("0" . meow-expand-0)
   '("9" . meow-expand-9)
   '("8" . meow-expand-8)
   '("7" . meow-expand-7)
   '("6" . meow-expand-6)
   '("5" . meow-expand-5)
   '("4" . meow-expand-4)
   '("3" . meow-expand-3)
   '("2" . meow-expand-2)
   '("1" . meow-expand-1)
   '("-" . negative-argument)
   '(";" . meow-reverse)
   '("," . meow-inner-of-thing)
   '("." . meow-bounds-of-thing)
   '("[" . meow-beginning-of-thing)
   '("]" . meow-end-of-thing)
   '("a" . meow-append)
   '("A" . meow-open-below)
   '("b" . meow-back-word)
   '("B" . meow-back-symbol)
   '("c" . meow-change)
   '("d" . meow-delete)
   '("D" . meow-backward-delete)
   '("e" . meow-next-word)
   '("E" . meow-next-symbol)
   '("f" . meow-find)
   '("g" . meow-cancel-selection)
   '("G" . meow-grab)
   '("h" . meow-left)
   '("H" . meow-left-expand)
   '("i" . meow-insert)
   '("I" . meow-open-above)
   '("j" . meow-next)
   '("J" . meow-next-expand)
   '("k" . meow-prev)
   '("K" . meow-prev-expand)
   '("l" . meow-right)
   '("L" . meow-right-expand)
   '("m" . meow-join)
   '("n" . meow-search)
   '("o" . meow-block)
   '("O" . meow-to-block)
   '("p" . meow-yank)
   '("q" . meow-quit)
   '("Q" . meow-goto-line)
   '("r" . meow-replace)
   '("R" . meow-swap-grab)
   '("s" . meow-kill)
   '("t" . meow-till)
   '("u" . meow-undo)
   '("U" . meow-undo-in-selection)
   '("v" . meow-visit)
   '("w" . meow-mark-word)
   '("W" . meow-mark-symbol)
   '("x" . meow-line)
   '("X" . meow-goto-line)
   '("y" . meow-save)
   '("Y" . meow-sync-grab)
   '("z" . meow-pop-selection)
   '("'" . repeat)
   '("<escape>" . ignore)))

(use-package meow
  :custom
  (meow-use-clipboard t)
  :config
  (meow-setup)
  (meow-global-mode 1))
	
;; ===========================================
;; Custom Variables (Generated)
;; ===========================================

;; ===========================================
;; Custom Escape Panic Button
;; ===========================================

