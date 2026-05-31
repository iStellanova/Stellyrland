{
  config,
  lib,
  ...
}: let
  cfg = config.services.ai;
in {
  config = lib.mkIf cfg.openWebUI.enable {
    services.open-webui = {
      enable = true;
      port = cfg.openWebUI.port;
      environment = {
        # Route through Letta when available, LiteLLM otherwise
        OPENAI_API_BASE_URL = "http://127.0.0.1:${toString (
          if cfg.letta.enable
          then cfg.letta.port
          else cfg.litellm.port
        )}/v1";
        OPENAI_API_KEY = "local-only";
        WEBUI_AUTH = "false";
      };
    };

    systemd.services.open-webui.wantedBy = lib.mkIf cfg.onDemand (lib.mkForce []);
  };
}
