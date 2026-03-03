;;; init.el --- Main Emacs configuration -*- lexical-binding: t; -*-

;; ===========================================
;; Package Management
;; ===========================================

(require 'package)
(package-initialize) 

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
(global-unset-key (kbd "C-M-x"))
(setq debug-on-error nil)
(global-set-key (kbd "C-r") #'undo)
(global-set-key (kbd "C-/") #'isearch-backward)
(setq echo-keystrokes 0.1)

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

(add-hook 'c++-mode-hook
          (lambda ()
            (setq-local font-lock-maximum-decoration 1)
            (setq-local show-trailing-whitespace nil)))

(when (fboundp 'windmove-default-keybindings)
  (windmove-default-keybindings))

(setopt sentence-end-double-space nil)
(setopt switch-to-buffer-obey-display-actions t)
(setopt mouse-wheel-tilt-scroll t)
(setopt mouse-wheel-flip-direction t)
(setq select-enable-clipboard t)
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
(setq initial-major-mode 'text-mode)

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

(defun eldoc-in-completions ()
  (add-hook
   'eldoc-documentation-functions
   (lambda (cb)
     (let* ((documentation (plist-get
                            (get-text-property (point) 'eglot--lsp-item)
                            :documentation))
            (formatted (and documentation
                            (eglot--format-markup documentation))))
       (when formatted (funcall cb formatted :echo 'skip))))
   nil t)
  (eldoc-mode t))

(add-hook 'completion-list-mode-hook #'eldoc-in-completions)
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
;; Custom Variables
;; ===========================================

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
