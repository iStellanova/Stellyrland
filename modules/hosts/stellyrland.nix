{inputs, ...}: {
  hosts.nixos.stellyrland = {
    system = "x86_64-linux";
    modules = [
      inputs.catppuccin.nixosModules.catppuccin
      inputs.hyprland.nixosModules.default
      inputs.disko.nixosModules.disko
      inputs.preservation.nixosModules.preservation
      inputs.nix-flatpak.nixosModules.nix-flatpak
      inputs.lanzaboote.nixosModules.lanzaboote
      inputs.sops-nix.nixosModules.sops

      # Identity configuration
      {
        identity = {
          username = "stellanova";
          homeDir = "/home/stellanova";
          gitName = "stellanova";
          userEmail = "iStellanova@users.noreply.github.com";
          sshKeys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID23408QRe02peABnmkDcmpu2DVSwN3H+Jm7kcVenTDr stellanova"
          ];
          dataPath = inputs.my-assets;
        };
      }

      # Host-specific configuration
      {
        imports = [./stellyrland/_hardware-configuration.nix];

        networking.hostName = "stellyrland";

        aspects = {
          core = {
            enable = true;
            nix-settings = {
              enable = true;
              cores = 24; # Reserve 8 threads for responsiveness on the 9950X3D (32 logical cores).
            };
            users.enable = true;
            hardware.enable = true;
            boot = {
              enable = true;
              secureBoot = true;
            };
            kernel-params.enable = true;
            initrd.enable = true;
            secrets.enable = true;
            kernel.enable = true;
            fonts.enable = true;
            networking.enable = true;
            storage.enable = true;
            extra-disk.enable = true;
            hdd.enable = true;
            preservation.enable = true;
            services-base.enable = true;
            xdg.enable = true;
            headless = {
              enable = true;
              disabledPorts = [
                "DP-2"
                "DP-3"
              ];
            };
          };
          desktop = {
            hyprland = {
              enable = true;
              wallpaperEngine.workshopId = "3258032485";
            };
            styling.enable = true;
          };
          programs = {
            cli.enable = true;
            ai-tools.enable = true;
            aesthetic.enable = true;
            background-sounds.enable = true;
            maintenance.enable = true;
            media.enable = true;
            media-editing.enable = true;
            utils.enable = true;
            browser.enable = true;
            gaming.enable = true;
            git.enable = true;
            zsh.enable = true;
            nixvim.enable = true;
            bitwarden.enable = true;
            vesktop.enable = true;
            noctalia-shell.enable = true;
            btop.enable = true;
            cava.enable = true;
            fastfetch.enable = true;
            gsr.enable = true;
            kitty.enable = true;
            nix-index.enable = true;
            ns.enable = true;
            yazi.enable = true;
            nautilus.enable = true;
            zed.enable = true;
          };
          services = {
            openssh.enable = true;
            discord-music-rpc.enable = true;
            greetd.enable = true;
            flatpak.enable = true;
            seahorse.enable = true;
            coolercontrol.enable = true;
            lact.enable = true;
            openrgb.enable = true;
            # ai = {
            #   enable = true;
            #   openWebUI.port = 8090;
            # };
          };
        };
      }
    ];
  };
}
