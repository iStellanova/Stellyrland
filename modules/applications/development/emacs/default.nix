{ ... }:
{
  modules.homeManager.emacs = { pkgs, ... }:
  let
    emacs-package = pkgs.emacs-nox.override {
      withNativeCompilation = false;
      withMailutils = false;
      withGpm = false;
    };
    emacs-packages = pkgs.emacsPackagesFor emacs-package;
    nix-treesit-grammars = emacs-packages.treesit-grammars.with-grammars (
      p: [ p.tree-sitter-nix ]
    );
  in
  {
    home.sessionVariables.EMACS_TREESIT_GRAMMAR_PATH = "${nix-treesit-grammars}/lib";

    home.packages = with pkgs; [
      nixd
      bash-language-server
      clojure-lsp
    ];

    programs.emacs = {
      enable = true;
      package = emacs-package;
      extraPackages = epkgs: with epkgs; [
        hermes
        catppuccin-theme
        vertico
        nix-ts-mode
        indent-bars
        nix-treesit-grammars
        markdown-mode
        lua-mode
        clojure-mode
        treemacs
        treemacs-nerd-icons
        magit
        diff-hl
      ];
      extraConfig =
        (import ./_startup.nix) +
        (import ./_functions.nix) +
        (import ./_keys.nix);
    };
  };
}
