{
  sn,
  inputs,
  ...
}: {
  sn.av = {includes = [sn.music];};

  flake-file.inputs.kopuz.url = "github:Kopuz-org/kopuz";

  sn.music.nixos = {pkgs, ...}: {
    nix.settings.substituters = ["https://kopuz.cachix.org"];
    nix.settings.trusted-public-keys = ["kopuz.cachix.org-1:J2X3AnAYhKTJW5S3aCLoA1ckonQXVNZMQvhZA0YAufw="];
    environment.systemPackages = [
      inputs.kopuz.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
