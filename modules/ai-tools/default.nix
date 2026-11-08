{
  pkgs,
  lib,
  config,
  ...
}:
{
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
}
