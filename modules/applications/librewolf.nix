_: {
  flake.modules.nixos.librewolf =
    {
      lib,
      host,
      ...
    }:
    {
      imports = lib.optional (host.persistence or false) {
        preservation.preserveAt."/persist".users.${host.username}.directories = [ ".librewolf" ];
      };
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
