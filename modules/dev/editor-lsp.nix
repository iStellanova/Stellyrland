_: {
  # Language servers + formatters shared by every editor aspect (helix, zed).
  flake.modules.homeManager.editor-lsp = { pkgs, ... }: {
    home.packages = with pkgs; [
      nixd
      nixfmt
      pyright
      black
      bash-language-server
      shfmt
      lua-language-server
      stylua
      ripgrep
      fd
    ];
  };
}
