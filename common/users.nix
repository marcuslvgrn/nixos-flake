{ inputs, config, lib, pkgs, pkgs-unstable, ... }:

let
  users = [
    {
      realname = "Marcus Lövgren";
      username="lovgren";
      email="marcuslvgrn@gmail.com";
      gituser="marcuslvgrn";
      uid=1000;
    }
    {
      realname = "Gerd Lövgren";
      username="gerd";
      email="gerd.lovgren@gmail.com";
      gituser="tmp";
      uid=1001;
    }
  ];

  # Shared home-manager config file
  commonHomeConfig = ../home-manager/common.nix;

  #Create users
  mkUser = usrcfg: {
    name = usrcfg.username;
    value = {
      isNormalUser = true;
      home = "/home/${usrcfg.username}";
      extraGroups = [ "wheel" "networkmanager" ];
      description = usrcfg.realname;
      shell = pkgs.bash;
      hashedPasswordFile = config.sops.secrets."passwords/${usrcfg.username}".path;
      uid=usrcfg.uid;
    };
  };

  #Setup home manager for all users
  mkHomeUser = usrcfg:
    let
      # Check if there is a per-user config file; fallback to common
      userConfigPath = builtins.toString (../home-manager) + "/" + usrcfg.username + ".nix";
      userConfigExists = builtins.pathExists userConfigPath;
    in
      {
        "${usrcfg.username}" = {
          imports =
            lib.optional userConfigExists userConfigPath
            ++ [ commonHomeConfig ];
          # Expose useful args to the home-manager configs
          _module.args = {
            inherit inputs pkgs-unstable usrcfg;
          };
        };
      };
  
in {
  # Configure all users' Home Manager setups
  users.users =
    # // here is a merge operator
    (builtins.listToAttrs (map mkUser users))
    //
    { root.hashedPassword = "!"; };
  
  home-manager = {
    #foldl' merges user definitions into one users attrset
    # // here is a merge operator
    users = builtins.foldl' lib.recursiveUpdate {} (map mkHomeUser users) // {
      root = {
        imports = [ ../home-manager/root.nix ];
      };
    };
    extraSpecialArgs = { inherit inputs pkgs-unstable; };
  };
  environment.variables.EDITOR = "emacs -nw";

  #If set to true, you are free to add new users and groups to the system with the ordinary useradd and groupadd commands. On system activation, the existing contents of the /etc/passwd and /etc/group files will be merged with the contents generated from the users.users and users.groups options. The initial password for a user will be set according to users.users, but existing passwords will not be changed.
  users.mutableUsers = false;
}
