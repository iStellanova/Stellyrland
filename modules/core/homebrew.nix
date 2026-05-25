{lib, ...}: {
  # Darwin Homebrew settings
  flake.modules.darwin.homebrew = {config, ...}: {
    options.aspects.darwin.homebrew.enable = lib.mkEnableOption "Darwin homebrew configuration";

    config = lib.mkIf config.aspects.darwin.homebrew.enable {
      homebrew = {
        enable = true;
        onActivation = {
          autoUpdate = true;
          cleanup = "zap";
          upgrade = true;
        };
      };
    };
  };
}
