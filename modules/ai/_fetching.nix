{ pkgs, interactiveToolsets }:
let
  searxngUrl = "http://127.0.0.1:8088";

  searxngSettingsTemplate = pkgs.writeText "hermes-searxng-settings.yml" ''
    use_default_settings: true

    server:
      bind_address: "127.0.0.1"
      port: 8088
      secret_key: "@HERMES_SEARXNG_SECRET_KEY@"

    search:
      formats:
        - html
        - json
  '';

  searxngRunner = pkgs.writeShellScript "hermes-searxng" ''
    set -eu

    # Preserve the generated secret, but render Nix-derived settings each start.
    state_dir="$HOME/.hermes/searxng"
    settings="$state_dir/settings.yml"
    secret_file="$state_dir/secret_key"
    ${pkgs.coreutils}/bin/install -d -m 0700 "$state_dir"

    if [ ! -s "$secret_file" ]; then
      ${pkgs.openssl}/bin/openssl rand -hex 32 > "$secret_file"
      chmod 0600 "$secret_file"
    fi

    secret_key="$(${pkgs.coreutils}/bin/cat "$secret_file")"
    ${pkgs.gnused}/bin/sed \
      "s/@HERMES_SEARXNG_SECRET_KEY@/$secret_key/" \
      ${searxngSettingsTemplate} > "$settings.tmp"
    chmod 0600 "$settings.tmp"
    ${pkgs.coreutils}/bin/mv "$settings.tmp" "$settings"

    export SEARXNG_SETTINGS_PATH="$settings"
    exec ${pkgs.searxng}/bin/searxng-run
  '';

  githubMcpRunner = pkgs.writeShellScript "hermes-github-mcp" ''
    set -eu

    # Hermes filters MCP environments; read the token explicitly and never
    # source user-writable credential files as shell code.
    if [ -r /run/secrets/github-token ]; then
      export GITHUB_PERSONAL_ACCESS_TOKEN="$( ${pkgs.coreutils}/bin/cat /run/secrets/github-token )"
    elif [ -r "$HOME/.hermes/github-mcp-token" ]; then
      export GITHUB_PERSONAL_ACCESS_TOKEN="$( ${pkgs.coreutils}/bin/cat "$HOME/.hermes/github-mcp-token" )"
    fi

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
      args = [ ];
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
    gh
  ];

  sessionVariables = {
    SEARXNG_URL = searxngUrl;
  };

  files = {
    ".hermes/github-mcp-token.example" = {
      text = ''
        # Copy this file to github-mcp-token, then chmod 600 github-mcp-token.
        # Put only a free, fine-grained GitHub PAT on the line below. Restrict
        # it to repositories Stellxie may read. Do not commit the active file.
        github_pat_replace_me
      '';
    };
  };

  activation = ''
    mkdir -p "$HOME/.hermes"

    # Preserve credentials while maintaining the non-secret local endpoint.
    env_file="$HOME/.hermes/.env"
    touch "$env_file"
    chmod 0600 "$env_file"
    if ${pkgs.gnugrep}/bin/grep -q '^SEARXNG_URL=' "$env_file"; then
      ${pkgs.gnused}/bin/sed -i \
        's|^SEARXNG_URL=.*|SEARXNG_URL=${searxngUrl}|' \
        "$env_file"
    else
      printf '%s\n' 'SEARXNG_URL=${searxngUrl}' >> "$env_file"
    fi
  '';

  searxngService = {
    Unit = {
      Description = "Private local SearXNG search backend for Hermes";
      After = [ "network-online.target" ];
    };
    Service = {
      ExecStart = "${searxngRunner}";
      Restart = "on-failure";
      RestartSec = 3;
    };
    Install.WantedBy = [ "default.target" ];
  };
}
