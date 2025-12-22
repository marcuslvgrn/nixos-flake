{ inputs, config, cfg, lib, pkgs, pkgs-stable, pkgs-unstable, ... }:

let
  userData = import ./userData.nix;
  allUsers = userData.users ++ userData.systemUsers;

  # Shared home-manager config file
  commonHomeConfig = ../home-manager/common.nix;

  #Create users
  mkUser = usrcfg: {
    name = usrcfg.username;
    value = {
      group = usrcfg.group or "nogroup";
      isNormalUser = usrcfg.normalUser or false;
      isSystemUser = usrcfg.systemUser or false;
      home = lib.mkIf (usrcfg.normalUser or false)
        "${config.users.homeBaseDir or "/home"}/${usrcfg.username}";
      extraGroups = usrcfg.extragroups or [];
      description = usrcfg.realname or "";
      shell = lib.mkIf (usrcfg.normalUser or false) pkgs.bashInteractive;
      hashedPasswordFile = lib.mkIf (usrcfg.normalUser or false)
        config.sops.secrets."passwords/${usrcfg.username}".path;
      uid=usrcfg.uid or null;
    };
  };

  #Setup home manager for all users
  mkHomeUser = usrcfg:
    let
      # Check if there is a per-user config file; fallback to common
      userConfigPath = builtins.toString (../home-manager) + "/" + usrcfg.username + ".nix";
      userConfigExists = builtins.pathExists userConfigPath;
    in
      lib.mkIf (usrcfg.normalUser or false) {
        "${usrcfg.username}" = {
          imports = lib.optional userConfigExists userConfigPath ++ [ commonHomeConfig ];
          _module.args = {
            inherit inputs pkgs-unstable cfg usrcfg;
          };
        };
      };
in {
  # Configure all users' Home Manager setups
  users.users =
    # // here is a merge operator
    (builtins.listToAttrs (map mkUser allUsers)) //
    { root.hashedPassword = "!"; };

#  users.groups.mysql = {};
  
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    #foldl' merges user definitions into one users attrset
    # // here is a merge operator
    users = (builtins.foldl' lib.recursiveUpdate {} (map mkHomeUser allUsers)) //
            {
              root = {
                imports = [ ../home-manager/root.nix ];
              };
            };
    extraSpecialArgs = { inherit inputs pkgs pkgs-stable pkgs-unstable; };
  };
  environment.variables.EDITOR = "emacs -nw";

  #If set to true, you are free to add new users and groups to the system with the ordinary useradd and groupadd commands. On system activation, the existing contents of the /etc/passwd and /etc/group files will be merged with the contents generated from the users.users and users.groups options. The initial password for a user will be set according to users.users, but existing passwords will not be changed.
  users.mutableUsers = false;
}
