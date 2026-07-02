{
  sn,
  inputs,
  ...
}: let
  ollamaUrl = "http://localhost:11434/v1";

  # Shared between the gateway service and the interactive CLI config written
  # via home-manager — same models either way.
  hermesConfig = {
    model = {
      provider = "custom";
      base_url = ollamaUrl;
      default = "qwen3.6:27b";
    };

    # Subagents spawned by delegate_task — routed to the coding-focused model.
    delegation = {
      provider = "custom";
      base_url = ollamaUrl;
      model = "qwen3-coder:30b";
    };

    # Side-task models: vision gets the multimodal model, everything else
    # shares the lightweight aux model.
    auxiliary = {
      vision = {
        base_url = ollamaUrl;
        model = "gemma4:26b";
      };
      web_extract = {
        base_url = ollamaUrl;
        model = "qwen3:8b";
      };
      compression = {
        base_url = ollamaUrl;
        model = "qwen3:8b";
      };
      session_search = {
        base_url = ollamaUrl;
        model = "qwen3:8b";
      };
      skills_hub = {
        base_url = ollamaUrl;
        model = "qwen3:8b";
      };
      mcp = {
        base_url = ollamaUrl;
        model = "qwen3:8b";
      };
      flush_memories = {
        base_url = ollamaUrl;
        model = "qwen3:8b";
      };
    };

    terminal = {
      backend = "local";
      timeout = 180;
      lifetime_seconds = 300;
    };

    # Auto-snapshot the filesystem before destructive operations — a safety
    # net given both profiles (gateway's cron jobs, local `hermes chat`) have
    # real terminal/file write access. Off by default upstream.
    checkpoints.enabled = true;

    # Routes short/simple turns (under the char/word thresholds, no code/URLs/
    # complex-task keywords) to the small aux model instead of the 27B default —
    # casual chat responds in seconds instead of ~a minute, while anything
    # substantial still gets the primary model.
    smart_model_routing = {
      enabled = true;
      max_simple_chars = 160;
      max_simple_words = 28;
      cheap_model = {
        provider = "custom";
        base_url = ollamaUrl;
        model = "qwen3:8b";
      };
    };

    # Cloud failover when the local Ollama backend errors out, rate-limits, or
    # goes down (OOM, ROCm crash, etc). Reuses the Claude Code OAuth session
    # already present at ~/.claude/.credentials.json — no separate API key.
    fallback_model = {
      provider = "anthropic";
      model = "claude-sonnet-4-6";
    };
  };

  # Identity, read from SOUL.md in HERMES_HOME if present (falls back to a
  # generic "You are Hermes Agent..." string otherwise) — deployed below to
  # both profiles. The "Hermes Agent" name still surfaces separately when the
  # agent talks about the software/platform it runs on (a different, hardcoded
  # string) — this only changes its own name and persona.
  soulMd = ''
    You are Stellxie, an intelligent AI assistant. You have the energy and
    instincts of a rabbit: quick, alert, and curious — you pick up on details
    fast, hop straight to the point, and stay light on your feet when a
    conversation changes direction. You're helpful, knowledgeable, and direct.
    You assist users with a wide range of tasks including answering questions,
    writing and editing code, analyzing information, creative work, and
    executing actions via your tools. You communicate clearly, admit
    uncertainty when appropriate, and prioritize being genuinely useful over
    being verbose unless otherwise directed below. Be targeted and efficient
    in your exploration and investigations — like a rabbit, you don't linger
    longer than you need to before darting to the next thing. Stay warm and a
    little playful, but never let the personality get in the way of being
    useful.
  '';
