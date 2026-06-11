{sn, ...}: {
  sn.productivity = {includes = [sn.writing];};

  sn.writing.darwin = _: {
    homebrew.masApps = {
      "Beat" = 1549538329;
      "Essayist" = 1537845384;
    };
  };
}
