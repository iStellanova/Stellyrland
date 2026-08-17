{ inputs, ... }:
{
  perSystem =
    {
      pkgs,
      config,
      ...
    }:
    {
      devShells.default = pkgs.mkShellNoCC {
        packages = with config; [
          treefmt.build.wrapper
          packages.write-tack
          inputs.tack.packages.${pkgs.stdenv.hostPlatform.system}.tack
        ];
      };
    };
}
