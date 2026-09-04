_: {
  flake-file.inputs.llm-agents = {
    url = "github:numtide/llm-agents.nix";
  };

  flake.modules.nixos.hermes-desktop =
    { lib, host, ... }:
    {
      nix.settings = {
        extra-substituters = [ "https://cache.numtide.com" ];
        extra-trusted-public-keys = [
          "nixs3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
        ];
      };
      imports = lib.optional (host.persistence or false) {
        preservation.preserveAt."/persist".users.${host.username}.directories = [
          ".hermes"
        ];
      };
    };

  flake.modules.homeManager.hermes-desktop =
    {
      inputs,
      pkgs,
      ...
    }:
    {
      home.packages = [
        inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.hermes-desktop
      ];
    };
}
