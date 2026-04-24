{ config, lib, ... }:
{
  options.aspects.programs.fastfetch.enable = lib.mkEnableOption "Fastfetch";
  config = lib.mkIf config.aspects.programs.fastfetch.enable {
    home-manager.users.stellanova = {
      programs.zsh.shellAliases.pf = "fastfetch";
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

    };
  };
}
