{
  imports = [
    ./users.nix
    ./packages.nix
    ./hardware.nix
    ./services.nix
    ./boot.nix
    ./fonts.nix
    ./nix-settings.nix
  ];

  # Set your time zone.
  time.timeZone = "America/Indianapolis";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  security.sudo-rs = {
    enable = true;
    extraConfig = ''
      Defaults pwfeedback
    '';
  };

  system.stateVersion = "25.11"; # Don't Change, for Compat.
}
