{ config, lib, ... }:
{
  config = lib.mkIf config.zenBrowser.personalize {
    programs.zen-browser.profiles.default.pins = {
      "YouTube" = {
        id = "accf6051-50c6-488d-9652-20bb7ce91a20";
        url = "https://youtube.com/";
        workspace = "7b8386f6-6cf7-4816-98a2-2ebbc85f20e5";
        position = 400;
      };

      "Dyno" = {
        id = "9b9d899b-6300-43ad-914b-4d61d2e8f265";
        url = "https://dyno.gg/";
        workspace = "7b8386f6-6cf7-4816-98a2-2ebbc85f20e5";
        position = 401;
      };

      "Nix" = {
        id = "9d2ef2b1-648f-4b38-a726-7b778b4d4fcf";
        isGroup = true;
        isFolderCollapsed = true;
        folderIcon = "chrome://browser/skin/zen-icons/selectable/code.svg";
        workspace = "7b8386f6-6cf7-4816-98a2-2ebbc85f20e5";
        position = 402;

        pins."dendritic-design-with-flake-parts" = {
          id = "123ea623-5965-49a5-9a0a-713946760f46";
          url = "https://github.com/Doc-Steve/dendritic-design-with-flake-parts";
          position = 403;
        };

        pins."FlakeHub" = {
          id = "7d5b4b89-c52a-4f8e-a60d-8fcc29e8747b";
          url = "https://flakehub.com/";
          position = 404;
        };

        pins."tack" = {
          id = "6eb7a5d1-e6ba-4730-a8ff-4ea958813194";
          url = "https://github.com/manic-systems/tack";
          position = 405;
        };

        pins."flake-file" = {
          id = "30c188cb-9e5a-4c99-b2d3-23adca958fb5";
          url = "https://github.com/denful/flake-file";
          position = 406;
        };
      };
    };
  };
}
