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
            "provider" = "ollama";
            "model" = "Echo:latest";
          };
          "inline_assistant_model" = {
            "provider" = "ollama";
            "model" = "Echo:latest";
          };
        };
        "assistant" = {
          "default_model" = {
            "provider" = "ollama";
            "model" = "Echo:latest";
          };
          "version" = 2;
          "dock" = "right";
        };
        "language_models" = {
          "ollama" = {
            "api_url" = "http://127.0.0.1:11434";
            "available_models" = [
              { "name" = "Echo:latest"; }
              { "name" = "qwen2.5-coder:32b"; }
              { "name" = "deepseek-r1:70b"; }
              { "name" = "qwen2.5:14b"; }
              { "name" = "qwen2.5:32b"; }
              { "name" = "echo-personalized:latest"; }
              { "name" = "llama3.1:8b"; }
            ];
          };
          "openai_api_compatible" = {
            "ollama" = {
              "api_url" = "http://127.0.0.1:11434/v1";
              "available_models" = [
                { "name" = "Echo:latest"; }
                { "name" = "qwen2.5-coder:32b"; }
                { "name" = "deepseek-r1:70b"; }
                { "name" = "qwen2.5:14b"; }
                { "name" = "qwen2.5:32b"; }
                { "name" = "echo-personalized:latest"; }
                { "name" = "llama3.1:8b"; }
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
          "Project Echo" = {
            "command" = "nix";
            "args" = [
              "develop"
              "/home/${identity.name}/Projects/Project Echo"
              "-c"
              "python"
              "/home/${identity.name}/Projects/Project Echo/scripts/echo-zed.py"
            ];
            "env" = {
              "ECHO_STATE_DIR" = "/home/${identity.name}/Projects/Project Echo";
            };
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
          "echo" = {
            "type" = "custom";
            "command" = "nix";
            "args" = [
              "develop"
              "/home/${identity.name}/Projects/Project Echo"
              "-c"
              "python"
              "/home/${identity.name}/Projects/Project Echo/scripts/echo-zed.py"
            ];
            "env" = {
              "ECHO_STATE_DIR" = "/home/${identity.name}/Projects/Project Echo";
            };
          };
        };
        "chat_panel" = {
          "dock" = "right";
        };
      };
    };
  };
}
