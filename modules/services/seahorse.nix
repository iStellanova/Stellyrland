_: {
  config = {
    # NixOS Seahorse Settings
    flake.modules.nixos.default = {
      config,
      lib,
      ...
    }: {
      options.aspects.services.seahorse.enable = lib.mkEnableOption "Seahorse GUI for managing GPG keys and SSH passwords";

      config = lib.mkIf config.aspects.services.seahorse.enable {
        programs.seahorse.enable = true;
      };
    };
  };
}
