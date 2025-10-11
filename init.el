;;; init.el --- Main Emacs configuration -*- lexical-binding: t; -*-

;; ===========================================
;; UI / Display Settings
;; ===========================================
(toggle-frame-maximized)

(setopt display-time-default-load-average nil)
(setq inhibit-startup-message t)         ;; Disable splash screen
(setq initial-scratch-message "")        ;; Disable scratch buffer message
(setq initial-buffer-choice nil)         ;; Don't open any buffer at startup
(setq display-line-numbers-type 'relative) ;; Relative line numbers

(blink-cursor-mode 0)                    ;; Disable blinking cursor
(global-display-line-numbers-mode 1)

(when (display-graphic-p)
  (context-menu-mode))                   ;; Right-click menu in GUI mode

;; ===========================================
;; Package Archives
;; ===========================================

(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

;; ===========================================
;; Tabs, Indents, and Offsets
;; ===========================================

(setq c-ts-mode-indent-style 'k&r)  ;; Set style to K&R instead of GNU
(setq c-ts-mode-indent-offset 2)    ;; Set the indent offset. Default (2)
(setq-default tab-width 4)

;; ===========================================
;; File & Backup Behavior
;; ===========================================

(setq make-backup-files nil)            ;; No backup files
(setq backup-inhibited t)               ;; Extra safeguard
(setq auto-save-default nil)            ;; No auto-save files
(setq auto-save-list-file-prefix nil)   ;; No auto-save list files
(setq create-lockfiles nil)             ;; No lockfiles

(setq version-control nil)               ;; Don't keep numbered backups
(setq auto-save-interval 0)              ;; Disable autosave timer (keystroke count)
(setq auto-save-timeout 0)               ;; Disable autosave timer (idle time)
(setq tramp-backup-directory-alist nil)  ;; Disable backups on remote files

;; ===========================================
;; Session Management
;; ===========================================

(setq session-initialize nil)   ;; Disable session saving
(desktop-save-mode -1)          ;; Disable desktop save mode (session saving)

;; ===========================================
;; General Behavior
;; ===========================================

(when (fboundp 'windmove-default-keybindings)
  (windmove-default-keybindings))

(setopt sentence-end-double-space nil)
(setopt switch-to-buffer-obey-display-actions t)
(setopt mouse-wheel-tilt-scroll t)
(setopt mouse-wheel-flip-direction t)

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

(setq major-mode-remap-alist
      '((c-mode      . c-ts-mode)
        (c++-mode    . c++-ts-mode)
        (go-mode     . go-ts-mode)))

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

(add-hook 'c++-ts-mode-hook 
          (lambda () 
            (add-hook 'before-save-hook #'my-eglot-format-buffer-on-save nil t)))
(add-hook 'c-ts-mode-hook 
          (lambda () 
            (add-hook 'before-save-hook #'my-eglot-format-buffer-on-save nil t)))
(add-hook 'go-ts-mode-hook 
          (lambda () 
            (add-hook 'before-save-hook #'my-eglot-format-buffer-on-save nil t)))

;; Eglot for C++ and Go
(add-hook 'c++-ts-mode-hook 'eglot-ensure)
(add-hook 'c-ts-mode-hook 'eglot-ensure)
(add-hook 'go-ts-mode-hook 'eglot-ensure)

;; ===========================================
;; File Associations
;; ===========================================

;; Go files
(add-to-list 'auto-mode-alist '("\\.go\\'" . go-ts-mode))

;; C files
(add-to-list 'auto-mode-alist '("\\.c\\'" . c-ts-mode))

;; C++ files
(add-to-list 'auto-mode-alist '("\\.h\\'" . c++-ts-mode)) ;; Could also be C
(dolist (pattern '("\\.cc\\'" "\\.cpp\\'" "\\.cxx\\'" "\\.hh\\'" "\\.hpp\\'" "\\.hxx\\'"))
  (add-to-list 'auto-mode-alist (cons pattern 'c++-ts-mode)))

;; ===========================================
;; Evil Extras
;; ===========================================

(use-package evil-collection
  :after evil
  :ensure t
  :custom (evil-collection-setup-minibuffer t)
  :config
  (evil-collection-init))

;; ===========================================
;; Dired Customizations
;; ===========================================

(setq dired-listing-switches "-alh")      ;; Human-readable sizes
(setq dired-dwim-target t) 
(setq dired-kill-when-opening-new-dired-buffer t)

(with-eval-after-load 'dired
  (evil-define-key 'normal dired-mode-map
    (kbd "*") 'dired-create-empty-file))

(define-key evil-normal-state-map (kbd "-") #'dired-jump)  ;; Dired for current
(define-key evil-normal-state-map (kbd "_") #'dired)       ;; Prompt for dir
  
;; ===========================================
;; Remaps
;; ===========================================

(evil-ex-define-cmd "q"  'save-and-quit-safe)
(evil-ex-define-cmd "q!" 'save-and-quit-safe)
(evil-set-leader 'normal (kbd "SPC"))

(evil-define-key 'normal 'global (kbd "<leader>q") 'quit-window)

(evil-define-key 'normal 'global (kbd "<leader>k") 'kill-current-buffer)
(evil-define-key 'normal 'global (kbd "<leader>b") 'ibuffer)
(evil-define-key 'normal 'global (kbd "<leader>p") 'previous-buffer)
(evil-define-key 'normal 'global (kbd "<leader>n") 'next-buffer)
(evil-define-key 'normal 'global (kbd "<leader>f") 'switch-to-buffer)

;; Navigation
(evil-define-key 'normal 'global (kbd "<leader>wh") 'evil-window-left)
(evil-define-key 'normal 'global (kbd "<leader>wj") 'evil-window-down)
(evil-define-key 'normal 'global (kbd "<leader>wk") 'evil-window-up)
(evil-define-key 'normal 'global (kbd "<leader>wl") 'evil-window-right)
(evil-define-key 'normal 'global (kbd "<leader>ww") 'evil-window-next)

;; Movement/Swapping (Emacs 27+)
(evil-define-key 'normal 'global (kbd "<leader>wH") 'windmove-swap-states-left)
(evil-define-key 'normal 'global (kbd "<leader>wJ") 'windmove-swap-states-down)
(evil-define-key 'normal 'global (kbd "<leader>wK") 'windmove-swap-states-up)
(evil-define-key 'normal 'global (kbd "<leader>wL") 'windmove-swap-states-right)

;; Resizing
(evil-define-key 'normal 'global (kbd "<leader>w<") 'evil-window-decrease-width)
(evil-define-key 'normal 'global (kbd "<leader>w>") 'evil-window-increase-width)
(evil-define-key 'normal 'global (kbd "<leader>w-") 'evil-window-decrease-height)
(evil-define-key 'normal 'global (kbd "<leader>w+") 'evil-window-increase-height)
(evil-define-key 'normal 'global (kbd "<leader>w=") 'balance-windows)

;; Splits
(evil-define-key 'normal 'global (kbd "<leader>ws") 'evil-window-split)
(evil-define-key 'normal 'global (kbd "<leader>wv") 'evil-window-vsplit)

;; Close
(evil-define-key 'normal 'global (kbd "<leader>wq") 'evil-window-delete)
(evil-define-key 'normal 'global (kbd "<leader>wo") 'delete-other-windows)

;; ===========================================
;; Custom Variables (Generated)
;; ===========================================

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages '(company evil-collection)))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
