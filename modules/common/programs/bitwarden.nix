{
  config,
  lib,
  pkgs,
  identity,
  isDarwin,
  ...
}: {
  options.aspects.programs.bitwarden.enable = lib.mkEnableOption "Bitwarden password manager";

  config = lib.mkIf config.aspects.programs.bitwarden.enable (lib.mkMerge [
    (lib.optionalAttrs isDarwin {
      homebrew.casks = ["bitwarden"];
    })

    (lib.optionalAttrs (!isDarwin) {
      home-manager.users.${identity.name} = {
        home.packages = [pkgs.bitwarden-desktop];
      };
    })
  ]);
}