in {
  sn.ai = {includes = [sn.hermes];};

  flake-file.inputs.nix-hermes-agent = {
    url = "github:0xrsydn/nix-hermes-agent";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  sn.hermes.nixos = {
    host,
    config,
    pkgs,
    ...
  }: {
    imports = [inputs.nix-hermes-agent.nixosModules.hermes-agent];

    # Pinned static — upstream's module creates this user with no uid/gid set,
    # so it's dynamically allocated from the free system-ID pool (currently
    # clustered at 991-999 alongside wpa_supplicant, sshd, etc. on this host).
    # Disabling+re-enabling sn.ai (or any module reordering that shifts pool
    # allocation) can reassign a different number on the next rebuild, silently
    # orphaning every file hermes already wrote under the old uid — which is
    # exactly what broke the gateway's own internal logger after sn.ai was
    # toggled off and back on this session. 500/500 is unused on this host
    # (checked via getent) and well clear of the 990s where dynamic allocation
    # has been landing, so a future reallocation is unlikely to collide with it.
    users.users.hermes.uid = 500;
    users.groups.hermes.gid = 500;

    services.ollama.loadModels = [
      "qwen3.6:27b" # main model
      "qwen3-coder:30b" # coding delegate
      "qwen3:8b" # aux slots
      "gemma4:26b" # vision
      "nomic-embed-text" # embeddings (pulled for direct API use; Hermes has no embedding hook)
    ];

    # Bot token grants full control of the Discord bot, the allowed-users ID
    # is otherwise plaintext in a public repo, and the Anthropic/Tavily keys
    # are billable credentials — all encrypted at rest via sops-nix
    # (modules/system/secrets.nix) rather than living in the Nix store. Add
    # them with: nix run nixpkgs#sops -- secrets/secrets.yaml
    # (keys: discord-bot-token, discord-allowed-users — the latter is your
    # own numeric Discord user ID; Settings → Advanced → Developer Mode →
    # right-click your name → Copy User ID — anthropic-api-key, used by
    # fallback_model below since the gateway runs as a system user with no
    # Claude Code OAuth session to reuse — and tavily-api-key, backing the
    # `safe` toolset's web_search/web_extract since the gateway has no
    # browser to fall back to like the homeManager profile does).
    sops.secrets.discord-bot-token = {};
    sops.secrets.discord-allowed-users = {};
    sops.secrets.anthropic-api-key = {};
    sops.secrets.tavily-api-key = {};
    sops.templates."hermes-gateway-env" = {
      content = ''
        DISCORD_BOT_TOKEN=${config.sops.placeholder.discord-bot-token}
        DISCORD_ALLOWED_USERS=${config.sops.placeholder.discord-allowed-users}
        ANTHROPIC_API_KEY=${config.sops.placeholder.anthropic-api-key}
        TAVILY_API_KEY=${config.sops.placeholder.tavily-api-key}
      '';
      owner = "hermes";
      group = "hermes";
      mode = "0400";
    };

    services.hermes-agent = {
      enable = true;

      environment = {
        # Ollama ignores bearer auth, but Hermes' provider-resolution chain
        # (hermes_cli/runtime_provider.py) falls back to OPENAI_API_KEY for
        # any non-OpenRouter base_url when no explicit key is configured —
        # this dummy value is what actually gets sent, harmlessly ignored.
        OPENAI_API_KEY = "ollama";

        # Without this, Python block-buffers stdout when it's not a TTY (true
        # here, since output is redirected to logPath) — error detail can sit
        # in an in-process buffer indefinitely while only flush()-ed UI frames
        # reach the log file, making the gateway log useless for debugging.
        PYTHONUNBUFFERED = "1";
      };

      environmentFiles = [config.sops.templates."hermes-gateway-env".path];

      # Upstream's bundled "dogfood" skill has a nested SKILL.md
      # (dogfood/hermes-agent-setup) under its own top-level SKILL.md. The
      # installer copies "dogfood" wholesale (read-only, from the Nix store),
      # then fails trying to overwrite the nested copy because the parent dir
      # it just wrote is read-only. upstreamSrc is only used for this
      # skill-copy step (not for building the hermes binary itself), so strip
      # the one duplicate nested skill there — every other current and future
      # bundled skill still installs normally.
      package = inputs.nix-hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.hermes-agent.overrideAttrs (old: {
        passthru =
          old.passthru
          // {
            upstreamSrc = pkgs.runCommand "hermes-agent-upstream-src-patched" {} ''
              cp -r ${old.passthru.upstreamSrc} $out
              chmod -R u+w $out
              rm -rf $out/skills/dogfood/hermes-agent-setup
            '';
          };
      });

      # Deep-merged into cli-config.yaml at activation. Overrides the discord
      # platform's default toolset (hermes-discord = hermes-cli, the full
      # toolset incl. terminal/file/code_execution, plus discord/discord_admin)
      # with safe (web/vision/image_gen) + cronjob (list/manage its own
      # scheduled jobs) — Discord is a remote-triggerable surface (account
      # compromise, or prompt injection via fetched web content combined with
      # exec/file access — classic agentic-tool exfil pattern), so it stays
      # deliberately scoped down. Shell/file access lives on the homeManager
      # `hermes chat` profile instead — only triggerable locally by you, and
      # already strictly more capable (full browser) — there's no need for
      # Discord to duplicate that with the weaker remote-exposure tradeoff.
      # NB: the config key is platform_toolsets.<platform>, NOT a flat
      # top-level `toolsets` list — the latter is silently ignored (confirmed
      # by reading hermes_cli/tools_config.py's _get_platform_tools()).
      #
      # platform_toolsets.cron is the same mechanism, applied to a different
      # gap: cron jobs are *created* through Discord's scoped-down toolset,
      # but a created job *runs* under its own "cron" platform resolution
      # (cron/scheduler.py spawns it with no enabled_toolsets, only a
      # disabled_toolsets list), which otherwise defaults wide open to the
      # full hermes-cron set (terminal, file, browser, code_execution,
      # delegate_task, ...) — silently undoing the Discord scoping the
      # moment a job actually fires. Upstream always
      # strips cronjob/messaging/clarify from cron-spawned agents regardless
      # of this list (no recursive scheduling, no live messaging/blocking).
      # terminal + file are kept because that's the actual point of cron
      # jobs here (e.g. reading .tack/pins.lock.json to check for nixpkgs
      # updates) — browser/code_execution/delegate_task are dropped as
      # unnecessary surface for maintenance-style checks. Same systemd
      # sandbox (ProtectSystem=strict, ReadWritePaths=[stateDir]) confines
      # writes regardless, so this isn't reopening the Discord live-chat
      # risk — just scoping cron to what it's actually used for.
      config =
        hermesConfig
        // {
          platform_toolsets = {
            discord = ["safe" "cronjob"];
            cron = ["safe" "terminal" "file"];
          };
        };
    };

    # Upstream's activation script writes the rendered config to
    # cli-config.yaml, but load_config() (hermes_cli/config.py) only reads
    # config.yaml for installed-package runs — cli-config.yaml is a
    # source-tree-only fallback. Without this, the gateway silently runs on
    # DEFAULT_CONFIG (OpenRouter + claude-opus-4.6) instead of our config.
    # Also installs SOUL.md (see soulMd above) — upstream's setup script has
    # no hook for it, so it's not something `config` can express.
    system.activationScripts."hermes-agent-config-symlink" = {
      deps = ["hermes-agent-setup"];
      text = ''
        ln -sf cli-config.yaml ${config.services.hermes-agent.stateDir}/.hermes/config.yaml
        install -o ${config.services.hermes-agent.user} -g ${config.services.hermes-agent.group} -m 0640 -D ${pkgs.writeText "hermes-soul-md" soulMd} ${config.services.hermes-agent.stateDir}/.hermes/SOUL.md

        # Let cron jobs (platform_toolsets.cron = terminal+file) read the
        # actual git repo — e.g. nixpkgs-update-check needs .tack/pins.lock.json.
        # Projects/ and Projects/stellyrland are already 755; only your home
        # dir itself (700) blocks the path. ACL instead of chmod: grants the
        # hermes user execute-only (traverse, not list/read) on your home dir
        # specifically — it still can't `ls` anything else in there, only walk
        # through a path it's told about. Not exposed to Discord's live-chat
        # toolset, which stays "safe"+"cronjob" only — this only reaches
        # scheduled cron runs, which you create yourself.
        #
        # Symlinked at ~/Projects/stellyrland (i.e. stateDir/Projects/..., since
        # HOME=stateDir for this service) rather than under workingDirectory —
        # job instructions reference the literal path "~/Projects/stellyrland",
        # same as it resolves on your own machine, so it has to land there for
        # "~" to mean the same thing for both.
        ${pkgs.acl}/bin/setfacl -m u:${config.services.hermes-agent.user}:x ${host.homeDir}
        install -d -o ${config.services.hermes-agent.user} -g ${config.services.hermes-agent.group} ${config.services.hermes-agent.stateDir}/Projects
        ln -sfn ${host.homeDir}/Projects/stellyrland ${config.services.hermes-agent.stateDir}/Projects/stellyrland
      '';
    };

    home-manager.users.${host.username} = {pkgs, ...}: let
      # Hermes' browser tool shells out to this CLI (github:vercel-labs/agent-browser).
      # No nixpkgs package exists upstream, so we pull the prebuilt static (musl) binary
      # directly — it has no dynamic deps, so it runs unpatched on NixOS, unlike the
      # default glibc build. Check for updates: ai-check-updates
      agentBrowserVersion = "0.31.1";
      agentBrowser = pkgs.stdenvNoCC.mkDerivation {
        pname = "agent-browser";
        version = agentBrowserVersion;
        src = pkgs.fetchurl {
          url = "https://github.com/vercel-labs/agent-browser/releases/download/v${agentBrowserVersion}/agent-browser-linux-musl-x64";
          hash = "sha256-t0kqPgDlJ5C/+9KQDDmSZeaoBZgnb4n7iy+/oxTMjSI=";
        };
        dontUnpack = true;
        installPhase = ''
          install -Dm755 $src $out/bin/agent-browser
        '';
      };
    in {
      home.packages = [
        inputs.nix-hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.hermes-agent
        agentBrowser
        pkgs.chromium
        pkgs.mcp-nixos
      ];

      home.shellAliases.ai-check-updates = ''echo "agent-browser:" && curl -s https://api.github.com/repos/vercel-labs/agent-browser/releases/latest | grep tag_name'';

      # Same model wiring as the gateway service above, rendered for `hermes
      # chat` run interactively as yourself. Must be named config.yaml —
      # cli-config.yaml is only read as a fallback when run from inside Hermes'
      # own source tree, not from ~/.hermes.
      # mcp_servers.nixos: same mcp-nixos server already used by Zed (modules/dev/ai-tools.nix,
      # modules/dev/zed.nix) — gives the agent NixOS/nixpkgs-aware lookups via MCP instead of
      # guessing from training data.
      home.file.".hermes/config.yaml".text = builtins.toJSON (hermesConfig
        // {
          mcp_servers.nixos = {
            command = "${pkgs.mcp-nixos}/bin/mcp-nixos";
            args = [];
          };
        });

      # AGENT_BROWSER_EXECUTABLE_PATH: point the browser tool's CLI at nixpkgs' own
      # Chromium, skipping agent-browser's default Playwright-Chromium auto-download
      # (a generic glibc build that won't run unpatched on NixOS).
      home.file.".hermes/.env".text = ''
        OPENAI_API_KEY=ollama
        AGENT_BROWSER_EXECUTABLE_PATH=${pkgs.chromium}/bin/chromium
      '';

      home.file.".hermes/SOUL.md".text = soulMd;
    };
  };
}
