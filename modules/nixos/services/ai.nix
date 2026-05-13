{ config, lib, pkgs, identity, ... }:

{
  options.aspects.services.ai = {
    enable = lib.mkEnableOption "Local AI services (Ollama + Open WebUI)";
    acceleration = lib.mkOption {
      type = lib.types.enum [ "rocm" "cuda" "none" ];
      default = "rocm";
      description = "Hardware acceleration for Ollama. Defaults to ROCm for AMD GPUs.";
    };
    models = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "llama3:8b" # Fast, high quality
        "llama3:70b" # Deep intelligence (fits in 24GB VRAM)
        "nomic-embed-text" # Required for local RAG/Memory in Open WebUI
      ];
      description = "List of models to pre-load into Ollama.";
    };
  };

  config = lib.mkIf config.aspects.services.ai.enable {
    # Ollama Service - The engine
    services.ollama = {
      enable = true;
      package = if config.aspects.services.ai.acceleration == "rocm" then pkgs.ollama-rocm
                else if config.aspects.services.ai.acceleration == "cuda" then pkgs.ollama-cuda
                else pkgs.ollama;
      # ROCm package for 7900 XTX support
      rocmOverrideGfx = "11.0.0"; # RDNA3 target
      loadModels = config.aspects.services.ai.models;
    };
    systemd.services.ollama.wantedBy = lib.mkForce [ ];

    # Open WebUI - The interface & Memory manager
    services.open-webui = {
      enable = true;
      port = 8080;
      environment = {
        OLLAMA_API_BASE_URL = "http://127.0.0.1:11434";
        # Disable telemetry for privacy
        WEBUI_AUTH = "false"; # Local only, so we can skip the login if desired
        ENABLE_RAG = "true";
        ENABLE_SEARCH = "true";
        # Force environment variables to win over DB settings
        ENABLE_PERSISTENT_CONFIG = "False";

        # Web Search Settings (using local SearXNG)
        ENABLE_RAG_WEB_SEARCH = "true";
        RAG_WEB_SEARCH_ENGINE = "searxng";
        SEARXNG_QUERY_URL = "http://127.0.0.1:8888/search?q=<query>";
      };
    };
    systemd.services.open-webui.wantedBy = lib.mkForce [ ];

    # Correctly extend the PATH for the service via systemd
    systemd.services.open-webui.path = [ pkgs.ffmpeg ];

    # SearXNG - Privacy metasearch engine for the AI to use
    services.searx = {
      enable = true;
      settings = {
        server = {
          port = 8888;
          bind_address = "127.0.0.1";
          secret_key = "ai-research-secret";
        };
        search = {
          safe_search = 1;
        };
        engines = [
          { name = "google"; engine = "google"; shortcut = "go"; }
          { name = "duckduckgo"; engine = "duckduckgo"; shortcut = "ddg"; }
          { name = "wikipedia"; engine = "wikipedia"; shortcut = "wp"; }
        ];
      };
    };
    systemd.services.searx.wantedBy = lib.mkForce [ ];

    # Ensure the user has access to the render/video groups for GPU acceleration
    users.users.${identity.name}.extraGroups = [ "video" "render" ];

    # Add a friendly alias for checking status
    environment.shellAliases = {
      ai-logs = "journalctl -u ollama --since '1 hour ago' -f";
      ai-webui-logs = "journalctl -u open-webui --since '1 hour ago' -f";
      ai-models = "ollama list";
      ai-on = "sudo systemctl start ollama open-webui searx";
      ai-off = "sudo systemctl stop ollama open-webui searx";
    };
  };
}
