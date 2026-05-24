_: {
  config = {
    # NixOS SSH Server settings
    flake.modules.nixos.openssh = {
      config,
      lib,
      ...
    }: {
      options.aspects.services.openssh.enable = lib.mkEnableOption "Secure Shell (SSH) daemon";

      config = lib.mkIf config.aspects.services.openssh.enable {
        services.openssh = {
          enable = true;
          settings = {
            PasswordAuthentication = false;
            KbdInteractiveAuthentication = false;
            PermitRootLogin = "no";
          };
        };
      };
    };

    # Darwin SSH Server settings
    flake.modules.darwin.openssh = {
      config,
      lib,
      ...
    }: {
      options.aspects.services.openssh.enable = lib.mkEnableOption "Secure Shell (SSH) daemon";

      config = lib.mkIf config.aspects.services.openssh.enable {
        # macOS manages SSH via standard built-in Remote Login.
        # This stub ensures full cross-platform compile compatibility.
      };
    };
  };
}
