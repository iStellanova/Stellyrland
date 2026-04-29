{ config, lib, pkgs, ... }:

let
  cfg = config.aspects.services.coolercontrol;
  coolerConfig = pkgs.writeText "coolercontrol-config.toml" ''
# ==============================================================================
# CoolerControl Configuration - Managed by NixOS
# ==============================================================================

# --- Unique ID Device List ---
[devices]
c1c4f573af5adb37f4b2b21c38e7ab00131dec4e073a10af87799b5e930fee88 = "AMD Ryzen 9 9950X3D 16-Core Processor"
a06dc537aacb907e3aa1a69a6ab67106537d395252872d1c756ba223a6785b66 = "r8169_0_1000:00"
7deb4a0fe5e737483aeef3aeb54517362600688c291e31f0c503c90e363584a5 = "z53"
2d9a9f02e09f68d74af68145127df9cac50dc08f6e84a89b8fe7ece3db51da32 = "nvme0"
19e098e312e1b1b39163a343ea22b6ea17f18ec1a803ffe0ce44f5bacd6076ee = "Custom Sensors"
2af841828b301922fd91182ee0564e731459a8484a61fe4209d9d91e3315d184 = "amdgpu"
996156de9ace76d9a0d0f156358832d85b8e22f8ea4c59c14a215e34cc2343dc = "mt7921_phy0"
30be009423237289c356ab4559d592436c61374f8624c7d13aa7b7c2f26eee11 = "nvme2"
9a64f7a5c7b59e073064f69eea496b0424b867bb35c843c28825f6d4a73aeba5 = "gigabyte_wmi"
f42333b13a2853dfb8e516c576470622e74a4659bfffe7ca229f68733beae979 = "acpitz"
97910386cac9bfce54b2c224e4aaef42cd953440cb57f1ff5ff46ac183bf338e = "amdgpu"
23e5f03b21099ed5fedc5aa20dc78ac022e492d5595230be701cb939363d0260 = "nvme1"
914e1bc3a45b7bec59de01518baf9725774b1e1ed1b3a7e86df8922b9ae00ab4 = "NZXT Kraken Z (Z53, Z63 or Z73)"
6652394d0545f0577cc613773ca85145b28fb5a266512af9e414704d3ed10744 = "Gigabyte RGB Fusion 2.0 5702 Controller"
78253a0bbf8c5f69d5e80bb6418287c12b755575b530954fe94f70e362d20b39 = "mt7921_phy1"
d8a0d82688da79d4d5ae97535c0b13b6b64bd5a0353b53e2e9a7de8e5638b3c8 = "spd5118"
961547fb3857172fc22c5f76f1acf7f103bf2512c68dec92287a81c9814fd2c6 = "spd5118"
c6d76dc72d383065b8f9126461927f904ea2c08dd869ebec3489b245dfbd64de = "Lian Li Uni SL-Infinity"

[legacy690]

# --- Device Settings ---
[device-settings]

[device-settings.914e1bc3a45b7bec59de01518baf9725774b1e1ed1b3a7e86df8922b9ae00ab4]
lcd = { lcd = { mode = "temp", brightness = 50, orientation = 270, colors = [], temp_source = { temp_name = "temp1", device_uid = "c1c4f573af5adb37f4b2b21c38e7ab00131dec4e073a10af87799b5e930fee88" } } }
pump = { speed_fixed = 100 }
fan = { speed_fixed = 100 }

[device-settings.c6d76dc72d383065b8f9126461927f904ea2c08dd869ebec3489b245dfbd64de]
fan1 = { profile_uid = "0e2d7e57-668a-47f3-b703-265b5a520488" }
fan2 = { profile_uid = "0e2d7e57-668a-47f3-b703-265b5a520488" }
fan3 = { profile_uid = "0e2d7e57-668a-47f3-b703-265b5a520488" }
fan4 = { profile_uid = "0e2d7e57-668a-47f3-b703-265b5a520488" }

# --- Fan Profiles ---
[[profiles]]
uid = "0"
name = "Default Profile"
p_type = "Default"
function = "0"

[[profiles]]
uid = "0840dd7f-04cb-4c72-9303-4d78f0e92a55"
name = "My Profile"
p_type = "Default"
speed_profile = []
function_uid = "02ba5ea0-89cc-4085-808f-c3b1cc97963b"

[[profiles]]
uid = "0e2d7e57-668a-47f3-b703-265b5a520488"
name = "Main"
p_type = "Graph"
speed_profile = [[0.0, 0], [25.0, 20], [45.0, 45], [65.0, 70], [80.0, 100]]
temp_source = { temp_name = "temp1", device_uid = "c1c4f573af5adb37f4b2b21c38e7ab00131dec4e073a10af87799b5e930fee88" }
temp_min = 0.0
temp_max = 95.0
function_uid = "0"
offset_profile = []

