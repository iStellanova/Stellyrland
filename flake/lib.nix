{inputs, ...}: {
  flake.lib = inputs.nixpkgs.lib.extend (self: super: (import ../lib/default.nix {lib = self;}));
}
