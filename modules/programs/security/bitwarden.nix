_: {
  # NixOS Bitwarden Settings
  flake.modules.nixos.bitwarden = {lib, ...}: {
    options.aspects.programs.bitwarden.enable = lib.mkEnableOption "Bitwarden password manager";
  };

  # Darwin Bitwarden Settings
  flake.modules.darwin.bitwarden = {
    config,
    lib,
    ...
  }: {
    options.aspects.programs.bitwarden.enable = lib.mkEnableOption "Bitwarden password manager";

    config = lib.mkIf config.aspects.programs.bitwarden.enable {
      homebrew.casks = ["bitwarden"];
    };
  };

  # Home Manager Bitwarden Settings
  flake.modules.homeManager.bitwarden = {
    osConfig,
    pkgs,
    lib,
    ...
  }: let
    isDarwin = osConfig ? system.defaults;
  in
    lib.mkIf (osConfig ? aspects.programs.bitwarden && osConfig.aspects.programs.bitwarden.enable && !isDarwin) {
      home.packages = [pkgs.bitwarden-desktop];
    };
}
