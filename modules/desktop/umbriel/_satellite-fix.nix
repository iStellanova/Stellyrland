{ pkgs, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      # TODO(umbriel): remove when xwayland-satellite includes Supreeeme/xwayland-satellite#494.
      xwayland-satellite = prev.xwayland-satellite.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [
          # Fix Steam dropdowns closing instantly and Unity Add Component not focusing.
          (final.fetchpatch2 {
            url = "https://github.com/Supreeeme/xwayland-satellite/compare/9d51b59ff3c38464e7654096c9b10a8052a26b25.diff?full_index=1";
            hash = "sha256-VpdX1V9N0pkBJoRuqTwZiwJeW4h200TdsPN75xnBSEk=";
          })
        ];
      });
    })
  ];

  # The upstream module defaults to its flake package, which uses its own nixpkgs.
  # Use the host package so the overlay above supplies the patched satellite.
  programs.umbriel.package = pkgs.umbriel;
}
