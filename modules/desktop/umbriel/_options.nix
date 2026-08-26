{ lib, ... }:
{
  options.desktop.umbriel.outputs = lib.mkOption {
    type = lib.types.attrsOf (lib.types.attrsOf lib.types.anything);
    default = { };
    description = "Umbriel output configuration keyed by connector name.";
  };
}
