{ sn, ... }: {
  sn.productivity = {
    includes = [ sn.finance ];
  };

  # No nixos stanza: Quicken is Mac/Windows-only, no supported Linux equivalent.
  sn.finance.darwin = _: {
    homebrew.casks = [ "quicken" ];
  };
}
