{ inputs, config, lib, pkgs, pkgs-stable, pkgs-unstable, ... }:

let
  # Import your user definitions
  userData = import ./userData.nix;
  usersByName = userData.users;

  # Shared Home Manager config
  homeBase = config.users.homeBaseDir or "/home";
  commonHomeConfig = ../home-manager/common.nix;

  moduleCfg = config.moduleCfg;

  # Normal + system user builder
  mkUser = username:
    let usrcfg = usersByName.${username} or {}; in
    {
      group = usrcfg.group or "nogroup";
      isNormalUser = usrcfg.normalUser or false;
      isSystemUser = usrcfg.systemUser or false;

      home = lib.mkIf (usrcfg.normalUser or false)
        "${homeBase}/${username}";

      extraGroups = usrcfg.extragroups or [];
      description = usrcfg.realname or "";
      shell = lib.mkIf (usrcfg.normalUser or false)
        pkgs.bashInteractive;

      hashedPasswordFile = lib.mkIf (usrcfg.normalUser or false)
        config.sops.secrets."passwords/${username}".path;

      uid = usrcfg.uid or null;
    };

  # Home Manager per-user builder
  mkHomeUser = username:
    let
      usrcfg = usersByName.${username} or {};
      userConfigPath = ../home-manager + "/${username}.nix";
    in
      lib.mkIf (usrcfg.normalUser or false) {
        imports =
          lib.optional (builtins.pathExists userConfigPath)
            userConfigPath
          ++ [ commonHomeConfig ];

        _module.args = {
#          inherit inputs pkgs-unstable pkgs-stable usrcfg cfg moduleCfg;
          inherit inputs pkgs-unstable pkgs-stable usrcfg moduleCfg;
        };
      };

in {
  # Safety check: all users listed in moduleCfg must exist in userData.nix
#  assertions = [
#    {
#      assertion = lib.all (u: usersByName ? u) (config.moduleCfg.userNames or []);
#      message = "moduleCfg.userNames contains users not defined in userData.nix";
#    }
#  ];

  environment.variables.EDITOR = "emacs -nw";

  users.mutableUsers = false;

  # System + normal users
  users.users = let
    userNamesList = moduleCfg.userNames or [];
  in
    lib.genAttrs userNamesList mkUser
    // { root.hashedPassword = "!"; };

  # Home Manager configuration
  home-manager = let
    userNamesList = moduleCfg.userNames or [];
    normalUsers = lib.filter (u: (usersByName.${u}.normalUser or false)) userNamesList;
  in
  {
    useGlobalPkgs = true;
    useUserPackages = true;

    users = lib.genAttrs normalUsers mkHomeUser
      // { root.imports = [ ../home-manager/root.nix ]; };

    extraSpecialArgs = { inherit inputs pkgs pkgs-stable pkgs-unstable; };
  };
}
