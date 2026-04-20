{ pkgs, ... }:

{
  services.hardware.openrgb = {
    enable = false;
    package = pkgs.openrgb-with-all-plugins;
    motherboard = "amd";
  };

  # Enable I2C support (required for many RAM and Motherboard RGB controllers)
  hardware.i2c.enable = true;

  # Ensure the package is available in the system environment
  environment.systemPackages = [
    pkgs.openrgb-with-all-plugins
  ];
}
