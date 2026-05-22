{
  config,
  lib,
  pkgs,
  isDarwin,
  ...
}: {
  options.aspects.programs.utils.enable = lib.mkEnableOption "Miscellaneous GUI utilities";

  config = lib.mkIf config.aspects.programs.utils.enable (lib.mkMerge [
    (lib.optionalAttrs isDarwin {
      homebrew.casks = ["protonvpn"];
    })

    (lib.optionalAttrs (!isDarwin) {
      environment.systemPackages = with pkgs; [
        gnome-disk-utility
        mission-center
        planify
        proton-vpn
      ];
    })
  ]);
}
