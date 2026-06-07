_: let
  fontPkgs = pkgs:
    with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.noto
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
    ];
in {
  den.aspects.fonts.nixos = {pkgs, ...}: {
    fonts.packages = fontPkgs pkgs;
  };

  den.aspects.fonts.darwin = {pkgs, ...}: {
    fonts.packages = fontPkgs pkgs;
    homebrew.casks = ["font-sf-pro"];
  };
}
