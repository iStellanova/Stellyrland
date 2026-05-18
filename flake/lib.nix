{inputs, ...}: {
  flake.lib = inputs.nixpkgs.lib.extend (self: _super: (import ../lib/default.nix {lib = self;}));
}
