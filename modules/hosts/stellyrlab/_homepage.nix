_:
{
  services.homepage-dashboard = {
    listenPort = 8082;
    allowedHosts = "stellyrlab.tailb15b96.ts.net:8082,localhost:8082,127.0.0.1:8082";
    settings = {
      title = "stellyrlab";
      background = "https://raw.githubusercontent.com/iStellanova/Stellyrland/assets/wallpapers/wallpaper.png";
    };
    services = [
      {
        "Services" = [
          {
            "Hermes" = {
              href = "https://stellyrlab.tailb15b96.ts.net";
              description = "Hermes Agent";
              siteMonitor = "https://stellyrlab.tailb15b96.ts.net";
            };
          }
          {
            "Navidrome" = {
              href = "http://stellyrlab.tailb15b96.ts.net:4533";
              description = "Music Server";
              siteMonitor = "http://stellyrlab.tailb15b96.ts.net:4533";
            };
          }
          {
            "Binary cache" = {
              href = "http://stellyrlab.tailb15b96.ts.net:5000";
              description = "Nix Binary Cache";
              siteMonitor = "http://stellyrlab.tailb15b96.ts.net:5000";
            };
          }
        ];
      }
      {
        "Operations" = [
          {
            "Overnight Builds" = {
              href = "https://github.com/iStellanova/Stellyrland";
              description = "Daily x86 NixOS Builds";
              widget = {
                type = "customapi";
                url = "http://127.0.0.1:9118/status";
                refreshInterval = 60000;
                mappings = [
                  {
                    field = "status";
                    label = "Result";
                    format = "text";
                  }
                  {
                    field = "updated";
                    label = "Updated";
                    format = "text";
                  }
                ];
              };
            };
          }
        ];
      }
    ];
  };

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 8082 ];
}
