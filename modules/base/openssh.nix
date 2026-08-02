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
    # nix-darwin's openssh module has no `settings` option (unlike nixos'),
    # so the same hardening goes through raw sshd_config text instead.
    services.openssh.extraConfig = ''
      PasswordAuthentication no
      KbdInteractiveAuthentication no
      PermitRootLogin no
    '';
  };
}
