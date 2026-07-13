{ inputs, ... }:
{
  flake-file.inputs.sidra.url = "github:wimpysworld/sidra";

  flake.modules.homeManager.sidra = { pkgs, ... }: {
    home.packages = [ inputs.sidra.packages.${pkgs.stdenv.hostPlatform.system}.default ];
  };
}
