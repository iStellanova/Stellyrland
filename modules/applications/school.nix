_:
let
  osShared = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      zoom-us
      super-productivity
    ];
  };

  darwinSchool = { pkgs, ... }: {
    environment.systemPackages = [
      pkgs.zoom-us
      (pkgs.super-productivity.overrideAttrs (old: {
        # TODO: Remove once Super Productivity accepts macOS 26 iconutil's encoded output.
        postPatch = (old.postPatch or "") + ''
          substituteInPlace tools/generate-mac-icon.js \
            --replace-fail '    compareIconsets(ICONSET_DIR, extractedIconset);' '    // iconutil encoding is platform-dependent.'
        '';
      }))
    ];
  };
in
{
  flake.modules.nixos.school = osShared;
  flake.modules.darwin.school = darwinSchool;
}
