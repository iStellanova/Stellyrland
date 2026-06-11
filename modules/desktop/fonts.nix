{
  sn,
  ...
}: let
  fontPkgs = pkgs:
    with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.noto
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
    ];
in {
  sn.desktop = {includes = [sn.fonts];};

  sn.fonts.nixos = {pkgs, ...}: {
    fonts.packages = fontPkgs pkgs;
  };

  sn.fonts.darwin = {pkgs, ...}: {
    fonts.packages = fontPkgs pkgs;
    homebrew.casks = ["font-sf-pro"];
  };
}
