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
          session.default = "umbriel";
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
}
