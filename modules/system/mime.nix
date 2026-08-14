_: {
  flake.modules.nixos.mime = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.xdg-utils ];
  };

  flake.modules.homeManager.mime =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      # Category -> .desktop file(s) actually installed on this host. The
      # mime-type mapping below is universal; only these bindings vary.
      options.mimeDefaultApps = lib.mkOption {
        type = lib.types.attrsOf (lib.types.listOf lib.types.str);
        default = { };
      };

      config = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
        xdg.mimeApps = {
          enable = true;
          defaultApplications =
            let
              apps = config.mimeDefaultApps;
              mimeTypes = {
                browser = [
                  "x-scheme-handler/http"
                  "x-scheme-handler/https"
                  "x-scheme-handler/chrome"
                  "text/html"
                  "application/x-extension-htm"
                  "application/x-extension-html"
                  "application/x-extension-shtml"
                  "application/xhtml+xml"
                  "application/x-extension-xhtml"
                  "application/x-extension-xht"
                ];
                discord = [ "x-scheme-handler/discord" ];
                fileManager = [ "inode/directory" ];
                editor = [
                  "text/plain"
                  "text/markdown"
                  "text/x-script.python"
                  "application/json"
                  "application/x-shellscript"
                ];
                imageViewer = [
                  "image/jpeg"
                  "image/png"
                  "image/gif"
                  "image/webp"
                  "image/tiff"
                  "image/bmp"
                  "image/avif"
                  "image/svg+xml"
                ];
                musicPlayer = [
                  "audio/mpeg"
                  "audio/flac"
                  "audio/ogg"
                  "audio/wav"
                  "audio/x-vorbis+ogg"
                  "audio/aac"
                  "audio/mp4"
                  "audio/x-flac"
                ];
                pdfViewer = [ "application/pdf" "application/x-pdf" ];
                videoPlayer = [
                  "video/mp4"
                  "video/x-matroska"
                  "video/webm"
                  "video/avi"
                  "video/quicktime"
                  "video/x-msvideo"
                  "video/mpeg"
                ];
              };
            in
            lib.concatMapAttrs (
              category: types: lib.genAttrs types (_: apps.${category} or [ ])
            ) mimeTypes;
        };
      };
    };
}
