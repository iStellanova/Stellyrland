{ inputs, ... }:
{
  flake-file.inputs.nixcord = {
    url = "github:4evy/nixcord";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.homeManager.discord =
    { osConfig, pkgs, lib, ... }:
    {
      imports = [
        osConfig._module.args.inputs.nixcord.homeModules.nixcord
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
