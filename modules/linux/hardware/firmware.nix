_: {
  flake.modules.nixos.firmware = _: {
    hardware.enableRedistributableFirmware = true;
    hardware.cpu.amd.updateMicrocode = true;
  };
}
