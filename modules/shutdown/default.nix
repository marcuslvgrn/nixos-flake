{
  config,
  lib,
  pkgs,
  ...
}:

{
  environment.systemPackages = lib.mkIf config.shutdownApp.enable [
    (pkgs.writeTextFile {
      name = "shutdown-launcher";
      destination = "/share/applications/shutdown-computer.desktop";
      text = ''
        [Desktop Entry]
        Type=Application
        Name=Shut Down Computer
        Comment=Shut down this computer
        Exec=${pkgs.systemd}/bin/systemctl poweroff
        Icon=system-shutdown
        Terminal=false
        Categories=System;
      '';
    })
  ];
}
