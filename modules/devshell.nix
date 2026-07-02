_: {
  perSystem =
    {
      pkgs,
      config,
      ...
    }:
    {
      devShells.default = pkgs.mkShellNoCC {
        packages = [
          config.treefmt.build.wrapper
          config.packages.write-tack
        ];
      };
    };
}
