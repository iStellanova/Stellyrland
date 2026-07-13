_:
let
  fontPkgs =
    pkgs:
    with pkgs;
    [
      nerd-fonts.jetbrains-mono
      nerd-fonts.noto
      noto-fonts
      noto-fonts-cjk-sans
    ]
    ++ pkgs.lib.optionals (!pkgs.stdenv.isDarwin) [
      noto-fonts-color-emoji
    ];
in
{
  flake.modules.nixos.fonts = { pkgs, ... }: {
    fonts.packages = fontPkgs pkgs;
  };

  flake.modules.darwin.fonts = { pkgs, ... }: {
    fonts.packages = fontPkgs pkgs;
    homebrew.casks = [ "font-sf-pro" ];
  };
}
