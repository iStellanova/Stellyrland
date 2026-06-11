{
  sn,
  ...
}: {
  sn.productivity = {includes = [sn.planify];};

  sn.planify.nixos = {pkgs, ...}: {
    environment.systemPackages = [pkgs.planify];
  };
}
