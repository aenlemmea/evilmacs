;;; early-init.el --- Emacs early init config -*- lexical-binding: t; -*-

;; ===========================================
;; GC and Warning Optimizations
;; ===========================================

(setq gc-cons-threshold 10000000)                          ;; Speed up startup
(setq byte-compile-warnings '(not obsolete))               ;; Suppress obsolete warnings
(setq warning-suppress-log-types '((comp) (bytecomp)))     ;; Suppress native/byte compile logs
(setq native-comp-async-report-warnings-errors 'silent)    ;; Quiet native compilation



;; Silence initial message in echo area
(setq inhibit-startup-echo-area-message (user-login-name))

;; ===========================================
;; Appearance Settings (GUI)
;; ===========================================

(when initial-window-system
  (setq frame-background-mode 'dark)
  (add-to-list 'default-frame-alist '(background-color . "black"))
  (add-to-list 'default-frame-alist '(foreground-color . "white")))

(menu-bar-mode -1)
(when (tool-bar-mode)    (tool-bar-mode -1))
(when (scroll-bar-mode)  (scroll-bar-mode -1))

;; ===========================================
;; Evil Setup (with bootstrap if missing)
;; ===========================================

(setq package-enable-at-startup nil)
(package-initialize) 
(require 'use-package)

(unless (package-installed-p 'evil)
  (package-refresh-contents)
  (package-install 'evil))

(use-package evil
  :demand t
  :bind (("<escape>" . keyboard-escape-quit))
  :init
  (setq evil-want-keybinding nil)
  (setq evil-want-integration t)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-Y-yank-to-eol t)          ;; Make Y behave like D and C
  (setq evil-want-fine-undo t)              ;; More granular undo in insert mode
  (setq evil-undo-system 'undo-redo)        ;; Use modern undo system
  (setq evil-split-window-below t)          ;; New splits go below
  (setq evil-vsplit-window-right t)         ;; New vsplits go right
  :config
  (evil-mode 1))


