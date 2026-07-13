_: {
  flake.modules.nixos.media = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      ffmpegthumbnailer
      imv
      pavucontrol
      nicotine-plus
    ];
  };

  flake.modules.darwin.media =
    { pkgs, ... }:
    {
      homebrew.casks = [
        "background-music"
        "vlc"
      ];
      environment.systemPackages = [ pkgs.mpv ];

      # TODO: revisit — mpv-unwrapped's link step crashes cctools' ld64 with
      # "Trace/BPT trap: 5" (exit 133) on aarch64-darwin, reproduced across
      # the last two nixpkgs pins. Confirmed upstream: nixpkgs#540682, fixed
      # in nixpkgs#540762 (switches the darwin link to lld, disables Swift
      # bridging PCH) which isn't merged yet. Drop once it lands and this
      # pin's nixpkgs includes it.
      nixpkgs.overlays = [
        (final: prev: {
          mpv-unwrapped = prev.mpv-unwrapped.overrideAttrs (old: {
            nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [
              final.makeBinaryWrapper
              final.llvmPackages.lld
            ];
            env = (old.env or { }) // {
              NIX_SWIFTFLAGS_COMPILE = "-disable-bridging-pch";
              NIX_CFLAGS_LINK = "-fuse-ld=lld";
            };
          });
        })
      ];
    };

  flake.modules.homeManager.media =
    {
      pkgs,
      ...
    }:
    {
      home.packages = with pkgs; [
        ani-cli
        ffmpeg
        mpv
      ];
    };
}
