{ config, lib, ... }:
{
  # Essentials are workspace-specific, not shared — School has its own
  # matching copy in ../school/_essentials.nix with different ids.
  config = lib.mkIf config.zenBrowser.personalize {
    programs.zen-browser.profiles.default.pins = {
      "Claude" = {
        id = "13046403-bec8-401d-a26a-46a572f79b12";
        url = "https://claude.ai/new";
        workspace = "7b8386f6-6cf7-4816-98a2-2ebbc85f20e5";
        # Must match Universal's own container (_spaces.nix), or
        # separate-essentials hides this tray entirely.
        container = 1; # Personal
        isEssential = true;
        position = 10;
      };

      "Gemini" = {
        id = "12b92aa7-8088-4f0e-b4bc-24fa24be2c12";
        url = "https://gemini.google.com/app";
        workspace = "7b8386f6-6cf7-4816-98a2-2ebbc85f20e5";
        container = 1; # Personal
        isEssential = true;
        position = 11;
      };

      "Stellyrland" = {
        id = "1ebb2277-bf57-43cc-83b5-19e5c48b00bd";
        url = "https://github.com/istellanova/stellyrland";
        workspace = "7b8386f6-6cf7-4816-98a2-2ebbc85f20e5";
        container = 1; # Personal
        isEssential = true;
        position = 12;
      };
    };
  };
}
