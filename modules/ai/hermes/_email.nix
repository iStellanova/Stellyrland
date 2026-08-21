{ inputs, pkgs }:
let
  # TODO(proton-mcp): drop Python 3.13 when upstream imapclient/Proton MCP supports the host Python version; rerun the real Bridge STARTTLS inbox read first.
  protonMcp = pkgs.python313Packages.buildPythonApplication {
    pname = "proton-mcp";
    version = "0.1.0";
    pyproject = true;
    src = inputs.proton-mcp;
    build-system = [ pkgs.python313Packages.hatchling ];
    dependencies = with pkgs.python313Packages; [
      imapclient
      mcp
    ];
    doCheck = false;
  };
in
{
  packages = [
    pkgs.protonmail-bridge
    pkgs.pass
    pkgs.gnupg
    pkgs.pinentry-curses
    protonMcp
  ];

  files.".gnupg/gpg-agent.conf" = {
    text = "pinentry-program ${pkgs.pinentry-curses}/bin/pinentry-curses\n";
    force = true;
  };

  services = {
    protonmail-bridge = {
      Unit = {
        Description = "Proton Mail Bridge";
        After = [ "network-online.target" ];
        Wants = [ "network-online.target" ];
      };
      Service = {
        Environment = [ "PASSWORD_STORE_DIR=%h/.password-store-bridge" ];
        ExecStart = "${pkgs.protonmail-bridge}/bin/protonmail-bridge --noninteractive";
        Restart = "on-failure";
        RestartSec = 5;
      };
      Install.WantedBy = [ "default.target" ];
    };
  };

  hermesConfig = {
    mcp_servers.proton_mail = {
      command = "${protonMcp}/bin/proton-mcp";
      timeout = 90;
      connect_timeout = 30;
      sampling.enabled = false;
      tools.include = [
        "mail_list_folders"
        "mail_search"
        "mail_get_message"
      ];
    };
  };
}
