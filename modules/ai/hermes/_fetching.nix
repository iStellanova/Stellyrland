{ pkgs, interactiveToolsets }:
let
  searxngUrl = "http://127.0.0.1:8088";

  searxngRunner = pkgs.writeShellScript "hermes-searxng" ''
    set -eu
    umask 077

    state_dir="$HOME/.hermes/searxng"
    settings="$state_dir/settings.yml"
    secret_file="$state_dir/secret_key"
    ${pkgs.coreutils}/bin/install -d -m 0700 "$state_dir"

    if [ ! -s "$secret_file" ]; then
      ${pkgs.openssl}/bin/openssl rand -hex 32 > "$secret_file"
    fi

    secret_key="$(<"$secret_file")"
    ${pkgs.coreutils}/bin/cat > "$settings" <<EOF
    use_default_settings: true

    server:
      bind_address: "127.0.0.1"
      port: 8088
      secret_key: "$secret_key"

    search:
      formats:
        - json
    EOF

    SEARXNG_SETTINGS_PATH="$settings" exec ${pkgs.searxng}/bin/searxng-run
  '';

  githubMcpRunner = pkgs.writeShellScript "hermes-github-mcp" ''
    set -eu

    export GITHUB_PERSONAL_ACCESS_TOKEN="$( ${pkgs.coreutils}/bin/cat /run/secrets/github-token )"
    exec ${pkgs.github-mcp-server}/bin/github-mcp-server stdio
  '';
in
{
  hermesConfig = {
    # Full-page retrieval uses the local browser toolset.
    web.search_backend = "searxng";

    # Local, zero-cost headless Chromium through agent-browser.
    browser.engine = "chrome";

    platform_toolsets.cli = interactiveToolsets;

    mcp_servers.github = {
      command = "${githubMcpRunner}";
      timeout = 90;
      connect_timeout = 30;
      env = {
        # Fetching is deliberately read-only. Expand this only when write
        # operations such as issues or pull requests are explicitly wanted.
        GITHUB_READ_ONLY = "1";
        GITHUB_TOOLSETS = "repos,issues,pull_requests,actions,code_security";
      };
      sampling.enabled = false;
    };
  };

  packages = with pkgs; [
    agent-browser
    chromium
  ];

  sessionVariables = {
    SEARXNG_URL = searxngUrl;
  };

  searxngService = {
    Unit.Description = "Private local SearXNG search backend for Hermes";
    Service = {
      ExecStart = "${searxngRunner}";
      Restart = "on-failure";
      RestartSec = 3;
    };
    Install.WantedBy = [ "default.target" ];
  };
}
