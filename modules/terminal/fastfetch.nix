{ sn, ... }: {
  sn.terminal = {
    includes = [ sn.fastfetch ];
  };

  sn.fastfetch.homeManager =
    {
      host,
      lib,
      ...
    }:
    {
      programs.zsh.shellAliases.pf = "fastfetch";
      programs.zsh.initContent = lib.mkAfter ''
        if [[ $(tty) == *"pts"* ]]; then
          fastfetch
        fi
      '';
      programs.fastfetch = {
        enable = true;
        settings = {
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
              type = "command";
              key = " ";
              keyColor = "34";
              text = "size=$(nix path-info -Sh /run/current-system | awk '{print $2}') && echo \"$(nix-store -qR /run/current-system | wc -l | xargs) Paths, \${size}B\"";
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
              text =
                if host.class == "darwin" then
                  "echo $(( ($(date +%s) - $(stat -f %B /)) / 86400 )) days"
                else
                  "echo $(( ($(date +%s) - $(stat -c %W /)) / 86400 )) days";
            }
            "break"
          ];
        };
      };
    };
}
