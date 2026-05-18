{
  config,
  lib,
  pkgs,
  inputs,
  identity,
  isDarwin,
  ...
}: {
  options.aspects.programs.browser.enable = lib.mkEnableOption "Zen Browser";

  config = lib.mkIf config.aspects.programs.browser.enable (lib.mkMerge [
    (lib.optionalAttrs isDarwin {
      homebrew.casks = ["zen"];
    })

    {
      home-manager.users.${identity.name} = {
        home.packages = lib.optionals (!isDarwin) [
          inputs.zen-browser.packages."${pkgs.stdenv.hostPlatform.system}".default
        ];
      };
    }
  ]);
}
