{ config, lib, ... }:
{
  options.aspects.programs.fastfetch.enable = lib.mkEnableOption "Fastfetch";
  config = lib.mkIf config.aspects.programs.fastfetch.enable {
    home-manager.users.stellanova = {
      programs.fastfetch = {
        enable = true;
        settings = {
          "$schema" = "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json";
          logo = { };
          display = {
            separator = " ";
          };
          modules = [
            "break"
            {
              type = "title";
              keyWidth = 10;
            }
            "break"
            {
              type = "os";
              key = " ";
              keyColor = "34";
            }
            {
              type = "kernel";
              key = " ";
              keyColor = "34";
            }
            {
              type = "packages";
              key = " ";
              keyColor = "34";
            }
            {
              type = "shell";
              key = " ";
              keyColor = "34";
            }
            {
              type = "terminal";
              key = " ";
              keyColor = "34";
            }
            {
              type = "de";
              key = "󰧨 ";
              keyColor = "34";
            }
            {
              type = "wm";
              key = " ";
              keyColor = "34";
            }
            {
              type = "wmtheme";
              key = "󰉼 ";
              keyColor = "34";
            }
            {
              type = "cursor";
              key = " ";
              keyColor = "34";
            }
            {
              type = "terminalfont";
              key = " ";
              keyColor = "34";
            }
            {
              type = "cpu";
              key = "󰻠 ";
              keyColor = "34";
            }
            {
              type = "gpu";
              key = "󰢮 ";
              keyColor = "34";
            }
            {
              type = "disk";
              key = "󰋊 ";
              keyColor = "34";
            }
            {
              type = "memory";
              key = "󰍛 ";
              keyColor = "34";
            }
            {
              type = "uptime";
              key = " ";
              keyColor = "34";
            }
            {
              type = "datetime";
              format = "{1}-{3}-{11}";
              key = " ";
              keyColor = "34";
            }
            {
              type = "command";
              key = "󰃶 ";
              keyColor = "34";
              text = "echo $(( ($(date +%s) - $(stat -c %W /)) / 86400 )) days";
            }
            "break"
          ];
        };
      };

      xdg.configFile."fastfetch/ough.jsonc".text = ''
        {
            "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
            "logo": {
                "source": "$HOME/.config/fastfetch/ough.txt",
                "padding": {
                        "top": 1,
                "right": 2
                },
            },
            "display": {
                "separator": " "
            },
            "modules": [
            "break",
            "break",
                      {
                    "type": "title",
                    "keyWidth": 10
                },
                "break",
                {
                    "type": "os",
                    "key": " ",
                    "keyColor": "34",
                    "format": "Ough Linux"
                },
                {
                    "type": "kernel",
                    "key": " ",
                    "keyColor": "34",
                },
                {
                    "type": "packages",
                    "key": " ",
                    "keyColor": "34",
                },
                {
                    "type": "shell",
                    "key": " ",
                    "keyColor": "34",
                },
                {
                    "type": "terminal",
                    "key": " ",
                    "keyColor": "34",
                },
                {
                    "type": "de",
                    "key": "󰧨 ",
                    "keyColor": "34",
                },

                {
                    "type": "wm",
                    "key": " ",
                    "keyColor": "34",
                },
                {
                    "type": "wmtheme",
                    "key": "󰉼 ",
                    "keyColor": "34",
                },
                {
                    "type": "cursor",
                    "key": " ",
                    "keyColor": "34",
                },
                {
                    "type": "terminalfont",
                    "key": " ",
                    "keyColor": "34",
                },
                {
                    "type": "cpu",
                    "key": "󰻠 ",
                    "keyColor": "34",
                },
                {
                    "type": "gpu",
                    "key": "󰢮 ",
                    "keyColor": "34",
                },
                {
                    "type": "disk",
                    "key": "󰋊 ",
                    "keyColor": "34",
                },
                {
                    "type": "memory",
                    "key": "󰍛 ",
                    "keyColor": "34"
                },
                {
                    "type": "uptime",
                    "key": " ",
                    "keyColor": "34",
                },
                {
                    "type": "datetime",
                    "format": "{1}-{3}-{11}",
                    "key": " ",
                    "keyColor": "34",
                },
                "break"
            ]
        }
      '';

      xdg.configFile."fastfetch/small.jsonc".text = ''
        {
            "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
            "logo": {
                "source": "arch_small",
                "padding": {
                        "top": 1
                },
            },
            "display": {
                "separator": "  "
            },
            "modules": [
                "break",
                "title",
                {
                    "type": "os",
                    "key": "os    ",
                    "keyColor": "33"
                },
                {
                    "type": "kernel",
                    "key": "kernel",
                    "keyColor": "33"
                },
                {
                    "type": "host",
                    "format": "{5} {1}",
                    "key": "host  ",
                    "keyColor": "33"
                },
                {
                    "type": "packages",
                    "key": "pkgs  ",
                    "keyColor": "33"
                },
                {
                    "type": "uptime",
                    "format": "{2}h {3}m",
                    "key": "uptime",
                    "keyColor": "33"
                },
                {
                    "type": "memory",
                    "key": "memory",
                    "keyColor": "33"
                },
                "break"
            ]
        }
      '';

      xdg.configFile."fastfetch/ough.txt".text = ''
        ⠀⠀⠀⠀⠀⠀⠀⠀⣠⣤⣦⣤⣄⡀⠀⠀⠀⠀⢀⣀⣀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⠀⣰⠟⠙⠀⠀⠀⠈⢻⡆⠀⣴⠞⠋⠉⠉⠙⠳⣦⡀⠀⠀⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⢸⡛⠂⠀⠀⠀⠀⠀⠈⣿⣾⠋⠀⠀⠀⠀⠀⠀⠈⣿⡄⠀⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⣽⠁⠀⠀⠀⠀⠀⠀⠀⣽⢇⠀⠀⠀⠀⠀⠀⠀⠀⢸⡇⠀⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⢰⣿⠄⠀⠀⠀⠀⠀⠀⠐⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⢺⡇⠀⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⢨⡟⠀⠀⠀⠀⠀⠀⠀⢸⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⠇⠀⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠈⣿⠀⠀⠀⠀⠀⠀⠀⢸⡇⠀⠀⠀⠀⠀⠀⠀⠀⢠⡿⠀⠀⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⣿⡆⠀⠀⢀⣀⣀⡀⢸⣇⠀⠀⠀⠀⠀⠀⠀⢀⣾⠃⠀⠀⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⣘⡟⠰⠛⠛⠉⠙⠉⠈⠃⠀⠀⠀⠀⠀⠀⢰⣾⡟⠚⢶⣄⠀⠀⠀⠀⠀
        ⠀⠀⠀⣤⡾⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⡁⠀⢀⡬⢹⡇⠀⠀⠀⠀
        ⠀⠀⣴⠟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣷⠀⠚⢷⣼⡷⠀⠀⠀⠀
        ⠀⣼⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢙⣷⠀⠀⠘⢿⣷⠀⠀⠀
        ⢸⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣇⠀⠀⠀⢹⣧⠀⠀
        ⣿⢣⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⡏⣡⠀⠀⠀⠻⣧⠀
        ⣿⡾⡿⠖⠀⠀⠀⠀⠀⠀⠀⠀⢀⣶⣿⣤⠀⠀⠀⠀⠀⠀⠀⣼⡇⠃⠀⠀⠀⠀⢹⣇
        ⠹⣧⡀⠀⠀⠰⣦⣸⣶⠄⠀⠀⠸⡿⠿⠇⠀⠀⠀⠀⠀⠀⢢⡿⠅⠀⠀⠀⠀⠀⠀⣿
        ⠀⠈⠻⣦⣒⠸⠛⠻⠖⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣼⠟⠁⠀⠀⠀⠀⣄⠀⠀⣾
        ⠀⠀⠀⠈⢙⣷⢶⣤⣀⣀⠀⠀⠀⠀⠀⠀⠀⣀⣤⡶⠟⠁⠀⠀⠀⠀⠀⣼⢏⣠⣾⠟
        ⠀⠀⠀⢀⣾⠃⠀⠀⠉⠛⠛⠻⠶⠶⠶⠶⠞⠋⠁⠀⠀⠀⠀⠀⠀⣰⡾⠛⠛⠉⠀⠀
        ⠀⠀⠀⠘⣿⠀⠀⠀⠀⠀⢲⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⣠⡾⠏⠀⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠻⣧⡀⠀⠀⣡⣿⠛⠻⠶⣾⠀⠀⠀⠀⠀⠀⠈⢾⡟⠆⠀⠀⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⠉⠛⠛⠛⠋⠁⠀⠀⠀⢿⣦⠀⠀⠀⠀⠀⣠⡾⠁⠀⠀⠀⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⣶⣤⣀⣦⣴⡟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀
      '';
    };
  };
}
