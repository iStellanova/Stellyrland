{ config, lib, ... }:
{
  # Attrset keys are suffixed "(School)" because `pins` is one flat attrset
  # across the whole profile — an identical key in both this file and
  # universal/_essentials.nix would merge into one pin with two conflicting
  # `id`s, instead of declaring two separate pins. `title` overrides the key
  # back to the plain display name Zen shows.
  config = lib.mkIf config.zenBrowser.personalize {
    programs.zen-browser.profiles.default.pins = {
      "Claude (School)" = {
        title = "Claude";
        id = "3c391612-7999-433d-8ada-08be24d47955";
        url = "https://claude.ai/new";
        workspace = "65e30ccb-7994-4ca4-a3a8-0d38c8df648d";
        # Must match School's own container (_spaces.nix), or
        # separate-essentials hides this tray entirely.
        container = 2; # Work
        isEssential = true;
        position = 10;
      };

      "Gemini (School)" = {
        title = "Gemini";
        id = "2cd61a69-a9bd-43d6-b9e2-88fc049e4e9f";
        url = "https://gemini.google.com/app";
        workspace = "65e30ccb-7994-4ca4-a3a8-0d38c8df648d";
        container = 2; # Work
        isEssential = true;
        position = 11;
      };

      "Stellyrland (School)" = {
        title = "Stellyrland";
        id = "c85296e0-d624-4b63-b519-421edb7856a8";
        url = "https://github.com/istellanova/stellyrland";
        workspace = "65e30ccb-7994-4ca4-a3a8-0d38c8df648d";
        container = 2; # Work
        isEssential = true;
        position = 12;
      };
    };
  };
}
