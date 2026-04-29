{ config, lib, pkgs, ... }:

{
  options.aspects.core.fonts.enable = lib.mkEnableOption "Core fonts" // { default = true; };

  config = lib.mkIf config.aspects.core.fonts.enable {
    fonts.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.noto
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
    ];
  };
}
