{
  flake.modules.finix.lollypop = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.lollypop ];
  };

  flake.modules.nixos.lollypop =
    {
      lib,
      host,
      pkgs,
      ...
    }:
    {
      environment.systemPackages = [ pkgs.lollypop ];

      imports = lib.optional (host.persistence or false) {
        preservation.preserveAt."/persist".users.${host.username}.directories = [
          ".local/share/lollypop"
        ];
      };
    };
}
