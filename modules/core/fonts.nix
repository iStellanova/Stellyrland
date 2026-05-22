{
  lib,
  ...
}: {
  config = {
    # System-level Linux Font settings
    flake.modules.nixos.default = {
      config,
      pkgs,
      ...
    }: {
      options.aspects.core.fonts.enable = lib.mkEnableOption "Core fonts";

      config = lib.mkIf config.aspects.core.fonts.enable {
        fonts.packages = with pkgs; [
          nerd-fonts.jetbrains-mono
          nerd-fonts.noto
          noto-fonts
          noto-fonts-cjk-sans
          noto-fonts-color-emoji
        ];
      };
    };

    # System-level macOS (Darwin) Font settings
    flake.modules.darwin.default = {
      config,
      pkgs,
      ...
    }: {
      options.aspects.core.fonts.enable = lib.mkEnableOption "Core fonts";

      config = lib.mkIf config.aspects.core.fonts.enable {
        fonts.packages = with pkgs; [
          nerd-fonts.jetbrains-mono
          nerd-fonts.noto
          noto-fonts
          noto-fonts-cjk-sans
          noto-fonts-color-emoji
        ];
        homebrew.casks = ["font-sf-pro"];
      };
    };
  };
}
