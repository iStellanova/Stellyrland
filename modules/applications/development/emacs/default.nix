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
      fd
      ripgrep
      fzf
      bat
    ];

    programs.emacs = {
      enable = true;
      package = pkgs.emacs-nox.override {
        withNativeCompilation = false;
        withMailutils = false;
        withGpm = false;
      };
      extraPackages = epkgs: with epkgs; [
        hermes
        catppuccin-theme
        vertico
        markdown-mode
        nix-mode
        lua-mode
        clojure-mode
        treemacs
        treemacs-nerd-icons
        magit
        diff-hl
        fzf
      ];
      extraConfig =
        (import ./_startup.nix) +
        (import ./_functions.nix) +
        (import ./_keys.nix);
    };
  };
}
