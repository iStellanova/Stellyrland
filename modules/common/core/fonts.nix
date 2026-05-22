{
  config,
  lib,
  pkgs,
  isDarwin,
  ...
}: {
  options.aspects.core.fonts.enable = lib.mkEnableOption "Core fonts";

  config = lib.mkIf config.aspects.core.fonts.enable (lib.mkMerge [
    {
      fonts.packages = with pkgs; [
        nerd-fonts.jetbrains-mono
        nerd-fonts.noto
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-color-emoji
      ];
    }

    (lib.optionalAttrs isDarwin {
      homebrew.casks = ["font-sf-pro"];
    })
  ]);
}
