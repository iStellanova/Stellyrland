{ inputs, pkgs, ... }:

{
  home.packages = with pkgs; [
    quickshell
    (stdenv.mkDerivation {
      pname = "qs-hyprview";
      version = "unstable";
      src = inputs.qs-hyprview-src;
      dontWrapQtApps = true;
      nativeBuildInputs = [ makeWrapper ];
      buildInputs = [ qt6.qt5compat qt6.qtdeclarative ];
      installPhase = ''
        mkdir -p $out/share/qs-hyprview
        cp -r . $out/share/qs-hyprview
        
        # Daemon/Start command
        makeWrapper ${quickshell}/bin/quickshell $out/bin/qs-hyprview \
          --add-flags "-c $out/share/qs-hyprview" \
          --prefix QML2_IMPORT_PATH : "${qt6.qt5compat}/lib/qt-6/qml" \
          --prefix QML2_IMPORT_PATH : "${qt6.qtdeclarative}/lib/qt-6/qml"

        # Toggle command (IPC)
        # Using 'smart-grid' as the default layout for the toggle
        makeWrapper ${quickshell}/bin/quickshell $out/bin/qs-hyprview-toggle \
          --add-flags "ipc -c $out/share/qs-hyprview call expose toggle smart-grid"
      '';
    })
  ];
}
