{ inputs, pkgs }:
let
  githubMcpRunner = pkgs.writeShellScript "hermes-github-mcp" ''
    set -eu

    export GITHUB_PERSONAL_ACCESS_TOKEN="$( ${pkgs.coreutils}/bin/cat /run/secrets/github-token )"
    exec ${pkgs.github-mcp-server}/bin/github-mcp-server stdio
  '';
in
{
  hermesConfig = {
    mcp_servers.github = {
      command = "${githubMcpRunner}";
      timeout = 90;
      connect_timeout = 30;
      env = {
        GITHUB_READ_ONLY = "1";
        GITHUB_TOOLSETS = "repos,issues,pull_requests,actions,code_security";
      };
      sampling.enabled = false;
    };

    mcp_servers.nixos = {
      command = "${pkgs.mcp-nixos}/bin/mcp-nixos";
      supports_parallel_tool_calls = true;
      sampling.enabled = false;
    };
  };

  packages = [
    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.agent-browser
    pkgs.chromium
  ];
}
