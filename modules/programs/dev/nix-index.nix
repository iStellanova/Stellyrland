{
  lib,
  ...
}: {
  config = {
    # Home Manager nix-index Settings
    flake.modules.homeManager.default = {
      osConfig,
      ...
    }:
      lib.mkIf (osConfig ? aspects.programs.nix-index && osConfig.aspects.programs.nix-index.enable) {
        programs.nix-index.enable = true;
        programs.nix-index-database.comma.enable = true;
      };

    # NixOS Options Declaration
    flake.modules.nixos.default = {
      lib,
      ...
    }: {
      options.aspects.programs.nix-index.enable = lib.mkEnableOption "nix-index with pre-built database and comma";
    };

    # Darwin Options Declaration
    flake.modules.darwin.default = {
      lib,
      ...
    }: {
      options.aspects.programs.nix-index.enable = lib.mkEnableOption "nix-index with pre-built database and comma";
    };
  };
}
