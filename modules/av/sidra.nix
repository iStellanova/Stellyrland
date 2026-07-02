{
  inputs,
  sn,
  ...
}: {
  sn.av = {host, ...}: {
    includes =
      if host.class == "nixos"
      then [sn.sidra]
      else [];
  };

  flake-file.inputs.sidra.url = "github:wimpysworld/sidra";

  sn.sidra.homeManager = {pkgs, ...}: {
    home.packages = [inputs.sidra.packages.${pkgs.stdenv.hostPlatform.system}.default];
  };
}
