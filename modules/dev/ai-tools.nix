{ inputs, ... }:
let
  aiPkgs =
    pkgs:
    let
      llm = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
    in
    [
      llm.claude-code
      llm.antigravity-cli
    ];
  osShared = { pkgs, ... }: {
    environment.systemPackages = aiPkgs pkgs ++ [ pkgs.mcp-nixos ];
  };
in
{
  flake-file.inputs.llm-agents = {
    url = "github:numtide/llm-agents.nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos.ai-tools = {
    imports = [
      osShared
      (
        { pkgs, ... }:
        {
          environment.systemPackages = with pkgs; [
            antigravity-fhs
          ];
        }
      )
    ];
  };

  flake.modules.darwin.ai-tools = {
    imports = [
      osShared
      (_: {
        homebrew.casks = [
          "claude"
          "antigravity"
        ];
      })
    ];
  };
}
