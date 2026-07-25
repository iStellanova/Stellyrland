{ self, ... }: {
  flake.nixosConfigurations = self.lib.mkNixos "aarch64-linux" "famtop";
}
