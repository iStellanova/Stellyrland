{
  sn,
  inputs,
  ...
}: let
  ollamaUrl = "http://localhost:11434/v1";

  # Shared between the gateway service and the interactive CLI config written
  # via home-manager — same models either way.
  hermesConfig = {
    # Named so cron jobs (and anything else that pins a provider rather than
    # inferring one from model.base_url) have something real to resolve.
    # hermes_cli/runtime_provider.py: bare "custom" only resolves when it
    # matches a named providers/custom_providers entry — without this, a
    # cron job created with no explicit provider falls through to the
    # global default (openrouter) instead of our Ollama endpoint, since
    # cronjob_tools.py's per-job model pinning only captures
    # (provider, model), never base_url. key_env reuses the dummy
    # OPENAI_API_KEY=ollama already set below — Ollama ignores it, but
    # Hermes' OpenAI client hard-requires a non-empty key regardless.
    #
    # Registered under both "custom" and "ollama": the model doesn't
    # reliably use our literal config key when it pins a per-job provider
    # override (cronjob action=update) — it's guessed "openrouter" (from a
    # stale memory note) and "ollama" (intuitive, matching its own "ran
    # successfully with Ollama!" summary) on different occasions, both
    # failing with "Unknown provider" since only "custom" was registered.
    # Aliasing both names to the same endpoint makes this tolerant of
    # whichever one it reaches for next, instead of fixing one guess at a
    # time.
    providers.custom = {
      api = ollamaUrl;
      key_env = "OPENAI_API_KEY";
    };
    providers.ollama = {
      api = ollamaUrl;
      key_env = "OPENAI_API_KEY";
    };

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

    # Lets the homeManager profile's `hermes chat` (run as you) read/write the
    # gateway's memories/ dir (see the setgid install below) so both share
    # MEMORY.md/USER.md instead of keeping separate notes per profile.
    users.users.${host.username}.extraGroups = ["hermes"];

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
        # Ollama ignores bearer auth, but Hermes' OpenAI client and its custom-endpoint
        # credential checks (delegation, auxiliary tasks) both hard-require a non-empty
        # key when a custom base_url is set. This dummy value satisfies that check globally.
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
      package = inputs.nix-hermes-agent.packages.${pkgs.system}.hermes-agent.overrideAttrs (old: {
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
      # (cron/scheduler.py's _resolve_cron_enabled_toolsets), which otherwise
      # defaults wide open to the full hermes-cron set (terminal, file,
      # browser, code_execution, delegate_task, ...) — silently undoing the
      # Discord scoping the moment a job actually fires. Upstream always
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

    # Files the gateway creates (e.g. into shared-memories/ below) land
    # group-writable instead of the systemd default 0022, which would give
    # your local `hermes chat` read-only access to the gateway's writes —
    # one-way sharing instead of two-way.
    systemd.services.hermes-agent.serviceConfig.UMask = "0002";

    # Upstream's activation script writes the rendered config to
    # cli-config.yaml, but load_config() (hermes_cli/config.py) only reads
    # config.yaml for installed-package runs — cli-config.yaml is a
    # source-tree-only fallback. Without this, the gateway silently runs on
    # DEFAULT_CONFIG (OpenRouter + claude-opus-4.6) instead of our config.
    # Also installs SOUL.md (see soulMd above) — upstream's setup script has
    # no hook for it, so it's not something `config` can express.
    #
    # memories/ is symlinked to a sibling dir OUTSIDE .hermes rather than a
    # subdir within it: .hermes itself is 0700 (Hermes' own default — locks
    # down session/state data), and several files inside it (state.db,
    # cron/, sessions/) are independently world-readable, only safe today
    # because nothing but `hermes` can traverse into .hermes at all. Opening
    # .hermes's own permissions for group access would leak all of that to
    # your `hermes` group membership — way more than "just share memories".
    # /var/lib/hermes itself (the stateDir, not .hermes) is already 0750
    # with group hermes, so a sibling needs no loosening of anything
    # sensitive. `chmod` runs unconditionally (not just `install -d -m`,
    # which only sets mode when it creates the dir — a no-op, silently, on
    # a dir that already exists from a prior activation).
    system.activationScripts."hermes-agent-config-symlink" = {
      deps = ["hermes-agent-setup"];
      text = ''
        ln -sf cli-config.yaml ${config.services.hermes-agent.stateDir}/.hermes/config.yaml
        install -o ${config.services.hermes-agent.user} -g ${config.services.hermes-agent.group} -m 0640 -D ${pkgs.writeText "hermes-soul-md" soulMd} ${config.services.hermes-agent.stateDir}/.hermes/SOUL.md
        install -d -o ${config.services.hermes-agent.user} -g ${config.services.hermes-agent.group} ${config.services.hermes-agent.stateDir}/shared-memories
        chmod 2775 ${config.services.hermes-agent.stateDir}/shared-memories
        if [ -d ${config.services.hermes-agent.stateDir}/.hermes/memories ] && [ ! -L ${config.services.hermes-agent.stateDir}/.hermes/memories ]; then
          cp -an ${config.services.hermes-agent.stateDir}/.hermes/memories/. ${config.services.hermes-agent.stateDir}/shared-memories/ 2>/dev/null || true
          rm -rf ${config.services.hermes-agent.stateDir}/.hermes/memories
        fi
        ln -sfn ../shared-memories ${config.services.hermes-agent.stateDir}/.hermes/memories
      '';
    };
  };

  sn.hermes.homeManager = {
    config,
    pkgs,
    ...
  }: let
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
    # Shared with the gateway (modules/ai/hermes.nix's sn.hermes.nixos) — see
    # the setgid shared-memories/ install there. Points at the sibling dir
    # directly, not .hermes/memories — .hermes itself stays 0700 (gateway
    # session/state data), only this one directory is opened to the group
    # you're now a member of (also set up there).
    home.file.".hermes/memories".source = config.lib.file.mkOutOfStoreSymlink "/var/lib/hermes/shared-memories";

    home.packages = [
      inputs.nix-hermes-agent.packages.${pkgs.system}.hermes-agent
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
    # HERMES_MANAGED: without this, hermes_cli/config.py's _secure_dir() chmods
    # any directory it touches back to 0700 on every run (its normal behavior
    # for an unmanaged ~/.hermes) — since shared-memories/ is now the same
    # physical directory the gateway uses, that silently undid the gateway's
    # 2775 setgid setup every time a local `hermes` command ran. The gateway's
    # systemd service already sets this (nix-hermes-agent's own module); the
    # local profile needs it too so both sides agree to leave permissions
    # alone and let the Nix-managed activation script own them instead.
    home.file.".hermes/.env".text = ''
      OPENAI_API_KEY=ollama
      AGENT_BROWSER_EXECUTABLE_PATH=${pkgs.chromium}/bin/chromium
      HERMES_MANAGED=true
    '';

    home.file.".hermes/SOUL.md".text = soulMd;
  };
}
