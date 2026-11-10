{
  inputs,
  config,
  lib,
  pkgs,
  pkgs-stable,
  pkgs-unstable,
  hostSettings,
  ...
}:

let
  # Import user definitions
  userData = import ./userData.nix;
  usersByName = userData.users;

  # Shared Home Manager config
  homeBase = config.users.homeBaseDir or "/home";
  commonHomeConfig = ../../home-manager;

  # Normal + system user builder
  mkUser =
    username:
    let
      usrcfg = usersByName.${username} or { };
    in
    {
      group = usrcfg.group or "nogroup";
      isNormalUser = usrcfg.normalUser or false;
      isSystemUser = usrcfg.systemUser or false;

      home = lib.mkIf (usrcfg.normalUser or false) "${homeBase}/${username}";

      extraGroups = usrcfg.extragroups or [ ];
      description = usrcfg.realname or "";
      shell = lib.mkIf (usrcfg.normalUser or false) pkgs.bashInteractive;

      hashedPassword = usrcfg.hashedPassword or null;

      hashedPasswordFile = lib.mkIf (usrcfg.normalUser or false
      ) config.sops.secrets."passwords/${username}".path;

      uid = usrcfg.uid or null;

      openssh.authorizedKeys.keys = usrcfg.authorizedKeys or [ ];
    };

  # Home Manager per-user builder
  mkHomeUser =
    username:
    let
      userConfig = usersByName.${username} or { };
      userConfigPath = ../../home-manager/users + "/${username}.nix";
    in
    lib.mkIf (userConfig.normalUser or false) {
      imports = lib.optional (builtins.pathExists userConfigPath) userConfigPath ++ [ commonHomeConfig ];

      _module.args = {
        inherit userConfig hostSettings;
      };
    };

in
{
  # Safety check: all users listed in config must exist in userData.nix
  assertions = [
    {
      assertion = lib.all (u: usersByName ? ${u}) (config.userNames or [ ]);
      message = "config.userNames contains users not defined in userData.nix";
    }
    {
      assertion = lib.all (
        username:
        let
          user = usersByName.${username} or { };
        in
        !(user.normalUser or false) || (user.username or null) == username
      ) (config.userNames or [ ]);
      message = "Normal users in common/users/userData.nix must set username to the matching users attribute name.";
    }
  ];

  # Override NixOS's own mkDefault of "nano" for the shared system editor.
  environment.variables.EDITOR = lib.mkForce "nvim";

  users.mutableUsers = false;

  # System + normal users
  users.users =
    let
      userNamesList = config.userNames or [ ];
    in
    lib.genAttrs userNamesList mkUser;

  # Home Manager configuration
  home-manager =
    let
      userNamesList = config.userNames or [ ];
      normalUsers = lib.filter (u: (usersByName.${u}.normalUser or false)) userNamesList;
    in
    {
      useGlobalPkgs = true;
      useUserPackages = true;

      users = lib.genAttrs normalUsers mkHomeUser // {
        root.imports = [ ../../home-manager/users/root.nix ];
      };

      extraSpecialArgs = {
        inherit
          inputs
          pkgs
          pkgs-stable
          pkgs-unstable
          hostSettings
          ;
        nixosConfig = config;
      };
    };
}
