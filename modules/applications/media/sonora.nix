{ inputs, ... }:
{
  pins.sonora = {
    url = "https://github.com/sonorahq/sonora";
    follows.nixpkgs = "nixpkgs";
  };

  modules.nixos.sonora = { lib, host, pkgs, ... }: {
    environment.systemPackages = [
      inputs.sonora.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];

    imports = lib.optional (host.persistence or false) {
      preservation.preserveAt."/persist".users.${host.username}.directories = [
        ".config/sonora"
        ".local/share/sonora"
        ".cache/sonora"
      ];
    };
  };

  modules.darwin.sonora = {
    homebrew.taps = [ "nolight132/tap" ];
    homebrew.casks = [ "nolight132/tap/sonora" ];
    nix-homebrew.trust.casks = [ "nolight132/tap/sonora" ];
  };
}
