{sn, ...}: {
  sn.productivity = {includes = [sn.finance];};

  sn.finance.darwin = _: {
    homebrew.casks = ["quicken"];
  };
}
