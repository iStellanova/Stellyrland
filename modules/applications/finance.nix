_: {
  # No nixos stanza: Quicken is Mac/Windows-only, no supported Linux equivalent.
  flake.modules.darwin.finance = _: {
    homebrew.casks = [ "quicken" ];
  };
}
