_: {
  config = {
    # NixOS Options Declaration
    flake.modules.nixos.default = {lib, ...}: {
      options.aspects.programs.writing.enable = lib.mkEnableOption "Writing tools";
    };

    # Darwin Writing Settings
    flake.modules.darwin.default = {
      config,
      lib,
      ...
    }: {
      options.aspects.programs.writing.enable = lib.mkEnableOption "Writing tools";

      config = lib.mkIf config.aspects.programs.writing.enable {
        homebrew.masApps = {
          "Beat" = 1549538329;
          "Essayist" = 1537845384;
        };
      };
    };
  };
}
