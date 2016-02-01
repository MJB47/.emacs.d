;;;;
;; Packages
;;;;

;; Define package repositories
(require 'package)
(add-to-list 'package-archives
             '("marmalade" . "http://marmalade-repo.org/packages/") t)
(add-to-list 'package-archives
             '("tromey" . "http://tromey.com/elpa/") t)
(add-to-list 'package-archives
             '("melpa" . "http://melpa.milkbox.net/packages/") t)

;; (setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
;;                          ("marmalade" . "http://marmalade-repo.org/packages/")
;;                          ("melpa" . "http://melpa-stable.milkbox.net/packages/")))


;; Load and activate emacs packages. Do this first so that the
;; packages are loaded before you start trying to modify them.
;; This also sets the load path.
(package-initialize)

;; Download the ELPA archive description if needed.
;; This informs Emacs about the latest versions of all packages, and
;; makes them available for download.
(when (not package-archive-contents)
  (package-refresh-contents))

;; The packages you want installed. You can also install these
;; manually with M-x package-install
;; Add in your own as you wish:
(defvar my-packages
  '(;; makes handling lisp expressions much, much easier
    ;; Cheatsheet: http://www.emacswiki.org/emacs/PareditCheatsheet
    paredit

    ;; key bindings and code colorization for Clojure
    ;; https://github.com/clojure-emacs/clojure-mode
    clojure-mode

    ;; extra syntax highlighting for clojure
    clojure-mode-extra-font-locking

    ;; integration with a Clojure REPL
    ;; https://github.com/clojure-emacs/cider
    cider

    ;; allow ido usage in as many contexts as possible. see
    ;; customizations/navigation.el line 23 for a description
    ;; of ido
    ido-ubiquitous

    ;; Enhances M-x to allow easier execution of commands. Provides
    ;; a filterable list of possible commands in the minibuffer
    ;; http://www.emacswiki.org/emacs/Smex
    smex

    ;; project navigation
    projectile

    ;; colorful parenthesis matching
    rainbow-delimiters

    ;; edit html tags like sexps
    tagedit

    ;; git integration
    magit

    yasnippet
    auto-complete
    smartparens
    visual-regexp
    browse-kill-ring
    expand-region
    undo-tree
    iedit
    ag
    golden-ratio
    ace-jump-mode
    monokai-theme
    drag-stuff
    neotree
    git-gutter
    highlight-symbol))

;; On OS X, an Emacs instance started from the graphical user
;; interface will have a different environment than a shell in a
;; terminal window, because OS X does not run a shell during the
;; login. Obviously this will lead to unexpected results when
;; calling external utilities like make from Emacs.
;; This library works around this problem by copying important
;; environment variables from the user's shell.
;; https://github.com/purcell/exec-path-from-shell
(if (eq system-type 'darwin)
    (add-to-list 'my-packages 'exec-path-from-shell))

(dolist (p my-packages)
  (when (not (package-installed-p p))
    (package-install p)))


;; Place downloaded elisp files in ~/.emacs.d/vendor. You'll then be able
;; to load them.
;;
;; For example, if you download yaml-mode.el to ~/.emacs.d/vendor,
;; then you can add the following code to this file:
;;
;; (require 'yaml-mode)
;; (add-to-list 'auto-mode-alist '("\\.yml$" . yaml-mode))
;;
;; Adding this code will make Emacs enter yaml mode whenever you open
;; a .yml file
(add-to-list 'load-path "~/.emacs.d/vendor")


;;;;
;; Customization
;;;;

;; Add a directory to our load path so that when you `load` things
;; below, Emacs knows where to look for the corresponding file.
(add-to-list 'load-path "~/.emacs.d/customizations")

;; Sets up exec-path-from-shell so that Emacs will use the correct
;; environment variables
(load "shell-integration.el")

;; These customizations make it easier for you to navigate files,
;; switch buffers, and choose options from the minibuffer.
(load "navigation.el")

;; These customizations change the way emacs looks and disable/enable
;; some user interface elements
(load "ui.el")

;; These customizations make editing a bit nicer.
(load "editing.el")

;; Hard-to-categorize customizations
(load "misc.el")

;; For editing lisps
(load "elisp-editing.el")

;; Langauage-specific
(load "setup-clojure.el")
(load "setup-js.el")

(defun kill-other-buffers ()
  "Kill all buffers not currently shown in a window somewhere."
  (interactive)
  (dolist (buf  (buffer-list))
    (unless (get-buffer-window buf 'visible) (kill-buffer buf))))

;;; yasnippet
;;; should be loaded before auto complete so that they can work together
(require 'yasnippet)
(yas-global-mode 1)

;;; auto complete mod
;;; should be loaded after yasnippet so that they can work together
(require 'auto-complete-config)
(add-to-list 'ac-dictionary-directories "~/.emacs.d/ac-dict")
(ac-config-default)
;;; set the trigger key so that it can work together with yasnippet on tab key,
;;; if the word exists in yasnippet, pressing tab will cause yasnippet to
;;; activate, otherwise, auto-complete will
(ac-set-trigger-key "TAB")
(ac-set-trigger-key "<tab>")

(add-hook 'clojure-mode-hook #'smartparens-mode)
(add-hook 'clojure-mode-hook #'highlight-symbol-mode)
(require 'visual-regexp)
(define-key global-map (kbd "C-c r") 'vr/replace)
(define-key global-map (kbd "C-c q") 'vr/query-replace)
;; if you use multiple-cursors, this is for you:
(define-key global-map (kbd "C-c m") 'vr/mc-mark)

(browse-kill-ring-default-keybindings)

(require 'expand-region)
(global-set-key (kbd "C-=") 'er/expand-region)

(global-undo-tree-mode)

(require 'golden-ratio)
(golden-ratio-mode 1)

(add-hook 'js-mode-hook #'electric-pair-mode)

(drag-stuff-mode t)

(defun revert-all-buffers ()
  "Refreshes all open buffers from their respective files."
  (interactive)
  (dolist (buf (buffer-list))
    (with-current-buffer buf
      (when (and (buffer-file-name) (file-exists-p (buffer-file-name)) (not (buffer-modified-p)))
        (revert-buffer t t t) )))
  (message "Refreshed open files."))

(defun delete-region-or-back-char ()
  (interactive)
  (if (region-active-p)
      (delete-region (region-beginning) (region-end))
    (delete-backward-char 1)))

(defun select-word-or-mark-next-like-this ()
  (interactive)
  (if (region-active-p)
      (mc/mark-next-like-this 1)
    (er/expand-region 1)))

(defun sane-commenting ()
  (interactive)
  (if (region-active-p)
      (comment-dwim 1)
    (toggle-comment-on-line)))

(global-set-key (kbd "<s-left>") 'back-to-indentation)
(global-set-key (kbd "<s-right>") 'move-end-of-line)
(global-set-key (kbd "<s-up>") 'backward-paragraph)
(global-set-key (kbd "<s-down>") 'forward-paragraph)
(global-set-key (kbd "s-l") 'mc/edit-lines)
(global-set-key (kbd "s-d") 'select-word-or-mark-next-like-this)
(global-set-key (kbd "s-D") 'mc/mark-all-like-this)
(global-set-key (kbd "s-y") 'undo-tree-redo)
(global-set-key (kbd "C-c SPC") 'ace-jump-mode)
(global-set-key (kbd "C-<") 'previous-buffer)
(global-set-key (kbd "C->") 'next-buffer)
(global-set-key (kbd "<s-M-up>") 'drag-stuff-up)
(global-set-key (kbd "<s-M-down>") 'drag-stuff-down)
(global-set-key (kbd "<s-M-left>") 'drag-stuff-left)
(global-set-key (kbd "<s-M-right>") 'drag-right-stuff)
(global-set-key (kbd "<S-tab>") 'indent-region)
(global-set-key (kbd "<backspace>") 'delete-region-or-back-char)
(global-set-key (kbd "s-<mouse-1>") 'mc/add-cursor-on-click)
(global-set-key (kbd "M-3") '(lambda () (interactive) (insert "#")))
(global-set-key (kbd "RET") 'newline-and-indent)
(global-set-key (kbd "s-/") 'sane-commenting)

;; Make it look like sublime
(set-face-attribute 'default t :font  "Menlo Regular")
(set-face-attribute 'default nil :height 130)
(load-theme 'monokai t)

(delete-selection-mode 1)

;; fix scrolling
(setq redisplay-dont-pause t
  scroll-margin 1
  scroll-step 1
  scroll-conservatively 10000
  scroll-preserve-screen-position 1)

(global-set-key [f8] 'neotree-toggle)
(setq projectile-switch-project-action 'neotree-projectile-action)

(tool-bar-mode -1)

(global-git-gutter-mode +1)
(highlight-symbol-mode 1)
(add-hook 'before-save-hook 'whitespace-cleanup)
(toggle-word-wrap)

(custom-set-faces
 (set-face-attribute 'neo-button-face      nil :height 90)
 (set-face-attribute 'neo-file-link-face   nil :height 90)
 (set-face-attribute 'neo-dir-link-face    nil :height 90)
 (set-face-attribute 'neo-header-face      nil :height 90)
 (set-face-attribute 'neo-expand-btn-face  nil :height 90)
 )

(setq-default cursor-type 'bar)

(dtrt-indent-mode 1)
