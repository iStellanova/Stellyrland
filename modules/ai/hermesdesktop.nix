_: {
  flake-file.inputs.llm-agents = {
    url = "github:numtide/llm-agents.nix";
  };

  flake.modules.nixos.hermes-desktop =
    {
      inputs,
      lib,
      host,
      pkgs,
      ...
    }:
    {
      # Build Hermes Desktop against this host's configured nixpkgs.
      nixpkgs.overlays = [ inputs.llm-agents.overlays.shared-nixpkgs ];
      environment.systemPackages = [ pkgs.llm-agents.hermes-desktop ];
      nix.settings = {
        extra-substituters = [ "https://cache.numtide.com" ];
        extra-trusted-public-keys = [
          "nixs3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
        ];
      };
      imports = lib.optional (host.persistence or false) {
        preservation.preserveAt."/persist".users.${host.username}.directories = [
          ".config/Hermes"
          ".hermes"
        ];
      };
    };

  flake.modules.darwin.hermes-desktop = {
    homebrew.casks = [ "hermes-desktop" ];
  };
}
