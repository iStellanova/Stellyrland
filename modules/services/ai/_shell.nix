{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.ai;

  svcList = lib.concatStringsSep " " (
    ["ollama" "postgresql" "ai-db-init" "qdrant" "litellm"]
    ++ lib.optional cfg.letta.enable "litellm-think-injector"
    ++ lib.optional cfg.letta.enable "redis-letta"
    ++ lib.optional cfg.letta.enable "letta"
    ++ lib.optional cfg.letta.enable "letta-agent-init"
    ++ lib.optional cfg.letta.enable "letta-proxy"
    ++ lib.optional cfg.searx.enable "searx"
    ++ lib.optional cfg.openWebUI.enable "open-webui"
  );

  # check PyPI for newer versions of manually-pinned packages
  checkUpdates = pkgs.writeShellScript "ai-check-updates" ''
    echo "Checking pinned AI package versions against PyPI..."
    check() {
      local pkg=$1
      local current=$2
      local latest
      latest=$(${pkgs.curl}/bin/curl -sf "https://pypi.org/pypi/$pkg/json" | \
        ${pkgs.python3}/bin/python3 -c "import sys,json; print(json.load(sys.stdin)['info']['version'])")
      if [ "$latest" = "$current" ]; then
        echo "  $pkg: $current (up to date)"
      else
        echo "  $pkg: pinned=$current  latest=$latest  ← update available"
      fi
    }
    # Add entries here when new packages are pinned
    # check "mem0ai" "2.0.4"
    echo "(no pinned PyPI packages currently — Letta is sourced from GitHub)"
  '';
in {
  environment.shellAliases = {
    ai-up = "sudo systemctl start ${svcList}";
    ai-down = "sudo systemctl stop ${svcList}";
    ai-status = "systemctl status ${svcList}";
    ai-logs = "journalctl -f -b -u litellm -u letta";
    ai-check-updates = "${checkUpdates}";
  };

  environment.systemPackages =
    lib.optionals cfg.oterm.enable [pkgs.oterm]
    ++ lib.optionals cfg.letta.enable [pkgs.aichat];

  environment.interactiveShellInit = ''
    ${lib.optionalString cfg.oterm.enable ''
      # oterm: direct Ollama access (quick, no memory overhead)
      alias chat-raw="OLLAMA_HOST=127.0.0.1:11434 oterm"
    ''}
    ${lib.optionalString cfg.letta.enable ''
      # aichat: memory-enhanced chat via Letta (echo agent)
      alias chat="aichat --model letta:echo"
    ''}
  '';
}
