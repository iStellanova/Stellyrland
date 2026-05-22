{
  config,
  lib,
  isDarwin,
  ...
}: {
  options.aspects.programs.finance.enable = lib.mkEnableOption "Personal finance tools";

  config = lib.mkIf config.aspects.programs.finance.enable (lib.mkMerge [
    (lib.optionalAttrs isDarwin {
      homebrew.casks = ["quicken"];
    })
  ]);
}
