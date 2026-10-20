{ inputs, pkgs, config, lib, ... }:
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
      ];
  };
}
