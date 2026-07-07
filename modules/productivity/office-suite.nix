{ sn, ... }: {
  sn.productivity = {
    includes = [ sn.office-suite ];
  };

  sn.office-suite.nixos = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.freeoffice ];
  };

  sn.office-suite.darwin = _: {
    homebrew.casks = [
      "microsoft-excel"
      "microsoft-onenote"
      "microsoft-outlook"
      "microsoft-powerpoint"
      "microsoft-word"
    ];
  };
}
