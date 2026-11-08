{
  pkgs,
  pkgs-unstable,
  lib,
  config,
  ...
}:
{
  options = {
    ai-tools.cli.enable = lib.mkEnableOption "Enable agentic AI CLI tools";
    ai-tools.gui.enable = lib.mkEnableOption "Enable agentic AI GUI tools";
  };
  config = {
    environment.systemPackages =
      (lib.optionals config.ai-tools.cli.enable (
        with pkgs;
        [
          # AI CLI tools
          kiro-cli
          #chatgpt-cli
          pi-coding-agent
          #claude-code
          codex
          #grok-cli
          amp
        ]
      ))
      ++ (lib.optionals config.ai-tools.cli.enable (
        with pkgs-unstable;
        [
          omp
          antigravity-cli
          herdr
          opencode
        ]
      ))
      ++ (lib.optionals config.ai-tools.gui.enable (
        with pkgs;
        [
          kiro
        ]
      ))
      # chatgpt only available in unstable
      ++ (lib.optionals config.ai-tools.gui.enable (
        with pkgs-unstable;
        [
          chatgpt
        ]

      ));

    extraFavoriteApps = lib.mkIf config.ai-tools.gui.enable [
      "chatgpt.desktop"
    ];
  };
}
