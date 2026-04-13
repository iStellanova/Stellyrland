{
  services.snapper.configs = {
    home = {
      SUBVOLUME = "/home";
      ALLOW_USERS = [ "stellanova" ];
      TIMELINE_CREATE = true;
      TIMELINE_CLEANUP = true;
    };
  };
}
