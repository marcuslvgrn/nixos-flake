{
  lib,
  ...
}:

{
  imports = [
    ./disk-config.nix
  ];

  # nixos-facter generates HW specific kernel options
  # to update, run 'sudo nix run nixpkgs#nixos-facter -- -o facter.json'
  hardware.facter.reportPath = ./facter.json;

  # There is an SSD
  ssd.enable = true;

  networking = {
    useDHCP = lib.mkForce false;
    interfaces.enp1s0 = {
      wakeOnLan.enable = true;
      ipv4.addresses = [
        {
          address = "192.168.0.6";
          prefixLength = 24;
        }
      ];
    };
    nameservers = [ "192.168.0.6" ];
    defaultGateway = {
      address = "192.168.0.1";
      interface = "enp1s0";
    };
    search = [
      "local"
    ];
  };
}
