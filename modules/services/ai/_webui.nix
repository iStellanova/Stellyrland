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
        # Route through the router (when enabled) or proxy — never raw Letta
        # (Letta's /v1/chat/completions returns content:null; the proxy translates it)
        OPENAI_API_BASE_URL = "http://127.0.0.1:${toString (
          if cfg.letta.enable && cfg.router.enable
          then cfg.router.port
          else if cfg.letta.enable
          then cfg.letta.port + 1
          else cfg.litellm.port
        )}/v1";
        OPENAI_API_KEY = "local-only";
        WEBUI_AUTH = "false";
      };
    };

    systemd.services.open-webui.wantedBy = lib.mkIf cfg.onDemand (lib.mkForce []);
  };
}
