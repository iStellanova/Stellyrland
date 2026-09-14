{ self, ... }: {
  darwinConfigurations = self.lib.mkDarwin "aarch64-darwin" "stellyrtop";
}
