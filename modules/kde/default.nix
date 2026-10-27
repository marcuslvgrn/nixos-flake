{
  config,
  lib,
  pkgs-stable,
  pkgs-unstable,
  hostSettings,
  ...
}:
let
  cfg = config.kde;
  packageChannel = import ../../lib/packageChannel.nix {
    inherit
      lib
      pkgs-stable
      pkgs-unstable
      hostSettings
      ;
  };
  packageSet = packageChannel.forChannel cfg.packageChannel;
in
{
  # Selects the channel for KDE and related packages as a group.
  options.kde.packageChannel = lib.mkOption {
    type = packageChannel.type;
    default = "default";
    description = "Nixpkgs channel to use for KDE and related packages.";
  };

  config = lib.mkIf config.services.desktopManager.plasma6.enable {

    services = {
      xserver.enable = true;
      displayManager.gdm.enable = true;
    };

    programs.ssh.askPassword = lib.mkForce "${packageSet.seahorse}/libexec/seahorse/ssh-askpass";

    environment.systemPackages = (
      with packageSet;
      [
        # KDE
        kdePackages.discover # Optional: Install if you use Flatpak or fwupd firmware update sevice
        kdePackages.kcalc # Calculator
        kdePackages.kcharselect # Tool to select and copy special characters from all installed fonts
        kdePackages.kclock # Clock app
        kdePackages.kcolorchooser # A small utility to select a color
        kdePackages.kolourpaint # Easy-to-use paint program
        kdePackages.ksystemlog # KDE SystemLog Application
        kdePackages.sddm-kcm # Configuration module for SDDM
        kdiff3 # Compares and merges 2 or 3 files or directories
        kdePackages.isoimagewriter # Optional: Program to write hybrid ISO files onto USB disks
        kdePackages.partitionmanager # Optional: Manage the disk devices, partitions and file systems on your computer
        # Non-KDE graphical packages
        hardinfo2 # System information and benchmarks for Linux systems
        vlc # Cross-platform media player and streaming server
        wayland-utils # Wayland utilities
        wl-clipboard # Command-line copy/paste utilities for Wayland
      ]
    );
  };
}
