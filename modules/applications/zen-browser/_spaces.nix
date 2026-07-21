{ config, lib, ... }:
{
  config = lib.mkIf config.zenBrowser.personalize {
    programs.zen-browser.profiles.default = {
      # Removes any space not declared here, including whatever blank
      # default Zen auto-creates on a profile's first real launch.
      spacesForce = true;

      spaces = {
        "Universal" = {
          id = "7b8386f6-6cf7-4816-98a2-2ebbc85f20e5";
          icon = "chrome://browser/skin/zen-icons/selectable/planet.svg";
          container = 1; # Personal
          position = 1000;
        };

        # Reuses the id of the profile's original, never-renamed default
        # space, renaming it in place instead of creating a duplicate.
        "School" = {
          id = "65e30ccb-7994-4ca4-a3a8-0d38c8df648d";
          icon = "chrome://browser/skin/zen-icons/selectable/book.svg";
          container = 2; # Work
          position = 1001;
        };
      };
    };
  };
}
