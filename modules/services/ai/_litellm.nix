{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.ai;

  litellmConfig = (pkgs.formats.yaml {}).generate "litellm-config.yaml" {
    model_list = [
      {
        model_name = "face";
        litellm_params = {
          model = "openai/${cfg.models.face}";
          api_base = "http://127.0.0.1:11434/v1";
          api_key = "none";
        };
      }
      {
        model_name = "core";
        litellm_params = {
          model = "openai/${cfg.models.core}";
          api_base = "http://127.0.0.1:11434/v1";
          api_key = "none";
        };
      }
      {
        model_name = "code";
        litellm_params = {
          model = "openai/${cfg.models.code}";
          api_base = "http://127.0.0.1:11434/v1";
          api_key = "none";
        };
      }
      {
        model_name = cfg.models.embed;
        litellm_params = {
          model = "ollama/${cfg.models.embed}";
          api_base = "http://127.0.0.1:11434";
        };
      }
    ];
    router_settings = {
      routing_strategy = "least-busy";
      fallbacks = [{face = ["core"];}];
      num_retries = 3;
    };
    litellm_settings = lib.optionalAttrs cfg.observability.enable {
      # Expose /metrics endpoint for Prometheus scraping
      callbacks = ["prometheus"];
    };
  };
in {
  systemd.services.litellm = {
    description = "LiteLLM Model Router";
    after = ["ollama.service"];
    requires = ["ollama.service"];
    wantedBy =
      if cfg.onDemand
      then []
      else ["multi-user.target"];
    serviceConfig = {
      Type = "simple";
      User = cfg.user;
      ExecStart = "${pkgs.litellm}/bin/litellm --config ${litellmConfig} --port ${toString cfg.litellm.port} --host 127.0.0.1";
      Restart = "on-failure";
      RestartSec = "5s";
      PrivateTmp = true;
      NoNewPrivileges = true;
    };
  };
}
