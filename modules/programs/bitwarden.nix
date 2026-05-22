_: {
  config = {
    # NixOS Bitwarden Settings
    flake.modules.nixos.default = {
      config,
      lib,
      pkgs,
      identity,
      ...
    }: {
      options.aspects.programs.bitwarden.enable = lib.mkEnableOption "Bitwarden password manager";

      config = lib.mkIf config.aspects.programs.bitwarden.enable {
        home-manager.users.${identity.name} = {
          home.packages = [pkgs.bitwarden-desktop];
        };
      };
    };

    # Darwin Bitwarden Settings
    flake.modules.darwin.default = {
      config,
      lib,
      ...
    }: {
      options.aspects.programs.bitwarden.enable = lib.mkEnableOption "Bitwarden password manager";

      config = lib.mkIf config.aspects.programs.bitwarden.enable {
        homebrew.casks = ["bitwarden"];
      };
    };
  };
}
