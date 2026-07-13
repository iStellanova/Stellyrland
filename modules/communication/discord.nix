{ inputs, ... }:
{
  flake-file.inputs.nixcord = {
    url = "github:4evy/nixcord";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.homeManager.discord =
    { pkgs, lib, ... }:
    {
      imports = [
        inputs.nixcord.homeModules.nixcord
        ./_discord-music-rpc.nix
      ];

      programs.nixcord = lib.mkIf pkgs.stdenv.isLinux (import ./_nixcord-config.nix);
    };

  flake.modules.darwin.discord =
    { host, ... }:
    {
      imports = [ inputs.nixcord.darwinModules.default ];

      programs.nixcord = (import ./_nixcord-config.nix) // {
        user = host.username;
      };
    };
}
