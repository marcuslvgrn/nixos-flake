{
  users = {
    lovgren = {
      realname = "Marcus Lövgren";
      username = "lovgren";
      group = "users";
      extragroups = [
        "wheel"
        "networkmanager"
        "rtc"
      ];
      email = "marcus.lovgren@proton.me";
      gituser = "marcuslvgrn";
      uid = 1000;
      normalUser = true;
      systemUser = false;
      authorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIux8sh6ofpPIAKRCubTDxS0Ojbuv3MPUJH69mWygrYd lovgren@nixos"
      ];
    };
    gerd = {
      realname = "Gerd Lövgren";
      username = "gerd";
      group = "users";
      extragroups = [
        "wheel"
        "networkmanager"
      ];
      email = "gerd.lovgren@gmail.com";
      gituser = "";
      uid = 1001;
      normalUser = true;
      systemUser = false;
    };
    root = {
      group = "root";
      uid = 0;
      hashedPassword = "!";
      authorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKMxvG/wzUbwpZ/wB1O8CGjNiAsJlF3QRySfuAKuOdrk root@nixos"
      ];
      realname = "System administrator";
    };
  };
}
