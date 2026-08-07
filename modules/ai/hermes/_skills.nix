{ inputs }:
{
  flakeInputs.ponytail = {
    url = "github:DietrichGebert/ponytail";
    flake = false;
  };

  files.".hermes/plugins/ponytail" = {
    source = inputs.ponytail;
    force = true;
  };

  hermesConfig.plugins.enabled = [ "ponytail" ];
}
