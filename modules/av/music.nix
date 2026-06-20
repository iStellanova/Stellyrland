{
  sn,
  inputs,
  ...
}: {
  sn.av = {includes = [sn.music];};

  flake-file.inputs.kopuz.url = "github:Kopuz-org/kopuz";

  sn.music.nixos = _: {
    nix.settings.substituters = ["https://kopuz.cachix.org"];
    nix.settings.trusted-public-keys = ["kopuz.cachix.org-1:J2X3AnAYhKTJW5S3aCLoA1ckonQXVNZMQvhZA0YAufw="];
  };

  sn.music.homeManager = {pkgs, ...}: {
    home.packages = [
      inputs.kopuz.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
