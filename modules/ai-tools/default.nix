{
  pkgs,
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
          omp
          #claude-code
          codex
          antigravity-cli
          #grok-cli
          #opencode
          amp
          herdr
        ]
      ))
      ++ (lib.optionals config.ai-tools.gui.enable (
        with pkgs;
        [
          chatgpt
          kiro
        ]
      ));
    extraFavoriteApps = lib.mkIf config.ai-tools.gui.enable [
      "chatgpt.desktop"
    ];
  };
}
