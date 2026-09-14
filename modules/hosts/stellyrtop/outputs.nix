{ self, ... }: {
  flake.darwinConfigurations = self.lib.mkDarwin "aarch64-darwin" "stellyrtop";
}
