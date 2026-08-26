{
  inputs,
  pkgs,
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.zenBrowser.personalize {
    programs.zen-browser.profiles.default.extensions.packages =
      let
        rycee = inputs.nur.legacyPackages.${pkgs.stdenv.hostPlatform.system}.repos.rycee.firefox-addons;
      in
      [
        rycee.ublock-origin
        rycee.sponsorblock
        rycee.proton-pass

        # AMO-only; fixedExtid preserves the installed addon identity.
        (pkgs.fetchFirefoxAddon {
          name = "xcancel-redirect";
          url = "https://addons.mozilla.org/firefox/downloads/file/4480430/xcancelredirect-1.2.xpi";
          sha256 = "sha256-sCMdx9SiZxynTPclc++fQ7jHNNbu4EV6vjbhDwHk7SA=";
          fixedExtid = "{99f59414-6b9c-4ba2-8706-4b018bc10bdc}";
        })
      ];
  };
}
