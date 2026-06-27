_: {
  den.hosts.x86_64-linux.stellyrland = {
    homeDir = "/home/stellanova";
    flakePath = "/home/stellanova/Projects/stellyrland";

    features = {
      secureBoot = true;
      hdr = true;
      coolerControl = true;
      lact = true;
    };

    users.stellanova = {};
  };
}
