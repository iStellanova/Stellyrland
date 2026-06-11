{
  sn,
  ...
}: {
  sn.terminal = {includes = [sn.openssh];};

  sn.openssh.nixos = _: {
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
      };
    };
  };
}
