{ inputs, ... }: {
  # "sn" namespace — local only, not exported to flake outputs
  imports = [ (inputs.den.namespace "sn" false) ];
}
