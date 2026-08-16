{
  flake.modules.nixos.openssh = {
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
      };
    };
  };

  flake.modules.darwin.openssh = {
    services.openssh.enable = true;
    # nix-darwin lacks NixOS's structured `settings` option; use raw sshd_config text.
    services.openssh.extraConfig = ''
      PasswordAuthentication no
      KbdInteractiveAuthentication no
      PermitRootLogin no
    '';
  };
}
