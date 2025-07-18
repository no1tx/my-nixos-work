{ config, pkgs, ... }:

# --- Импорт аппаратных профилей ---
{
  imports = [ ../hardware-configuration.nix ];

  # --- Сетевые параметры ---
  networking.hostName = "btc-macbook-work";

  # --- Видео и звук (NVIDIA, PipeWire, PulseAudio) ---
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  hardware.graphics.enable = true;
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    jack.enable = false;
  };

  # --- Загрузчик и ядро ---
  boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;
  boot.loader.systemd-boot.enable = true;
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot/";
    };
  };

  # --- Touchpad/keyboard quirks (libinput overrides) ---
  services.libinput.enable = true;
  environment.etc."libinput/local-overrides.quirks".text = ''
    [MacBook(Pro) SPI Touchpads]
    MatchName=*Apple SPI Touchpad*
    ModelAppleTouchpad=1
    AttrTouchSizeRange=200:150
    AttrPalmSizeThreshold=1100

    [MacBook(Pro) SPI Keyboards]
    MatchName=*Apple SPI Keyboard*
    AttrKeyboardIntegration=internal

    [MacBookPro Touchbar]
    MatchBus=usb
    MatchVendor=0x05AC
    MatchProduct=0x8600
    AttrKeyboardIntegration=internal
  '';

  # --- Firmware, microcode, WiFi ---
  networking.enableB43Firmware = true;
  hardware = {
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = true;
  };

  # --- Клавиатура (applespi) и iommu ---
  boot.initrd.kernelModules = [
    "applespi"
    "spi_pxa2xx_platform"
    "intel_lpss_pci"
    "applesmc"
  ];

  # --- d3cold workaround ---
  systemd.services.disable-nvme-d3cold = {
    description = "Disables d3cold on the NVME controller";
    before = [ "suspend.target" ];
    path = [ pkgs.bash pkgs.coreutils ];
    serviceConfig.Type = "oneshot";
    serviceConfig.ExecStart = "${./disable-nvme-d3cold.sh}";
    serviceConfig.TimeoutSec = 0;
    wantedBy = [ "multi-user.target" "suspend.target" ];
  };
  boot.kernelParams = [
    "i915.enable_guc=2"
    "i915.enable_fbc=1"
    "i915.enable_psr=2"
  ];

  # --- Специфический пакет для исправления звука MacBook Pro 2017 ---
  boot = {
    extraModulePackages = [
      (pkgs.callPackage ./packages/macbook/snd-hda-cs8409/default.nix {
        kernel = pkgs.linuxPackages_xanmod_latest.kernel;
      })
    ];
  };

  hardware.graphics.extraPackages = with pkgs; [
    intel-media-driver
  ];

  # --- Поведение при закрытии крышки и кнопках питания ---
  services.logind = {
    lidSwitch = "hibernate";
    lidSwitchDocked = "ignore";
    powerKey = "hibernate";
  };

  # --- Дополнительная конфигурация systemd ---
  systemd.extraConfig = ''
    HibernateDelaySec=0
  '';
}