[[profiles]]
uid = "dff3f2ae-c3a6-4186-bdde-f1765ff3678f"
name = "Main, GPU"
p_type = "Graph"
speed_profile = [[25.0, 20], [45.0, 45], [65.0, 52], [80.0, 75], [100.0, 100]]
temp_source = { temp_name = "temp2", device_uid = "97910386cac9bfce54b2c224e4aaef42cd953440cb57f1ff5ff46ac183bf338e" }
temp_min = 25.0
temp_max = 100.0
function_uid = "0"
offset_profile = []

# --- Functions ---
[[functions]]
uid = "0"
name = "Default Function"
f_type = "Identity"

[[functions]]
uid = "02ba5ea0-89cc-4085-808f-c3b1cc97963b"
name = "My Function"
f_type = "Identity"
duty_minimum = 2
duty_maximum = 100

# --- General Settings ---
[settings]
apply_on_boot = true
liquidctl_integration = true
hide_duplicate_devices = true
no_init = false
startup_delay = 2
thinkpad_full_speed = false
compress = false
drivetemp_suspend = false

[settings.c1c4f573af5adb37f4b2b21c38e7ab00131dec4e073a10af87799b5e930fee88]
name = "AMD Ryzen 9 9950X3D 16-Core Processor"
disable = false

# --- GPU Conflict Prevention (Disabled here to allow LACT to manage the GPU) ---
[settings.97910386cac9bfce54b2c224e4aaef42cd953440cb57f1ff5ff46ac183bf338e]
name = "Navi 31 [Radeon RX 7900 XT/7900 XTX/7900 GRE/7900M]"
disable = true

[settings.97910386cac9bfce54b2c224e4aaef42cd953440cb57f1ff5ff46ac183bf338e.channel_settings]
fan1 = { label = "Fan1", disabled = true }

[settings.2af841828b301922fd91182ee0564e731459a8484a61fe4209d9d91e3315d184]
name = "Granite Ridge [Radeon Graphics]"
disable = true

# --- Other Hardware ---
[settings.f42333b13a2853dfb8e516c576470622e74a4659bfffe7ca229f68733beae979]
name = "acpitz"
disable = false

[settings.9a64f7a5c7b59e073064f69eea496b0424b867bb35c843c28825f6d4a73aeba5]
name = "gigabyte_wmi"
disable = false

[settings.996156de9ace76d9a0d0f156358832d85b8e22f8ea4c59c14a215e34cc2343dc]
name = "mt7921_phy0"
disable = false

[settings.2d9a9f02e09f68d74af68145127df9cac50dc08f6e84a89b8fe7ece3db51da32]
name = "Corsair MP700"
disable = false

[settings.23e5f03b21099ed5fedc5aa20dc78ac022e492d5595230be701cb939363d0260]
name = "Sabrent Rocket 4.0 500GB"
disable = false

[settings.30be009423237289c356ab4559d592436c61374f8624c7d13aa7b7c2f26eee11]
name = "Sabrent SB-RKT4P-2TB"
disable = false

[settings.a06dc537aacb907e3aa1a69a6ab67106537d395252872d1c756ba223a6785b66]
name = "r8169_0_1000:00"
disable = false

[settings.7deb4a0fe5e737483aeef3aeb54517362600688c291e31f0c503c90e363584a5]
name = "z53"
disable = false

[settings.c6d76dc72d383065b8f9126461927f904ea2c08dd869ebec3489b245dfbd64de]
name = "Lian Li Uni SL-Infinity"
disable = false

[settings.914e1bc3a45b7bec59de01518baf9725774b1e1ed1b3a7e86df8922b9ae00ab4]
name = "NZXT Kraken Z"
disable = false

[settings.6652394d0545f0577cc613773ca85145b28fb5a266512af9e414704d3ed10744]
name = "Gigabyte RGB Fusion 2.0 5702 Controller"
disable = false
  '';
in
{
  options.aspects.services.coolercontrol.enable = lib.mkEnableOption "CoolerControl service";

  config = lib.mkIf cfg.enable {
    programs.coolercontrol.enable = true;

    environment.systemPackages = [
      pkgs.coolercontrol.coolercontrol-gui
      pkgs.liquidctl
    ];
    # CoolerControl Configuration Management:
    # We use a systemd preStart script instead of environment.etc because
    # coolercontrold requires its configuration file to be writable for runtime updates.
    # This allows us to keep the config declarative in Nix while satisfying the daemon.
    systemd.services.coolercontrold.preStart = ''
      mkdir -p /etc/coolercontrol
      cp -f ${coolerConfig} /etc/coolercontrol/config.toml
      chmod 644 /etc/coolercontrol/config.toml
    '';
  };
}
