;;; early-init.el --- Early Init -*- lexical-binding: t; -*-

;; ===========================================
;; Speed Up Startup
;; ===========================================

(setq site-run-file nil)

;; Increase GC threshold during startup
(setq gc-cons-threshold (* 50 1000 1000))
(setq gc-cons-percentage 0.6)

;; Disable package auto-initialization
(setq package-enable-at-startup nil)

;; Suppress compilation noise
(setq byte-compile-warnings '(not obsolete))
(setq warning-suppress-log-types '((comp) (bytecomp)))
(setq native-comp-async-report-warnings-errors 'silent)

;; Silence echo area message
(setq inhibit-startup-echo-area-message user-login-name)

;; ===========================================
;; UI Tweaks (before frame creation)
;; ===========================================

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

(setq frame-inhibit-implied-resize t)

;; Default dark frame
(add-to-list 'default-frame-alist '(background-color . "black"))
(add-to-list 'default-frame-alist '(foreground-color . "white"))
(setq frame-background-mode 'dark)
