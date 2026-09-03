{ inputs, ... }:
{
  flake-file.inputs.llm-agents = {
    url = "github:numtide/llm-agents.nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos.hermes-desktop =
    { lib, host, ... }:
    {
      imports = lib.optional (host.persistence or false) {
        preservation.preserveAt."/persist".users.${host.username}.directories = [
          ".hermes"
        ];
      };
    };

  flake.modules.homeManager.hermes-desktop =
    { pkgs, ... }:
    {
      home.packages = [
        inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.hermes-desktop
      ];
    };
}
