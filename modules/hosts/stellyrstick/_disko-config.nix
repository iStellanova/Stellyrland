# Install-time layout for the portable USB host; runtime mounts live in
# _hardware-configuration.nix.
{ inputs, ... }:
{
  imports = [ inputs.disko.nixosModules.disko ];

  disko.enableConfig = false;

  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/disk/by-id/usb-PNY_USB_3.2.1_FD_071824C19485EC12-0:0";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          priority = 1;
          label = "STELLYRSTICK";
          size = "1G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
          };
        };
        swap = {
          priority = 2;
          size = "2G";
          content = {
            type = "swap";
          };
        };
        root = {
          priority = 3;
          size = "100%";
          content = {
            type = "luks";
            name = "stellyrstick-root";
            settings.allowDiscards = true;
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
            };
          };
        };
      };
    };
  };
}
