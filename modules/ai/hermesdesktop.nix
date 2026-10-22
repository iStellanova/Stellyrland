_: {
  pins.llm-agents = {
    url = "https://github.com/numtide/llm-agents.nix";
    follows.nixpkgs = "nixpkgs";
  };

  modules.nixos.hermes-desktop = { inputs, lib, host, pkgs, ... }: {
      # Build Hermes Desktop against this host's configured nixpkgs.
      nixpkgs.overlays = [
        inputs.llm-agents.overlays.shared-nixpkgs
        (final: prev:
          let
            hermesAgent = prev.llm-agents.hermes-agent.overridePythonAttrs (old: {
              # TODO: Drop when unpatched Hermes passes pythonRuntimeDepsCheckHook with pinned nixpkgs.
              # Source pins: prompt_toolkit==3.0.52, Markdown==3.10.2:
              # https://github.com/NousResearch/hermes-agent/blob/4d04303818b61bf3aa09278af48356315515965b/pyproject.toml
              postPatch = (old.postPatch or "") + ''
                substituteInPlace pyproject.toml \
                  --replace-fail 'prompt_toolkit==3.0.52' 'prompt_toolkit==${final.python3Packages.prompt-toolkit.version}' \
                  --replace-fail 'Markdown==3.10.2' 'Markdown==${final.python3Packages.markdown.version}'
              '';
            });
          in
          {
            llm-agents = prev.llm-agents // {
              hermes-agent = hermesAgent;
              hermes-desktop = prev.llm-agents.hermes-desktop.override {
                hermes-agent = hermesAgent;
              };
            };
          })
      ];
      environment.systemPackages = [ pkgs.llm-agents.hermes-desktop ];
      nix.settings = {
        extra-substituters = [ "https://cache.numtide.com" ];
        extra-trusted-public-keys = [ "nixs3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=" ];
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
