{
  sn,
  ...
}:
{
  sn.gaming = {
    includes = [ sn.vr ];
  };

  sn.vr.nixos =
    { pkgs, ... }:
    let
      spaceCalibrator = pkgs.stdenv.mkDerivation {
        pname = "openvr-space-calibrator-linux";
        # Tried pinning this via flake-file/tack instead of a hardcoded rev+hash
        # (see git history), but tack's submodule handling computes a NAR hash
        # that doesn't match what `fetchTree` resolves at build time for this
        # repo's `lib/imgui` submodule -- a real mismatch, not a caching fluke.
        # Falling back to a plain fetchFromGitHub pin until that's sorted upstream.
        # No releases/tags exist; this is the latest commit as of 2026-07-07.
        # Check for updates: space-calibrator-check-updates
        version = "unstable-2025-12-03";

        src = pkgs.fetchFromGitHub {
          owner = "xi-ve";
          repo = "openvr-space-calibrator-linux";
          rev = "28e3f83f7bc9808f145fac03ff8a8e455ab211fe";
          fetchSubmodules = true;
          hash = "sha256-WOMZ6BFLFAI6MhPpy7R/emy/MtGGySO7tCxS5IatUTY=";
        };

        nativeBuildInputs = with pkgs; [
          cmake
          pkg-config
          autoAddDriverRunpath
        ];
        buildInputs = with pkgs; [
          openvr
          eigen
          glfw
          libGL
          libX11
          libXrandr
          libXinerama
          libXcursor
          libXi
        ];

        # Upstream passes user-controlled strings straight to ImGui::Text(),
        # which -Werror=format-security (a nixpkgs default hardening flag) rejects.
        hardeningDisable = [ "format" ];

        cmakeFlags = [
          "-DOPENVR_INCLUDE_DIR=${pkgs.openvr}/include/openvr"
          "-DOPENVR_LIB_DIR=${pkgs.openvr}/lib"
        ];

        # Upstream's CMakeLists has no install() target; scripts/install.sh does
        # this copy by hand, so mirror it into $out instead of a mutable ~/.steam.
        installPhase = ''
          runHook preInstall

          driverOut="$out/share/space-calibrator/driver_01spacecalibrator"
          install -Dm755 lib/driver_01spacecalibrator.so "$driverOut/bin/linux64/driver_01spacecalibrator.so"
          install -Dm755 bin/space-calibrator "$driverOut/bin/linux64/space-calibrator"
          install -Dm644 manifest.vrmanifest "$driverOut/bin/linux64/manifest.vrmanifest"
          install -Dm644 actions.json "$driverOut/bin/linux64/actions.json"
          install -Dm644 ../driver_01spacecalibrator/driver.vrdrivermanifest "$driverOut/driver.vrdrivermanifest"
          cp -r ../driver_01spacecalibrator/resources "$driverOut/resources"

          runHook postInstall
        '';

        meta.mainProgram = "space-calibrator";
      };

      registerScript = pkgs.writeShellScriptBin "space-calibrator-register" ''
        set -euo pipefail
        driverDir="${spaceCalibrator}/share/space-calibrator/driver_01spacecalibrator"

        steamRoot=""
        for candidate in "$HOME/.local/share/Steam" "$HOME/.steam/steam" "$HOME/.steam/root"; do
          if [ -d "$candidate" ]; then
            steamRoot="$candidate"
            break
          fi
        done

        if [ -z "$steamRoot" ]; then
          echo "Could not find a Steam install directory (checked ~/.local/share/Steam, ~/.steam/steam, ~/.steam/root)." >&2
          exit 1
        fi

        # SteamVR may live in any configured library folder, not just steamRoot itself.
        libraryFolders=("$steamRoot")
        libraryFoldersVdf="$steamRoot/steamapps/libraryfolders.vdf"
        if [ -f "$libraryFoldersVdf" ]; then
          while IFS= read -r extraPath; do
            libraryFolders+=("$extraPath")
          done < <(${pkgs.gnugrep}/bin/grep -oP '"path"\s*"\K[^"]+' "$libraryFoldersVdf" || true)
        fi

        for base in "''${libraryFolders[@]}"; do
          vrpathreg="$base/steamapps/common/SteamVR/bin/linux64/vrpathreg"
          if [ -x "$vrpathreg" ]; then
            LD_LIBRARY_PATH="$(dirname "$vrpathreg")''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}" "$vrpathreg" adddriver "$driverDir"
            echo "Registered Space Calibrator driver with SteamVR: $driverDir"
            echo "Restart SteamVR to activate."
            exit 0
          fi
        done

        echo "Could not find vrpathreg in any Steam library folder; is SteamVR installed?" >&2
        exit 1
      '';
    in
    {
      # Valve/HTC udev rules for Index controllers and Vive trackers (their USB
      # dongles). Base stations aren't USB devices -- they just power on and
      # sync with each other, no udev rules needed.
      hardware.steam-hardware.enable = true;
      programs.alvr = {
        enable = true;
        openFirewall = true;
      };

      environment.systemPackages = [
        pkgs.android-tools
        spaceCalibrator
        registerScript
      ];
    };

  sn.vr.homeManager =
    { lib, ... }:
    {
      home.activation.seedAlvrSession = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        sessionFile="$HOME/.config/alvr/session.json"
        if [ ! -e "$sessionFile" ]; then
          $DRY_RUN_CMD mkdir -p "$(dirname "$sessionFile")"
          $DRY_RUN_CMD install -m644 ${./alvr-session-seed.json} "$sessionFile"
        fi
      '';

      programs.zsh.shellAliases = {
        space-calibrator-check-updates = ''
          echo "pinned commit: 28e3f83f7bc9808f145fac03ff8a8e455ab211fe (2025-12-03)"
          echo -n "latest commit: "
          curl -s https://api.github.com/repos/xi-ve/openvr-space-calibrator-linux/commits/main | grep -o '"sha": *"[^"]*"' | head -1 | cut -d'"' -f4
        '';
      };
    };
}
