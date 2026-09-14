{
  modules.nixos.soulseek =
    { lib, host, pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.nicotine-plus ];

      imports = lib.optional (host.persistence or false) {
        preservation.preserveAt."/persist".users.${host.username}.directories = [
          ".config/nicotine"
          ".local/share/nicotine"
        ];
      };
    };

  modules.darwin.soulseek = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.nicotine-plus ];
  };
}
