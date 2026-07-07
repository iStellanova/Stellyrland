{ sn, ... }: {
  sn.productivity = {
    includes = [ sn.writing ];
  };

  sn.writing.os = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      manuskript
    ];
  };
}
