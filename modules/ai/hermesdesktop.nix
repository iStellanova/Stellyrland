_: {
  pins.llm-agents = {
    url = "https://github.com/numtide/llm-agents.nix";
    follows.nixpkgs = "nixpkgs";
  };

  modules.nixos.hermes-desktop =
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

  modules.darwin.hermes-desktop = {
    homebrew.casks = [ "hermes-desktop" ];
  };
}
