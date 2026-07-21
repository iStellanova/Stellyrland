_:
let
  osShared = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      manuskript
    ];
  };
in
{
  flake.modules.nixos.writing = osShared;
  flake.modules.darwin.writing = osShared;
}
