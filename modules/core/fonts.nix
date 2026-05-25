_: {
  # System-level Linux Font settings
  flake.modules.nixos.fonts = {pkgs, ...}: {
    config = {
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
  flake.modules.darwin.fonts = {pkgs, ...}: {
    config = {
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
}
