{
  modules.nixos.feishin =
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

  modules.darwin.feishin = {
    homebrew.taps = [ "kgarner7/feishin" ];
    homebrew.casks = [ "kgarner7/feishin/feishin" ];
    nix-homebrew.trust.casks = [ "kgarner7/feishin/feishin" ];
  };
}
