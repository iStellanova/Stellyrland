{ self, ... }: {
  flake.modules = self.factory.user "user1" true;
}
