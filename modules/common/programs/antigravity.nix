{
  config,
  lib,
  pkgs,
  identity,
  isDarwin,
  ...
}: {
  options.aspects.programs.antigravity.enable = lib.mkEnableOption "Antigravity";
  config = lib.mkIf config.aspects.programs.antigravity.enable (lib.mkMerge [
    (lib.optionalAttrs isDarwin {
      homebrew.casks = ["antigravity"];
    })

    {
      home-manager.users.${identity.name} = {
        home.packages = lib.optionals (!isDarwin) [
          pkgs.antigravity-fhs
        ];
      };
    }
  ]);
}
