_: {
  flake.modules.homeManager.zed-ai = {
    osConfig,
    lib,
    ...
  }: let
    cfg = osConfig.services.ai;
    lettaBase = "http://127.0.0.1:${toString (cfg.letta.port + 1)}/v1";
  in
    lib.mkIf cfg.letta.enable {
      programs.zed-editor.userSettings = {
        # Code agent as default — IDE sessions use devstral via Letta
        "agent" = {
          "default_model" = {
            "provider" = "letta";
            "model" = "code";
          };
          "inline_assistant_model" = {
            "provider" = "letta";
            "model" = "code";
          };
        };
        "assistant" = {
          "default_model" = {
            "provider" = "letta";
            "model" = "code";
          };
        };
        "language_models" = {
          "openai_compatible" = {
            "letta" = {
              "api_url" = lettaBase;
              "api_key" = "local-only";
              "available_models" = [
                {
                  "name" = "code";
                  "display_name" = "Code (devstral via Letta)";
                  "max_tokens" = 32768;
                }
                {
                  "name" = "coder";
                  "display_name" = "Coder (face via Letta)";
                  "max_tokens" = 32768;
                }
                {
                  "name" = "echo";
                  "display_name" = "Echo (face via Letta)";
                  "max_tokens" = 32768;
                }
                {
                  "name" = "core";
                  "display_name" = "Core (reasoning via Letta)";
                  "max_tokens" = 32768;
                }
              ];
            };
          };
        };
      };
    };
}
