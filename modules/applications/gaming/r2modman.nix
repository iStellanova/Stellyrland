{
  modules.nixos.r2modman =
    {
      lib,
      host,
      pkgs,
      ...
    }:
    {
      environment.systemPackages = with pkgs; [ r2modman ];
      imports = lib.optional (host.persistence or false) {
        preservation.preserveAt."/persist".users.${host.username}.directories = [
          ".local/share/r2modman"
          ".config/r2modman"
          ".config/r2modmanPlus-local"
        ];
      };
    };

}
