{ inputs, ... }:
{
  pins.nixcord = {
    url = "https://github.com/4evy/nixcord";
    follows.nixpkgs = "nixpkgs";
  };

  modules.homeManager.discord = { pkgs, lib, ... }: {
    imports = [
      inputs.nixcord.homeModules.nixcord
    ];

    programs.nixcord = lib.mkIf pkgs.stdenv.hostPlatform.isLinux (
      import ./_config.nix
    );
  };

  modules.nixos.discord = { lib, host, ... }: {
    imports = lib.optional (host.persistence or false) {
      preservation.preserveAt."/persist".users.${host.username}.directories = [
        ".config/vesktop"
      ];
    };
  };

  modules.darwin.discord = { host, ... }: {
      imports = [ inputs.nixcord.darwinModules.default ];

      programs.nixcord = (import ./_config.nix) // {
        user = host.username;
      };
    };
}
