_: {
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
        ];
      };
    };
}
