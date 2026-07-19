_: {
  flake.modules.nixos.librewolf = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.librewolf ];
  };

  flake.modules.homeManager.librewolf = _: {
    programs.librewolf = {
      enable = true;
      settings = {
        "webgl.disabled" = false;
        "media.ffmpeg.vaapi.enabled" = true;
      };
    };
  };
}
