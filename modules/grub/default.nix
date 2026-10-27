{
  ...
}:
{
  boot.loader = {
    timeout = 1;
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/efi";
    };
    grub = {
      # Use the GRUB boot loader
      enable = true;
      device = "nodev";
      useOSProber = true;
      efiSupport = true;
    };
  };
}
