{ self, ... }: {
  flake-file.inputs.finix.url = "git+https://github.com/finix-community/finix.git?ref=main";
  flake.finixConfigurations = self.lib.mkFinix "x86_64-linux" "stellyrland";
  flake.nixosConfigurations.stellyrland = self.finixConfigurations.stellyrland;
}
