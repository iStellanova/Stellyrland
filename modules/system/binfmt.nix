{
  flake.modules.nixos.binfmt = {
    # Lets cross-compiling for aarch64-linux (e.g. the famtop Asahi installer
    # ISO) run target-arch binaries that configure/build scripts sometimes
    # need to execute (SONAME probes, etc.) via transparent qemu emulation.
    boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  };
}
