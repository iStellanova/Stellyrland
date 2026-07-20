{ self, ... }: {
  flake.modules = self.factory.user "stellanova" true;
}
