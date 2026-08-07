{ stellxiePackage, interactiveToolsets }:
{
  hermesConfig.platform_toolsets.discord = interactiveToolsets;

  service = {
    Unit = {
      Description = "Stellxie Hermes Discord gateway";
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
    };
    Service = {
      EnvironmentFile = "/run/secrets/hermes-discord.env";
      ExecStart = "${stellxiePackage}/bin/hermes gateway run";
      Restart = "always";
      RestartSec = 5;
    };
    Install.WantedBy = [ "default.target" ];
  };
}
