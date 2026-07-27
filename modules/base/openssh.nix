_: {
  flake.modules.nixos.openssh = _: {
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
      };
    };
  };

  flake.modules.darwin.openssh = _: {
    services.openssh.enable = true;
  };
}
