{ ... }:
{
  modules.homeManager.emacs = { pkgs, ... }:
  {
    programs.emacs = {
      enable = true;
      package = pkgs.emacs-nox.override {
        withNativeCompilation = false;
        withMailutils = false;
        withGpm = false;
      };
      extraPackages = epkgs: [ epkgs.catppuccin-theme ];
      extraConfig = import ./_config.nix;
    };
  };
}
