{ self, ... }:
let
  user = self.factory.user "stellanova";
in
{
  flake.modules = user // {
    nixos.stellanova = {
      imports = [
        user.nixos.stellanova
        self.modules.nixos.accessor
      ];
    };
    darwin.stellanova = {
      imports = [
        user.darwin.stellanova
        self.modules.darwin.accessor
      ];
    };
  };
}
