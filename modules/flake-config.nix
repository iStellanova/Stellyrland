{inputs, ...}: {
  systems = [
    "x86_64-linux"
    "aarch64-darwin"
  ];

  flake.lib = inputs.nixpkgs.lib.extend (
    self: _super: import ../lib/default.nix {lib = self;}
  );
}
