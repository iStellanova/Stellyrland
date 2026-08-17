{
  flake.modules.nixos.binfmt = {
    # Lets cross-compiling for aarch64-linux run target-arch binaries that
    # configure/build scripts sometimes need to execute via QEMU emulation.
    boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  };
}
