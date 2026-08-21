{ inputs, pkgs }:
let
  bridgeGpgUnlock = pkgs.writeShellScript "hermes-bridge-gpg-unlock" ''
    set -eu
    ${pkgs.gnupg}/bin/gpgconf --kill gpg-agent || true
    ${pkgs.gnupg}/bin/gpgconf --launch gpg-agent
    keygrips=$(${pkgs.gnupg}/bin/gpg --with-keygrip --list-secret-keys --with-colons 'Hermes Proton Bridge' | ${pkgs.gawk}/bin/awk -F: '$1 == "grp" { print $10 }')
    test -n "$keygrips"
    while IFS= read -r keygrip; do
      test -n "$keygrip" || continue
      ${pkgs.gnupg}/libexec/gpg-preset-passphrase --preset "$keygrip" < /run/secrets/hermes-bridge-gpg-passphrase
    done <<< "$keygrips"
  '';

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
    text = "pinentry-program ${pkgs.pinentry-curses}/bin/pinentry-curses\nallow-preset-passphrase\n";
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
        ExecStartPre = [ "${bridgeGpgUnlock}" ];
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
