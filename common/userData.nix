{
  users = [
    {
      realname = "Marcus Lövgren";
      username="lovgren";
      group="users";
      extragroups=[ "wheel" "networkmanager" "rtc"];
      email="marcuslvgrn@gmail.com";
      gituser="marcuslvgrn";
      uid=1000;
      normalUser=true;
      systemUser=false;
    }
    {
      realname = "Gerd Lövgren";
      username="gerd";
      group="users";
      extragroups=[ "wheel" "networkmanager" ];
      email="gerd.lovgren@gmail.com";
      gituser="";
      uid=1001;
      normalUser=true;
      systemUser=false;
    }
  ];
  systemUsers= [
#    {
#      username="mysql";
#      normalUser=false;
#      systemUser=true;
#      extragroups=[ "keys" ];
#    }
#    {
#      username="nextcloud";
#      normalUser=false;
#      systemUser=true;
#      extragroups=[ "keys" ];
#    }
  ];
}
