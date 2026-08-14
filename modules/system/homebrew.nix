{ inputs, ... }:
{
  flake-file.inputs.nix-homebrew.url = "github:zhaofengli/nix-homebrew";

  flake.modules.darwin.homebrew =
    { host, ... }:
    {
      imports = [ inputs.nix-homebrew.darwinModules.nix-homebrew ];

      nix-homebrew = {
        enable = true;
        user = host.username;
        autoMigrate = true;
      };

      homebrew = {
        enable = true;
        onActivation = {
          autoUpdate = true;
          cleanup = "zap";
          upgrade = true;
        };
      };
    };
}
