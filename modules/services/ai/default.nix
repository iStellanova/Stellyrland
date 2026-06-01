{inputs, ...}: {
  # NixOS Cognitive AI Stack
  # Sub-modules (_*.nix) are imported below; this file owns all options.services.ai.* definitions.
  flake.modules.nixos.ai = {lib, ...}: {
    imports = [
      ./_ollama.nix
      ./_litellm.nix
      ./_letta.nix
      ./_proxy.nix
      ./_wave3.nix
      ./_consolidation.nix
      ./_observability.nix
      ./_memory.nix
      ./_search.nix
      ./_webui.nix
      ./_shell.nix
    ];

    options.services.ai = {
      user = lib.mkOption {
        type = lib.types.str;
        default = "stellanova";
      };

      onDemand = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Start services manually via ai-up rather than on boot.";
      };

      models = {
        loadOnStartup = lib.mkOption {
          type = lib.types.bool;
          default = true;
        };

        face = lib.mkOption {
          type = lib.types.str;
          default = "qwen3:8b";
          description = "L1 — Fast conversational model. (~5GB VRAM)";
        };

        core = lib.mkOption {
          type = lib.types.str;
          default = "qwen3.6:27b";
          description = "L2 — Deep reasoning. (~18GB VRAM)";
        };

        code = lib.mkOption {
          type = lib.types.str;
          default = "devstral-small-2:24b";
          description = "L3 — Coding agent. (~14GB VRAM)";
        };

        embed = lib.mkOption {
          type = lib.types.str;
          default = "nomic-embed-text";
          description = "Embedding model used by Letta for archival memory search.";
        };

        draft = lib.mkOption {
          type = lib.types.str;
          default = "qwen3:1.7b";
          description = "Draft model for speculative decoding alongside face. Must share the same tokenizer. (~1GB VRAM)";
        };

        vision = lib.mkOption {
          type = lib.types.str;
          default = "minicpm-v:8b";
          description = "Vision model for image analysis via the analyze_image tool. (~5GB VRAM)";
        };
      };

      sandbox.enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Firejail sandboxing for the coder agent's code execution tool.";
      };

      consolidation = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Run periodic memory consolidation to compact agent conversation histories.";
        };
        schedule = lib.mkOption {
          type = lib.types.str;
          default = "Sun *-*-* 03:00:00";
          description = "systemd OnCalendar expression for when to run consolidation.";
        };
      };

      observability = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Enable Prometheus metrics scraping for LiteLLM.";
        };
        prometheusPort = lib.mkOption {
          type = lib.types.port;
          default = 9090;
        };
        grafana = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Enable Grafana for dashboard visualization of Prometheus data.";
        };
        grafanaPort = lib.mkOption {
          type = lib.types.port;
          default = 3001;
          description = "Port for Grafana (3001 to avoid collision with other services).";
        };
      };

      litellm.port = lib.mkOption {
        type = lib.types.port;
        default = 4000;
      };

      letta = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
        };
        port = lib.mkOption {
          type = lib.types.port;
          default = 8283;
        };
      };

      openWebUI = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
        };
        port = lib.mkOption {
          type = lib.types.port;
          default = 8080;
        };
      };

      qdrant.port = lib.mkOption {
        type = lib.types.port;
        default = 6333;
        description = "Qdrant HTTP port. gRPC runs on port + 1.";
      };

      searx = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
        };
        port = lib.mkOption {
          type = lib.types.port;
          default = 8888;
        };
      };

      oterm.enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };

      bootstrap.rules = lib.mkOption {
        type = lib.types.listOf (lib.types.submodule {
          options = {
            rule = lib.mkOption {
              type = lib.types.str;
            };
            priority = lib.mkOption {
              type = lib.types.int;
              default = 0;
            };
          };
        });
        default = [
          {
            rule = "Never open a response by disclaiming, explaining, or qualifying your memory. Simply recall and use what you know.";
            priority = 10;
          }
        ];
      };

      postgresql.databaseName = lib.mkOption {
        type = lib.types.str;
        default = "ai_memory";
      };
    };

    config = {
      # Letta derivation — built from uv.lock via uv2nix using captured flake inputs.
      # Only evaluated when something references pkgs.letta (lazy).
      nixpkgs.overlays = [
        (_final: prev: let
          workspace = inputs.uv2nix.lib.workspace.loadWorkspace {
            workspaceRoot = inputs.letta-src;
          };
          overlay = workspace.mkPyprojectOverlay {
            sourcePreference = "wheel";
          };
          # Overrides for sdist packages missing build-system declarations or file collisions.
          # `prev` here is the pyproject-nix python set; `nixpkgsPrev` is captured from the
          # outer nixpkgs overlay scope to inject packages not in Letta's uv.lock.
          buildSystemFixes = _final: pyPrev: {
            demjson3 = pyPrev.demjson3.overrideAttrs (old: {
              nativeBuildInputs = (old.nativeBuildInputs or []) ++ [pyPrev.setuptools];
            });
            llama-cloud-services = pyPrev.llama-cloud-services.overrideAttrs (old: {
              postFixup =
                (old.postFixup or "")
                + ''
                  rm -f $out/bin/llama-parse
                '';
            });
          };

          pythonSet =
            (prev.callPackage inputs.pyproject-nix.build.packages {
              python = prev.python311;
            })
            .overrideScope (
              prev.lib.composeManyExtensions [
                inputs.pyproject-build-systems.overlays.wheel
                overlay
                buildSystemFixes
              ]
            );
        in {
          letta = pythonSet.mkVirtualEnv "letta-env" (workspace.deps.default
            // {
              asyncpg = [];
              pgvector = [];
              pg8000 = [];
            });
          # Expose source tree so _letta.nix can run alembic migrations from it
          inherit (inputs) letta-src;
        })
      ];
    };
  };

  # oterm declarative config — face model as default (direct Ollama, no memory overhead)
  flake.modules.homeManager.ai = {
    osConfig,
    lib,
    ...
  }: let
    cfg = osConfig.services.ai;
    proxyPort = toString (cfg.letta.port + 1);
  in {
    # oterm: direct Ollama TUI for quick model testing
    home.file.".local/share/oterm/config.json" = lib.mkIf cfg.oterm.enable {
      text = builtins.toJSON {
        theme = "textual-dark";
        splash-screen = true;
        model = cfg.models.face;
      };
    };

    # aichat: OpenAI-compatible TUI wired to Letta for memory-enhanced chat
    home.file.".config/aichat/config.yaml" = lib.mkIf cfg.letta.enable {
      text = ''
        model: letta:echo
        clients:
          - type: openai
            name: letta
            api_base: http://127.0.0.1:${proxyPort}/v1
            api_key: local-only
            models:
              - name: echo
                max_input_tokens: 32768
              - name: coder
                max_input_tokens: 32768
              - name: core
                max_input_tokens: 32768
      '';
    };
  };
}
