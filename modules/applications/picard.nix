{
  modules.nixos.picard = { lib, host, pkgs, ... }: {
    environment.systemPackages = [ pkgs.picard ];

    imports = lib.optional (host.persistence or false) {
      preservation.preserveAt."/persist".users.${host.username}.directories = [
        ".config/MusicBrainz/Picard"
        ".local/share/MusicBrainz/Picard"
      ];
    };
  };
}