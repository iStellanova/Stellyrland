{
  description = "Stellyrland System Configurations.";

  outputs = { self }:
    let
      inputs = (import ./.pnix { }) // { inherit self; };
    in
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
