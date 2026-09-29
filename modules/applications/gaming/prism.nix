{
  modules.nixos.prism =
    {
      lib,
      host,
      pkgs,
      ...
    }:
    {
      environment.systemPackages = [ pkgs.prismlauncher ];
      imports = lib.optional (host.persistence or false) {
        preservation.preserveAt."/persist".users.${host.username}.directories = [
          ".local/share/PrismLauncher"
        ];
      };
    };

  modules.darwin.prism = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.prismlauncher ];
  };
}
