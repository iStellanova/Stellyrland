_:
{
  modules.homeManager.emacs = { pkgs, ... }:
  let
    nix-treesit-grammars = (pkgs.emacsPackagesFor pkgs.emacs-pgtk).treesit-grammars.with-grammars (
      p: [ p.tree-sitter-nix ]
    );
  in
  {
    home.sessionVariables.EMACS_TREESIT_GRAMMAR_PATH = "${nix-treesit-grammars}/lib";

    home.packages = with pkgs; [
      nerd-fonts.symbols-only
      nixd
      bash-language-server
      clojure-lsp
    ];

    programs.emacs = {
      enable = true;
      package = pkgs.emacs-pgtk;
      extraPackages = epkgs: with epkgs; [
        agent-shell
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
        wc-mode
        magit
        diff-hl
      ];
      extraConfig =
        (import ./_startup.nix) +
        (import ./_functions.nix) +
        (import ./_keys.nix);
    };
    services.emacs.enable = true;
  };

}
