_: {
  flake.modules.nixos.office-suite = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.freeoffice ];
  };

  flake.modules.darwin.office-suite = _: {
    homebrew.casks = [
      "microsoft-excel"
      "microsoft-onenote"
      "microsoft-outlook"
      "microsoft-powerpoint"
      "microsoft-word"
    ];
  };
}
