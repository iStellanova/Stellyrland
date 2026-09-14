{
  # No nixos stanza: Quicken is Mac/Windows-only, no supported Linux equivalent.
  modules.darwin.finance = {
    homebrew.casks = [ "quicken" ];
  };
}
