{ inputs, ... }:
{
  flake-file.inputs.noctalia-greeter = {
    url = "github:noctalia-dev/noctalia-greeter";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos.noctalia-greeter =
    {
      host,
      lib,
      pkgs,
      ...
    }:
    {
      imports = [ inputs.noctalia-greeter.nixosModules.default ];

      programs.noctalia-greeter = {
        enable = true;
        settings = {
          session.default = "hyprland";
          user.default = host.username;
          idle.timeout = 300;
          output = {
            name = lib.head ((host.monitorPriority or [ ]) ++ [ "" ]);
            width = 3440;
            height = 1440;
          };
          cursor = {
            theme = "Bibata-Modern-Ice";
            size = 16;
            path = "${pkgs.bibata-cursors}/share/icons";
          };
          keyboard.layout = "us";
          appearance.password_style = "random";
        };
      };

      systemd.tmpfiles.rules = lib.optional (host.persistence or false
      ) "d /persist/var/lib/noctalia-greeter 0750 greeter greeter -";
    };

  flake.modules.finix.noctalia-greeter =
    {
      host,
      inputs,
      lib,
      modules,
      pkgs,
      ...
    }:
    let
      format = pkgs.formats.toml { };
      package = inputs.noctalia-greeter.packages.${pkgs.stdenv.hostPlatform.system}.default;
      configFile = format.generate "greeter.toml" {
        session.default = "hyprland";
        user.default = host.username;
        idle.timeout = 300;
        output = {
          name = lib.head ((host.monitorPriority or [ ]) ++ [ "" ]);
          width = 3440;
          height = 1440;
        };
        cursor = {
          theme = "Bibata-Modern-Ice";
          size = 16;
          path = "${pkgs.bibata-cursors}/share/icons";
        };
        keyboard.layout = "us";
        appearance.password_style = "random";
      };
    in
    {
      imports = [ modules.greetd ];

      environment.systemPackages = [ package ];
      services.greetd = {
        enable = true;
        settings.default_session = {
          command = "${package}/bin/noctalia-greeter-session";
          user = "greeter";
        };
      };
      finit.tmpfiles.rules = [
        "d /var/lib/noctalia-greeter 0750 greeter greeter -"
        "L+ /var/lib/noctalia-greeter/greeter.toml - - - - ${configFile}"
      ];
      preservation.preserveAt."/persist".directories = [ "/var/lib/noctalia-greeter" ];
    };
}
