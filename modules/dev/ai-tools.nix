{
  sn,
  inputs,
  ...
}: let
  aiPkgs = pkgs: let
    llm = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
  in [llm.claude-code llm.antigravity-cli];
in {
  sn.dev = {includes = [sn.ai-tools];};

  flake-file.inputs.llm-agents.url = "github:numtide/llm-agents.nix";

  sn.ai-tools.nixos = {pkgs, ...}: {
    environment.systemPackages = aiPkgs pkgs ++ [pkgs.antigravity-fhs];
  };

  sn.ai-tools.darwin = {pkgs, ...}: {
    homebrew.casks = [
      "claude"
      "antigravity"
    ];

    environment.systemPackages = aiPkgs pkgs;
  };
}
