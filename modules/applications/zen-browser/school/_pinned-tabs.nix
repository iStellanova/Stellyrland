{ config, lib, ... }:
{
  config = lib.mkIf config.zenBrowser.personalize {
    programs.zen-browser.profiles.default.pins = {
      "Brightspace - Home" = {
        id = "7400c18a-bf1a-4c29-a6a8-97ca0925569a";
        url = "https://purdue.brightspace.com/d2l/home/6822";
        workspace = "65e30ccb-7994-4ca4-a3a8-0d38c8df648d";
        position = 200;
      };

      "Brightspace - Calendar" = {
        id = "0e112ebc-3c2a-4223-ba4e-c1e1439776d9";
        url = "https://purdue.brightspace.com/d2l/le/calendar/6822";
        workspace = "65e30ccb-7994-4ca4-a3a8-0d38c8df648d";
        position = 201;
      };

      "Physics" = {
        id = "1a069e8c-a701-442c-858b-1487f5e35e5e";
        isGroup = true;
        isFolderCollapsed = true;
        folderIcon = "chrome://browser/skin/zen-icons/selectable/rocket.svg";
        workspace = "65e30ccb-7994-4ca4-a3a8-0d38c8df648d";
        position = 300;

        pins."PHYS 22100-02" = {
          id = "9ca09cf3-655d-4b51-93a5-6e8501189317";
          url = "https://purdue.brightspace.com/d2l/home/1617797";
          position = 301;
        };

        pins."PHYS 22100-01" = {
          id = "fe34aded-abc7-43cc-93f5-16f0fdeb85d2";
          url = "https://purdue.brightspace.com/d2l/home/1617796";
          position = 302;
        };
      };
    };
  };
}
