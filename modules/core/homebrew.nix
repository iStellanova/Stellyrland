_: {
  # Darwin Homebrew settings
  flake.modules.darwin.homebrew = _: {
    config = {
      homebrew = {
        enable = true;
        onActivation = {
          autoUpdate = true;
          # TODO: restore "zap" once nix-darwin passes --force-cleanup in the sudo invocation.
          # brew bundle --cleanup now requires --force/--force-cleanup/$HOMEBREW_ASK, but sudo
          # --preserve-env=PATH strips all env vars, making injection impossible from Nix side.
          cleanup = "none";
          upgrade = true;
        };
      };
    };
  };
}
