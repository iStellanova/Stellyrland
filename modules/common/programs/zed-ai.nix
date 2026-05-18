{ config, lib, pkgs, identity, ... }:
let
  aiEnabled = config.aspects.services.ai.enable or false;
  zedEnabled = config.aspects.programs.zed.enable or false;

  # Create a dedicated python environment for the Echo bridge with required dependencies.
  # This provides a stable 'python3' binary in the user's path without hardcoding store paths.
  echoPython = pkgs.python3.withPackages (ps: with ps; [
    psutil
    requests
    beautifulsoup4
    psycopg2
    textual
    rich
  ]);
in
{
  config = lib.mkIf (aiEnabled && zedEnabled) {
    home-manager.users.${identity.name} = {
      home.packages = [ echoPython ];

      programs.zsh.shellAliases = {
        echo-cli = "nix develop '/home/${identity.name}/Projects/Project Echo' -c python '/home/${identity.name}/Projects/Project Echo/scripts/echo_prime_tui.py'";
        echo-bridge = "nix develop '/home/${identity.name}/Projects/Project Echo' -c python '/home/${identity.name}/Projects/Project Echo/scripts/echo-bridge.py'";
      };

      programs.zed-editor.userSettings = {
        "agent" = {
          "default_model" = {
            "provider" = "OllamaMemoryBridge";
            "model" = "devstral-small-2:24b";
          };
          "inline_assistant_model" = {
            "provider" = "OllamaMemoryBridge";
            "model" = "devstral-small-2:24b";
          };
        };
        "assistant" = {
          "default_model" = {
            "provider" = "OllamaMemoryBridge";
            "model" = "devstral-small-2:24b";
          };
          "version" = 2;
          "dock" = "right";
        };
        "language_models" = {
          "openai_compatible" = {
            "OllamaMemoryBridge" = {
              "api_url" = "http://127.0.0.1:8000/v1";
              "api_key" = "ollama";
              "available_models" = [
                {
                  "name" = "devstral-small-2:24b";
                  "max_tokens" = 32768;
                }
                {
                  "name" = "devstral:24b";
                  "max_tokens" = 32768;
                }
                {
                  "name" = "qwen3:8b";
                  "max_tokens" = 32768;
                }
                {
                  "name" = "qwen3.6:27b";
                  "max_tokens" = 32768;
                }
              ];
            };
          };
          "google" = {
            "api_key" = null;
          };
          "anthropic" = {
            "api_key" = null;
          };
        };
        "context_servers" = {
          "Gemini CLI" = {
            "command" = "gemini";
            "args" = [
              "--acp"
              "--yolo"
            ];
          };
        };
        "agent_servers" = {
          "gemini" = {
            "type" = "custom";
            "command" = "gemini";
            "args" = [
              "--acp"
              "--yolo"
            ];
          };
        };
        "chat_panel" = {
          "dock" = "right";
        };
      };
    };
  };
}
