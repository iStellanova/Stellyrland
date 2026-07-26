{ self, ... }: {
  flake.modules = self.factory.user "RedFlame" true;
}
