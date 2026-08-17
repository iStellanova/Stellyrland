{
  flake.modules.nixos.obs =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      options.myModules.programs.obs.nvidia = lib.mkEnableOption "OBS NVIDIA/CUDA support";

      config = {
        nixpkgs.overlays = [
          (_final: prev: {
            obs-studio =
              (prev.obs-studio.override (
                {
                  browserSupport = false;
                }
                // lib.optionalAttrs config.myModules.programs.obs.nvidia {
                  cudaSupport = true;
                  stdenv = prev.stdenvAdapters.withCFlags [
                    "-O3"
                    "-march=native"
                    "-fomit-frame-pointer"
                    "-flto=auto"
                    "-ffat-lto-objects"
                    "-fdebug-types-section"
                    "-femit-struct-debug-baseonly"
                    "-g1"
                    "-gno-column-info"
                    "-gno-variable-location-views"
                  ] prev.stdenv;
                }
              )).overrideAttrs
                (old: {
                  buildInputs = builtins.filter (p: p != prev.libvlc) old.buildInputs;
                  cmakeFlags = old.cmakeFlags ++ [
                    (lib.cmakeBool "ENABLE_VLC" false)
                  ];

                  preFixup =
                    let
                      wrapperLibraries = [
                        prev.libx11
                        prev.libGL
                      ];
                    in
                    ''
                      qtWrapperArgs+=(
                        --prefix LD_LIBRARY_PATH : "$out/lib:${lib.makeLibraryPath wrapperLibraries}"
                        ''${gappsWrapperArgs[@]}
                      )
                    ''
                    + lib.optionalString (old.passthru.browserSupport or false) ''
                      rm $out/lib/obs-plugins/libcef.so
                      rm $out/lib/obs-plugins/libEGL.so
                      rm $out/lib/obs-plugins/libGLESv2.so
                      rm $out/lib/obs-plugins/libvk_swiftshader.so
                      rm $out/lib/obs-plugins/libvulkan.so.1
                      rm $out/lib/obs-plugins/chrome-sandbox
                    '';
                });
          })
        ];

        programs.obs-studio = {
          enable = true;
          enableVirtualCamera = true;
          plugins = with pkgs.obs-studio-plugins; [
            obs-pipewire-audio-capture
            obs-vaapi
          ];
        };
      };
    };

  flake.modules.darwin.obs = {
    homebrew.casks = [ "obs" ];
  };
}
