_: {
  # NixOS SSH Server settings
  flake.modules.nixos.openssh = _: {
    config = {
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
  flake.modules.darwin.openssh = _: {
    config = {
      # macOS manages SSH via standard built-in Remote Login.
      # This stub ensures full cross-platform compile compatibility.
    };
  };
}
