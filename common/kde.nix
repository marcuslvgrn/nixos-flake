{ config, lib, pkgs, pkgs-stable, pkgs-unstable, ... }:
let cfg = config.flakecfg.desktop.desktopManagers.kde;
in with lib; {
  config = mkIf cfg.enable {
    flakecfg.desktop.enable = true;
    imports = [
      #Common desktop manager settings
      ./desktopManager.nix
    ];

    services = {
      desktopManager.plasma6.enable = true;
      #   displayManager.sddm.enable = true;
      #   displayManager.sddm.wayland.enable = true;
    };

    programs.ssh.askPassword =
      lib.mkForce "${pkgs.seahorse}/libexec/seahorse/ssh-askpass";

    environment.systemPackages = (with pkgs; [
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
    ]) ++ (with pkgs-stable;
      [

      ]) ++ (with pkgs-unstable;
        [

        ]);
  };
}
