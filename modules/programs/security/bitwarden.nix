_: {
  config = {
    # NixOS Bitwarden Settings
    flake.modules.nixos.bitwarden = {
      config,
      lib,
      pkgs,
      ...
    }: {
      options.aspects.programs.bitwarden.enable = lib.mkEnableOption "Bitwarden password manager";

      config = lib.mkIf config.aspects.programs.bitwarden.enable {
        home-manager.users.${config.identity.username} = {
          home.packages = [pkgs.bitwarden-desktop];
        };
      };
    };

    # Darwin Bitwarden Settings
    flake.modules.darwin.bitwarden = {
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
