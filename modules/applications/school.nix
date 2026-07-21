_:
let
  osShared = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      zoom-us
      super-productivity
    ];
  };
in
{
  flake.modules.nixos.school = osShared;
  flake.modules.darwin.school = osShared;
}
