{ sn, ... }: {
  sn.productivity = {
    includes = [ sn.school ];
  };

  sn.school.os = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      zoom-us
      super-productivity
    ];
  };
}
