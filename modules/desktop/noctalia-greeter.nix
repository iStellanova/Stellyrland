{ inputs, ... }:
{
  flake-file.inputs.noctalia-greeter = {
    url = "github:noctalia-dev/noctalia-greeter";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos.noctalia-greeter = { ... }: {
    imports = [ inputs.noctalia-greeter.nixosModules.default ];

    programs.noctalia-greeter = {
      enable = true;
      greeter-args = "--session hyprland";
      settings = {
        cursor = {
          theme = "Bibata-Modern-Ice";
          size = 16;
        };
        keyboard.layout = "us";
        appearance.password_style = "random";
      };
    };

    systemd.tmpfiles.rules = [
      "d /persist/var/lib/noctalia-greeter 0750 greeter greeter -"
    ];
  };
}
