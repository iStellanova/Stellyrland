{ ... }:
{
  modules.homeManager.emacs = { pkgs, ... }:
  {
    home.packages = with pkgs; [
      nixd
      lua-language-server
      bash-language-server
      clojure-lsp
      clang-tools
      jdt-language-server
      python3Packages.markdown
    ];

    programs.emacs = {
      enable = true;
      package = pkgs.emacs-nox.override {
        withNativeCompilation = false;
        withMailutils = false;
        withGpm = false;
      };
      extraPackages = epkgs: with epkgs; [
        catppuccin-theme
        markdown-mode
        nix-mode
        lua-mode
        clojure-mode
        treemacs
        magit
        diff-hl
      ];
      extraConfig = import ./_config.nix;
    };
  };
}
