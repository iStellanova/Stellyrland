{
  config,
  lib,
  isDarwin,
  ...
}: {
  options.aspects.programs.writing.enable = lib.mkEnableOption "Writing tools";

  config = lib.mkIf config.aspects.programs.writing.enable (lib.mkMerge [
    (lib.optionalAttrs isDarwin {
      homebrew.masApps = {
        "Beat" = 1549538329;
        "Essayist" = 1537845384;
      };
    })
  ]);
}
