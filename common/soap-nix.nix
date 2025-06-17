{ config, lib, pkgs, modulesPath, ... }:

{
  imports = let
    # replace this with an actual commit id or tag
    commit = "50754dfaa0e24e313c626900d44ef431f3210138";
  in [ 
    "${builtins.fetchTarball {
      url = "https://github.com/Mic92/sops-nix/archive/${commit}.tar.gz";
      # replace this with an actual hash
      sha256 = "1q0b58m9bm4kkm19c0d8lbr10cg00ijqn63wqwxfc0s5yv6x1san";
    }}/modules/sops"
  ];
}

