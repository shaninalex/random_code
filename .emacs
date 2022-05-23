;; Initialize melpa packages
(require 'package)
(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(package-initialize)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages '(go-mode yaml-mode projectile gruvbox-theme)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
)

;; (require 'yaml-mode)
;; (add-to-list 'auto-mode-alist '("\\.yml\\'" . yaml-mode))

;; Theme
(load-theme 'gruvbox t)

;; C++ styles
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
(setq indent-line-function 'insert-tab)

(c-add-style "cpp-styles"
          '("stroustrup"
            (c-offsets-alist
             (innamespace . -)
             (inline-open . 0)
             (inher-cont . c-lineup-multi-inher)
             (arglist-cont-nonempty . +)
             (template-args-cont . +))))

(setq c-default-style "cpp-styles")

;; Global system setup
(setq make-backup-files nil) ;; Stop making backup files ~
(setq create-lockfiles nil)  ;; Stop creating lock files '#filename#'

;; Show line numbers
(global-linum-mode t)
(setq linum-format "%d ")
