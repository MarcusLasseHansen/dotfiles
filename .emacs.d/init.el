;; -*- lexical-binding: t; -*-
;; Suppress warnings about packages not using lexical-binding
(add-to-list 'warning-suppress-types '(lexical-binding))

(add-to-list 'default-frame-alist '(fullscreen . maximized))

(global-display-line-numbers-mode 1)

(dolist (hook '(image-mode-hook
                pdf-view-mode-hook
                doc-view-mode-hook
                eww-mode-hook
                term-mode-hook
                shell-mode-hook
                eshell-mode-hook))
  (add-hook hook
            (lambda ()
              (display-line-numbers-mode 0))))
(defun my-latex-wrap-setup ()
  (visual-line-mode 1)  ; wrap at window edge
  (setq-local word-wrap t)
  (setq-local truncate-lines nil))

(add-hook 'latex-mode-hook #'my-latex-wrap-setup)
(global-set-key (kbd "<f5>") 'compile)
(global-set-key (kbd "C-.") 'duplicate-line)

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
;; Comment/uncomment this line to enable MELPA Stable if desired.  See `package-archive-priorities`
;; and `package-pinned-packages`. Most users will not need or want to do this.
;;(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(package-initialize)

;; tramp stuff
(setq remote-file-name-inhibit-locks t
      tramp-use-scp-direct-remote-copying t
      remote-file-name-inhibit-auto-save-visited t)
(setq tramp-copy-size-limit (* 1024 1024) ;; 1MB
      tramp-verbose 2)
(connection-local-set-profile-variables
 'remote-direct-async-process
 '((tramp-direct-async-process . t)))
(connection-local-set-profiles
 '(:application tramp :protocol "scp")
 'remote-direct-async-process)
(setq magit-tramp-pipe-stty-settings 'pty)
(with-eval-after-load 'tramp
  (with-eval-after-load 'compile
    (remove-hook 'compilation-mode-hook #'tramp-compile-disable-ssh-controlmaster-options)))

(setq read-process-output-max (* 4 1024 1024)) ; 4MB
(setq set-mark-command-repeat-pop t)

;; avy stuffs
(global-unset-key (kbd "C-z"))
(global-unset-key (kbd "C-M-l"))
(global-unset-key (kbd "C-l"))
(global-unset-key (kbd "M-l"))
(global-set-key (kbd "C-l") #'avy-goto-char-timer)
(global-set-key (kbd "M-l") #'avy-goto-char)
(global-set-key (kbd "C-z") #'recenter-top-bottom)
(global-set-key (kbd "C-M-z") #'reposition-window)

;; multi cursor
(global-set-key (kbd "C-<") 'mc/mark-next-like-this)
(global-set-key (kbd "C->") 'mc/mark-previous-like-this)
(global-set-key (kbd "C-S-s") 'mc/mark-all-like-this)
(global-set-key (kbd "C-M-l") 'mc/edit-lines)

;; Make backups of files, even when they're in version control
(setq vc-make-backup-files t)

;; Save point position between sessions
(require 'saveplace)
(save-place-mode 1)
(setq save-place-file (expand-file-name ".places" user-emacs-directory))

;; Auto refresh buffers
(global-auto-revert-mode 1)

;; Also auto refresh dired, but be quiet about it
(setq global-auto-revert-non-file-buffers t)
(setq auto-revert-verbose nil)

(global-unset-key (kbd "C-o"))
(global-set-key (kbd "C-o") 'er/expand-region)
(global-set-key (kbd "M-o") 'other-window)

;; Add the theme directory to load-path
 (add-to-list 'custom-theme-load-path "~/.emacs.d/themes/")

(defun my/set-font ()
  ;; (set-face-attribute 'default nil :font "TempleOS 20"))
  (set-face-attribute 'default nil :font "Iosevka 20"))


(if (daemonp)
    (add-hook 'server-after-make-frame-hook #'my/set-font)
  (my/set-font))

;; Clangd things for C++ LSP to not be so invasive
;; Eglot configuration
(with-eval-after-load 'eglot
  ;; C/C++
  (add-to-list 'eglot-server-programs
               '((c-ts-mode c++-ts-mode c-mode c++-mode)
                 . ("clangd"
                    "-j=8"
                    "--log=error"
                    "--malloc-trim"
                    "--background-index"
                    "--clang-tidy"
                    "--completion-style=detailed"
                    "--pch-storage=memory"
                    "--header-insertion=never"
                    "--header-insertion-decorators=0"))))


(use-package multiple-cursors-core
  :bind    (:map mc/keymap
                 ("<return>" . nil)))

(add-hook 'prog-mode-hook #'hs-minor-mode)

(require 'python)
(require 'treesit nil t) ; Optional: loads tree-sitter if your Emacs build supports it

(add-to-list 'auto-mode-alist '("\\.h\\'" . c++-mode))

;; Show battery status in mode line

(with-eval-after-load 'emms
  (emms-all)
  (emms-default-players))

(menu-bar-mode -1)
(scroll-bar-mode -1)
(tool-bar-mode -1)

;; Enable vertigo mode
(vertico-mode 1)

;; PDF Tools setup (wrapped to prevent startup errors if not compiled)
(use-package pdf-tools
    :config
    (pdf-tools-install)
    (pdf-loader-install)
    (add-hook 'pdf-view-mode-hook #'auto-revert-mode));; Install and enable PDF Tools

;; Enable marginalia mode
(marginalia-mode 1)

;; Enable eglot (language server protocol client) but not on remote
(defun my-eglot-ensure-local ()
  (unless (or (file-remote-p default-directory)
              (derived-mode-p 'sh-mode))
    (eglot-ensure)))
(add-hook 'prog-mode-hook #'my-eglot-ensure-local)

;; Enable company mode globally
(add-hook 'after-init-hook 'global-company-mode)

;; Enable which-key mode
(which-key-mode 1)

(setq company-idle-delay nil)  ; disable automatic popup
(setq company-minimum-prefix-length 1)
(setq company-show-numbers t)
(global-set-key (kbd "C-<tab>") #'company-complete)

;; Emacs Multimedia System
(use-package emms
  :config
  (require 'emms-setup)
  (require 'emms-mpris)
  (emms-all)
  (emms-default-players)
  (emms-mpris-enable)
  :custom
  (emms-browser-covers #'emms-browser-cache-thumbnail-async)
  :bind
  (("C-c w m b" . emms-browser)
   ("C-c w m e" . emms)
   ("C-c w m p" . emms-play-playlist )
   ("<XF86AudioPrev>" . emms-previous)
   ("<XF86AudioNext>" . emms-next)
   ("<XF86AudioPlay>" . emms-pause)))

;; Customize company keybindings for manual selection and confirmation
(with-eval-after-load 'company
  (define-key company-active-map (kbd "RET") #'company-complete-selection)
  (define-key company-active-map (kbd "<return>") #'company-complete-selection)
  (define-key company-active-map (kbd "TAB") #'company-select-next)
  (define-key company-active-map (kbd "<tab>") #'company-select-next)
  (define-key company-active-map (kbd "S-TAB") #'company-select-previous)
  (define-key company-active-map (kbd "<backtab>") #'company-select-previous)
  (define-key company-active-map (kbd "<down>") #'company-select-next)
  (define-key company-active-map (kbd "<up>") #'company-select-previous)
  (define-key company-mode-map [remap c-indent-line-or-region] nil)
  (define-key company-mode-map [remap indent-for-tab-command] nil))

(require 'orderless)
(setq completion-styles '(orderless basic)
      orderless-style '(orderless-literal orderless-flex)
      completion-category-overrides '((file (styles basic partial-completion))))

;;paragraph movement
(global-set-key (kbd "M-n") #'forward-paragraph)
(global-set-key (kbd "M-p") #'backward-paragraph)

;;Indentation:
(setq-default indent-tabs-mode nil)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(avy-timeout-seconds 0.25)
 '(byte-compile-verbose nil)
 '(c-syntactic-indentation nil)
 '(compilation-auto-jump-to-first-error nil)
 '(custom-enabled-themes nil)
 '(custom-safe-themes
   '("4732feaaeab14f39b62cb922096749d0e9c5d561f6192e13dc2a3d8729d1fd4b"
     "ec717a4698b3fa398eb7f8214adba47d4f51bab42c3925ba0ffe3abc5f82712a"
     "c4df9006b9eb32599d758800a32f3487c2cdf13826084511783b47d419024af2"
     "5aedf993c7220cbbe66a410334239521d8ba91e1815f6ebde59cecc2355d7757"
     "f9575ecd8da2a02c114e427f2ebb49ffee94285c5963f33a0abf357c5a33a1d9"
     "8c237af2dcf284fbafd9d66c685785eeb00fafa1030a813885799ae13bdc56fc"
     "674f15e0383a621b31f47396c5aa90c227d21530d4fba091d88204c18b69b27c"
     "6781141be919cc1077b1f7f38dccbcfec775fb174c18ce0296f11d7881a62b7e"
     "b0a8537db8375187cf7d72044074b646c0e456a3c0fd3103db85455d94c3dce9"
     "88f7e2148bc46ca4b551e6e9b499540b8bc26b5884308ed85b98e16f7421f06f"
     "0206a1960f04896d7f5144e2e8ac0119bb63df78deec362337e7cc3003b946e9"
     "55d7acc3b01c43aa59067192ac68a60425e04b528798dcf90b75ab1eaa99755f"
     "979a7d9bdc9b392570fa986534612f7d473da3dfd5ccc148f4b287a07bb86d5c"
     "b8efc2889cf4d0bd8828fdd6620d583b71f45d768bea7b10f8c8f534bada0c05"
     "bcde92bbb2a49364639e4d76f5d2d8c39d114786cd554121c4d1413e39e70d51"
     "55132ce48859a0fd1016d744f163a6a2e23248fab16876cd0ca26d1f9cc15bc4"
     "62e8435cb64f355486739c15f7c19fcc4db9e6e45680e8eb3ec2a88c3a244207"
     "12888ff7a27cd483dfad5139a4056674385d7e86219d5c1381c2b40f4d57aac1"
     "436184bdc59691c2b07abd02114cc64ca1b6d5534801d74fa4e9c323a3b51d53"
     "1b2727001d06f63916118b811da49a9344582c16f9e2d7e26657634712886775"
     "03ffccc093c553a238a54fea13f2056749d83c24e65940f8d4bdb7135f1199a5"
     "f5ab1ad901eb430cdcd9b2a6824e94ff384172a9492ff7a88fe989ee2d583f09"
     "1185283fa4e0604861821c6b3539d39dd7544f0a28d7d3915539bfb2f8d1528a"
     "b1a691bb67bd8bd85b76998caf2386c9a7b2ac98a116534071364ed6489b695d"
     "04aa1c3ccaee1cc2b93b246c6fbcd597f7e6832a97aaeac7e5891e6863236f9f"
     "b11edd2e0f97a0a7d5e66a9b82091b44431401ac394478beb44389cf54e6db28"
     "6bdc4e5f585bb4a500ea38f563ecf126570b9ab3be0598bdf607034bb07a8875"
     "e900ae738225380abd1edc0c76535a12b8a6669c7a3180431ba0157a47bbf75e"
     "19a2c0b92a6aa1580f1be2deb7b8a8e3a4857b6c6ccf522d00547878837267e7"
     "3e374bb5eb46eb59dbd92578cae54b16de138bc2e8a31a2451bf6fdb0f3fd81b"
     "fa49766f2acb82e0097e7512ae4a1d6f4af4d6f4655a48170d0a00bcb7183970"
     "6d58e2b15bdf919fb3f975572af5de59556507b4addf71d8a0d4da3b5af1e830"
     "5acb2e842cccd8e19e3f263a7e27345b7c12024b80cfad00094c9da54cc0a0ed"
     "76829ecd2a3810c7a20b4163c8b3dbc8c4faf1674bb568e5150dd8d24fef25bf"
     "51caf9bf88aba940d98c96add138d83317d50eae4b8526612184e93473252d54"
     "6965a903ced31bd58caddb7e7035aadc47f8b0a5c57f246b698be2dfdfed2c4e"
     "0f738dce3f831b6d64ee3e98052bdea663b74d5149dcbbf555327dcb4517fc08"
     "fff0dc54ff5a194ba6593d1cce0fbb4fe8cf9da59fcef47f9e06dec6ef11b1fa"
     "2c7dc80264de0ba9409d4ebb3c7b31cf8e4982015066174c786f16a672db71b2"
     "6aff83667a3bad8db2f55d69cf595f58b56af233f116ec24d93fe2aa51033eef"
     "7e98dc1aa7f5db0557691da690c38d55e83ddd33c6d268205d66e430d57fb982"
     "6dcf1ca4c7432773084b9d52649ee5eb2c663131c4c06859f648dea98d9acb3e"
     "17570f818a8a3877994453342e3425a3b4fa4b3ebac050b4ecbbee958f1ca133"
     "3799f9b2e997c7cf7d1a5d9846095c8976bce96852eda40d8bf9248157c2615f"
     "fb232a8ae1311f1b8acecb1f766880d12d7a01b7d8d547e7c09325a074a31237"
     default))
 '(delete-selection-mode t)
 '(dired-free-space 'separate)
 '(dired-use-ls-dired t)
 '(ede-project-directories
   '("/home/marcus/uni/kemisk-projekt/midas/midascpp_branch_af_branch"
     "/home/marcus/uni/kemisk-projekt/midas/midascpp_mwp_tdadga"
     "/home/marcus/uni/kemisk-projekt/artikel"
     "/home/marcus/uni/kemisk-projekt/cpp_course/week_2/exercises/bits"))
 '(eglot-ignored-server-capabilities '(:documentOnTypeFormattingProvider))
 '(emms-mode-line-mode t)
 '(emms-mode-line-mode-line-function 'emms-mode-line-icon-function)
 '(enable-recursive-minibuffers t)
 '(fast-but-imprecise-scrolling 1)
 '(inhibit-startup-screen t)
 '(jit-lock-defer-time 0.0)
 '(line-spacing nil)
 '(menu-bar-mode nil)
 '(minibuffer-depth-indicate-mode t)
 '(mode-line-collapse-minor-modes t)
 '(mode-line-compact t)
 '(mode-line-format
   '("%e" mode-line-front-space mode-line-frame-identification
     mode-line-buffer-identification "   " mode-line-position
     (project-mode-line project-mode-line-format) (vc-mode vc-mode)
     "  " mode-line-modes mode-line-misc-info mode-line-end-spaces))
 '(package-selected-packages
   '(avy bln-mode catppuccin-theme color-theme-sanityinc-tomorrow company
         csv-mode diminish ef-themes eglot emms expand-region magit
         marginalia multiple-cursors orderless pdf-tools rainbow-mode
         standard-themes vertico vundo which-key))
 '(package-vc-selected-packages nil)
 '(pdf-view-selection-style 'glyph)
 '(pixel-scroll-mode nil)
 '(show-trailing-whitespace t)
 '(tool-bar-mode nil)
 '(truncate-lines t)
 '(underline-minimum-offset 0)
 '(use-short-answers t)
 '(word-wrap nil)
 '(x-underline-at-descent-line t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(hl-line ((t nil))))
(put 'upcase-region 'disabled nil)
