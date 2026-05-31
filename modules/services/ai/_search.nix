{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.ai;
in {
  config = lib.mkIf cfg.searx.enable {
    services.searx = {
      enable = true;
      package = pkgs.searxng;
      settings = {
        server = {
          port = cfg.searx.port;
          bind_address = "127.0.0.1";
          secret_key = "stellyrland-local-ai";
        };
        search.safe_search = 0;
        ui.default_theme = "simple";
      };
    };

    systemd.services.searx.wantedBy = lib.mkIf cfg.onDemand (lib.mkForce []);
  };
}
