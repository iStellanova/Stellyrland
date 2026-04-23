{ config, lib, ... }:

{
  options.aspects.programs.common.enable = lib.mkEnableOption "Common programs and utilities" // { default = true; };

  config = lib.mkIf config.aspects.programs.common.enable {
    home-manager.users.stellanova = { inputs, pkgs, ... }: {
      home.packages = with pkgs; [
        # --- Browsers ---
        inputs.zen-browser.packages."${pkgs.stdenv.hostPlatform.system}".default

        # --- CLI Utilities ---
        comma

        # --- Wayland Utilities ---
        cliphist
        wl-clipboard
      ];

      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
      };

      programs.nix-index.enable = true;
    };
  };
}
