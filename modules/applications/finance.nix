{
  # No nixos stanza: Quicken is Mac/Windows-only, no supported Linux equivalent.
  flake.modules.darwin.finance = {
    homebrew.casks = [ "quicken" ];
  };
}
