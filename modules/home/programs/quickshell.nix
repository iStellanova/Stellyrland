{ inputs, config, pkgs, ... }:

let
  quickshell = inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default;
  qmlImports = with pkgs.qt6; [
    qt5compat
    qtwayland
    qtdeclarative
    qtsvg
    qtmultimedia
  ];
in {
  home.packages = [
    (pkgs.writeShellScriptBin "quickshell" ''
      export QML_IMPORT_PATH="${pkgs.lib.makeSearchPath "lib/qt-6/qml" qmlImports}:$QML_IMPORT_PATH"
      export QML2_IMPORT_PATH="${pkgs.lib.makeSearchPath "lib/qt-6/qml" qmlImports}:$QML2_IMPORT_PATH"
      exec ${quickshell}/bin/quickshell "$@"
    '')
  ] ++ qmlImports;

  # Recursively symlink each file in config to ~/.config/quickshell
  # This allows matugen to write colors.json in the same directory
  xdg.configFile = let
    configDir = ./quickshell/config;
    files = pkgs.lib.filesystem.listFilesRecursive configDir;
    
    # Helper to create the attribute name and value for each file
    toConfigAttr = path: {
      name = "quickshell/" + (pkgs.lib.removePrefix (toString configDir + "/") (toString path));
      value = { source = path; };
    };
  in builtins.listToAttrs (map toConfigAttr files);
}
