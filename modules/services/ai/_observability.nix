{
  config,
  lib,
  ...
}: let
  cfg = config.services.ai;
in {
  config = lib.mkIf cfg.observability.enable {
    # Prometheus scrapes LiteLLM's /metrics endpoint.
    # LiteLLM exposes per-model request counts, latency histograms, and token usage
    # when the prometheus callback is active (set in _litellm.nix).
    services.prometheus = {
      enable = true;
      port = cfg.observability.prometheusPort;
      # Prometheus stores data in /var/lib/prometheus2 — declare persistence so
      # historical data survives reboots on this impermanent system.
      stateDir = "prometheus2";
      scrapeConfigs = [
        {
          job_name = "litellm";
          scrape_interval = "15s";
          static_configs = [{targets = ["127.0.0.1:${toString cfg.litellm.port}"];}];
          metrics_path = "/metrics";
        }
      ];
    };

    # Grafana for dashboard visualization of Prometheus data.
    services.grafana = lib.mkIf cfg.observability.grafana {
      enable = true;
      settings = {
        server.http_addr = "127.0.0.1";
        server.http_port = cfg.observability.grafanaPort;
        # Allow unauthenticated read access locally — no external exposure
        auth.disable_login_form = false;
        "auth.anonymous".enabled = true;
        "auth.anonymous".org_role = "Viewer";
      };
      provision.datasources.settings.datasources = [
        {
          name = "Prometheus";
          type = "prometheus";
          url = "http://127.0.0.1:${toString cfg.observability.prometheusPort}";
          isDefault = true;
        }
      ];
    };

    # Keep Prometheus data across reboots
    systemd.tmpfiles.rules = [
      "d /var/lib/prometheus2 0750 prometheus prometheus - -"
    ];
  };
}
