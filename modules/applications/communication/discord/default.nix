{ inputs, ... }:
{
  pins.nixcord = {
    url = "https://github.com/4evy/nixcord";
    follows.nixpkgs = "nixpkgs";
    follows.nixcord-nixpkgs = "nixpkgs";
  };

  flake.modules.homeManager.discord =
    { pkgs, lib, ... }:
    {
      imports = [
        inputs.nixcord.homeModules.nixcord
        ./_music-rpc.nix
      ];

      programs.nixcord = lib.mkIf pkgs.stdenv.hostPlatform.isLinux (
        import ./_config.nix { inherit pkgs lib; }
      );
    };

  flake.modules.nixos.discord =
    { lib, host, ... }:
    {
      imports = lib.optional (host.persistence or false) {
        preservation.preserveAt."/persist".users.${host.username}.directories = [ ".config/vesktop" ];
      };
    };

  flake.modules.darwin.discord =
    {
      host,
      pkgs,
      lib,
      ...
    }:
    {
      imports = [ inputs.nixcord.darwinModules.default ];

      programs.nixcord = (import ./_config.nix { inherit pkgs lib; }) // {
        user = host.username;
      };
    };
}
