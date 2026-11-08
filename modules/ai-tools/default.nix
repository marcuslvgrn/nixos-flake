{
  pkgs,
  lib,
  config,
  ...
}:
{
  options = {
    ai-cli-tools.enable = lib.mkEnableOption "Enable agentic AI CLI tools";
    ai-gui-tools.enable = lib.mkEnableOption "Enable agentic AI GUI tools";
  };
  config = {
    environment.systemPackages =
      (lib.optionals config.ai-cli-tools.enable (
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
      ++ (lib.optionals config.ai-gui-tools.enable (
        with pkgs;
        [
          chatgpt
          kiro
        ]
      ));
  };
}
