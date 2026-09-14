{
  modules.nixos.office-suite = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.freeoffice ];
  };

  modules.darwin.office-suite = {
    homebrew.casks = [
      "microsoft-excel"
      "microsoft-onenote"
      "microsoft-outlook"
      "microsoft-powerpoint"
      "microsoft-word"
    ];
  };
}
