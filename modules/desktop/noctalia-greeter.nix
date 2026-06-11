{
  sn,
  inputs ? {},
  ...
}: {
  sn.desktop = {includes = [sn.noctalia-greeter];};

  flake-file.inputs.noctalia-greeter.url = "github:noctalia-dev/noctalia-greeter";

  sn.noctalia-greeter.nixos = {...}: {
    imports = [inputs.noctalia-greeter.nixosModules.default];

    programs.noctalia-greeter = {
      enable = true;
      greeter-args = "--session hyprland";
    };

    systemd.tmpfiles.rules = [
      "d /persist/var/lib/noctalia-greeter 0750 greeter greeter -"
    ];
  };
}
