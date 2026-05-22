_: {
  config = {
    # NixOS Options Declaration
    flake.modules.nixos.default = {
      lib,
      ...
    }: {
      options.aspects.programs.finance.enable = lib.mkEnableOption "Personal finance tools";
    };

    # Darwin Finance Settings
    flake.modules.darwin.default = {
      config,
      lib,
      ...
    }: {
      options.aspects.programs.finance.enable = lib.mkEnableOption "Personal finance tools";

      config = lib.mkIf config.aspects.programs.finance.enable {
        homebrew.casks = ["quicken"];
      };
    };
  };
}
