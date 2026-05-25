_: {
  # Home Manager Zed AI Settings
  flake.modules.homeManager.zed-ai = {
    osConfig,
    pkgs,
    ...
  }: let
    # Create a dedicated python environment for the Echo bridge with required dependencies.
    # This provides a stable 'python3' binary in the user's path without hardcoding store paths.
    echoPython = pkgs.python3.withPackages (ps:
      with ps; [
        psutil
        requests
        beautifulsoup4
        psycopg2
        textual
        rich
      ]);
  in {
    home.packages = [echoPython];

    programs.zsh.shellAliases = let
      echoPath = osConfig.services.ai.echoProjectPath;
    in {
      echo-cli = "nix develop '${echoPath}' -c python '${echoPath}/scripts/echo_prime_tui.py'";
      echo-bridge = "nix develop '${echoPath}' -c python '${echoPath}/scripts/echo-bridge.py'";
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
    };
  };
}
