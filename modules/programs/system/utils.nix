_: {
  # NixOS GUI utilities Settings
  flake.modules.nixos.utils = {
    config,
    lib,
    pkgs,
    ...
  }: {
    options.aspects.programs.utils.enable = lib.mkEnableOption "Miscellaneous GUI utilities";

    config = lib.mkIf config.aspects.programs.utils.enable {
      environment.systemPackages = with pkgs; [
        gnome-disk-utility
        mission-center
        planify
        proton-vpn
      ];
    };
  };

  # Darwin GUI utilities Settings
  flake.modules.darwin.utils = {
    config,
    lib,
    ...
  }: {
    options.aspects.programs.utils.enable = lib.mkEnableOption "Miscellaneous GUI utilities";

    config = lib.mkIf config.aspects.programs.utils.enable {
      homebrew.casks = ["protonvpn"];
    };
  };
}
