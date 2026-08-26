{
  flake.modules.nixos.avahi = {
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      publish = {
        enable = true;
        addresses = true;
      };
    };
  };

  flake.modules.finix.avahi = { modules, ... }: {
    imports = [ modules.avahi ];
    services.avahi = {
      enable = true;
      settings.publish.publish-addresses = true;
    };
  };
}
