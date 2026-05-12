{ ... }: {
  programs.noctalia-shell.settings.appLauncher = {
    autoPasteClipboard = false;
    clipboardWatchImageCommand = "wl-paste --type image --watch cliphist store";
    clipboardWatchTextCommand = "wl-paste --type text --watch cliphist store";
    clipboardWrapText = true;
    customLaunchPrefix = "";
    customLaunchPrefixEnabled = false;
    density = "default";
    enableClipPreview = true;
    enableClipboardChips = true;
    enableClipboardHistory = false;
    enableClipboardSmartIcons = true;
    enableSessionSearch = true;
    enableSettingsSearch = true;
    enableWindowsSearch = true;
    iconMode = "native";
    ignoreMouseInput = false;
    overviewLayer = true;
    pinnedApps = [
      "org.gnome.Lollypop"
      "zen"
      "dev.zed.Zed"
      "vesktop"
      "steam"
      "antigravity"
    ];
    position = "center";
    screenshotAnnotationTool = "";
    showCategories = true;
    showIconBackground = false;
    sortByMostUsed = true;
    terminalCommand = "kitty -e";
    viewMode = "list";
  };
}
