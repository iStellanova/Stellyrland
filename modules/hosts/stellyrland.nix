_: {
  den.hosts.x86_64-linux.stellyrland = {
    flakePath = "/home/stellanova/Projects/stellyrland";
    monitorPriority = [
      "DP-2"
      "DP-3"
    ];

    features = {
      hdr = true;
    };

    users.stellanova = { };
  };
}
