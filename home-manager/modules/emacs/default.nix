{
  config,
  lib,
  ...
}:
{
  programs.emacs = lib.mkIf config.programs.emacs.enable {

    extraPackages = epkgs: [
      epkgs.nix-mode
    ];

    extraConfig = ''
      ;; disable startup screen
      (setq inhibit-startup-screen t)

      ;; overwrite selected text
      (delete-selection-mode t)

      ;; mac modifiers (safe even on non-mac)
      (setq mac-option-modifier 'meta)
      (setq mac-right-option-modifier 'meta)

      ;; keybindings
      (global-set-key (kbd "<C-left>")  #'backward-word)
      (global-set-key (kbd "<C-right>") #'forward-word)

      ;; font
      (set-face-attribute 'default nil
        :family "DejaVu Sans Mono"
        :height 181)
    '';
  };
}
