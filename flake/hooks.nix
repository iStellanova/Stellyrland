{inputs, ...}: {
  imports = [inputs.git-hooks.flakeModule];

  perSystem = {
    config,
    pkgs,
    ...
  }: {
    pre-commit.settings.hooks.treefmt = {
      enable = true;
      package = config.treefmt.build.wrapper;
    };

    # Enter this shell once to install the hooks: nix develop
    devShells.default = pkgs.mkShellNoCC {
      shellHook = config.pre-commit.installationScript;
    };
  };
}
