let
  osShared = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      zoom-us
      super-productivity
    ];
  };

in
{
  modules.nixos.school = osShared;
  modules.darwin.school = osShared;
}
