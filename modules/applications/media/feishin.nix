{
  flake.modules.nixos.feishin =
    {
      lib,
      host,
      pkgs,
      ...
    }:
    {
      environment.systemPackages = [ pkgs.feishin ];

      imports = lib.optional (host.persistence or false) {
        preservation.preserveAt."/persist".users.${host.username}.directories = [
          ".config/feishin"
        ];
      };
    };

  flake.modules.darwin.feishin = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.feishin ];
  };
}
