_: {
  config = {
    # Home Manager Yazi Settings
    flake.modules.homeManager.yazi = {
      osConfig,
      pkgs,
      lib,
      ...
    }: let
      isDarwin = osConfig ? system.defaults;
      openCmd =
        if isDarwin
        then ''/usr/bin/open "%s"''
        else ''${lib.getExe' pkgs.xdg-utils "xdg-open"} "%s"'';
    in
      lib.mkIf (osConfig ? aspects.programs.yazi && osConfig.aspects.programs.yazi.enable) {
        programs.yazi = {
          enable = true;
          enableZshIntegration = true;
          shellWrapperName = "y";

          plugins = {
            inherit (pkgs.yaziPlugins) git rsync chmod full-border;
          };

          initLua = ''
            require("full-border"):setup({ type = ui.Border.ROUNDED })
            require("git"):setup()
          '';

          keymap = {
            manager.prepend_keymap = [
              {
                on = ["R"];
                run = "plugin rsync";
                desc = "Copy files using rsync";
              }
              {
                on = ["c" "m"];
                run = "plugin chmod";
                desc = "Chmod on selected files";
              }
            ];
          };

          settings = {
            manager = {
              show_hidden = true;
              show_symlink = true;
              sort_by = "alphabetical";
              sort_sensitive = true;
              sort_dir_first = true;
              sort_translit = true;
              linemode = "size";
            };

            preview = {
              tab_size = 4;
              image_filter = "lanczos3";
              image_quality = 90;
            };

            opener = {
              play = [
                {
                  run = ''${lib.getExe pkgs.mpv} "%s"'';
                  orphan = true;
                  for = "unix";
                }
              ];
              view = [
                {
                  run = ''${lib.getExe pkgs.viu} "%s"'';
                  block = true;
                  for = "unix";
                }
              ];
              edit = [
                {
                  run = ''$EDITOR "%s"'';
                  block = true;
                  for = "unix";
                }
              ];
              hex = [
                {
                  run = ''${lib.getExe pkgs.hexyl} "%s"'';
                  block = true;
                  for = "unix";
                }
              ];
              exfil = [
                {
                  run = ''${lib.getExe pkgs.ouch} d "%s"'';
                  block = true;
                  for = "unix";
                }
              ];
              book = [
                {
                  run = ''${lib.getExe pkgs.epr} "%s"'';
                  block = true;
                  for = "unix";
                }
              ];
              open = [
                {
                  run = openCmd;
                  orphan = true;
                  for = "unix";
                }
              ];
            };

            open.rules = [
              {
                mime = "video/*";
                use = ["play" "open"];
              }
              {
                mime = "audio/*";
                use = ["play" "open"];
              }
              {
                mime = "image/*";
                use = ["view" "open"];
              }
              {
                mime = "application/epub+zip";
                use = ["book" "edit"];
              }
              {
                mime = "application/pdf";
                use = ["open"];
              }
              {
                mime = "application/{octet-stream,x-executable,x-sharedlib,x-pie-executable}";
                use = ["hex" "open"];
              }
              {
                mime = "application/{zip,rar,7z*,tar*,x-tar,x-bzip*,x-gzip,x-xz}";
                use = ["exfil" "open"];
              }
              {
                mime = "text/*";
                use = ["edit" "open"];
              }
              {
                mime = "*";
                use = ["edit" "open"];
              }
            ];

            plugin.prepend_fetchers = [
              {
                id = "git";
                name = "*";
                run = "git";
              }
              {
                id = "git";
                name = "*/";
                run = "git";
              }
            ];

            input.cursor_blink = true;
          };
        };

        home.packages = with pkgs;
          [
            imagemagick
            poppler-utils
            ffmpegthumbnailer
            fd
            viu
            hexyl
            ouch
            epr
            mpv
          ]
          ++ lib.optionals (!isDarwin) [xdg-utils];
      };

    # NixOS Options Declaration
    flake.modules.nixos.yazi = {lib, ...}: {
      options.aspects.programs.yazi.enable = lib.mkEnableOption "Yazi file manager";
    };

    # Darwin Options Declaration
    flake.modules.darwin.yazi = {lib, ...}: {
      options.aspects.programs.yazi.enable = lib.mkEnableOption "Yazi file manager";
    };
  };
}
