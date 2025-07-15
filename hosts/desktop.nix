{ config, pkgs, ... }:

# --- Импорт аппаратных профилей ---
{
  imports = [ ../hardware-configuration.nix ];

  # --- Сетевые параметры ---
  networking.hostName = "btc-work";

  # --- Видео и звук (NVIDIA, PipeWire, PulseAudio) ---
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.legacy_470;
    modesetting.enable = true;
    powerManagement.enable = true;
    # open = true;
  };
  hardware.graphics.enable = true;
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    jack.enable = false;
  };

  # --- Загрузчик и ядро ---
  boot.loader = {
    grub = {
      enable = true;
      efiSupport = true;
      # efiInstallAsRemovable = true;          # Опционально
      device = "/dev/sda";                     # Диск установки GRUB
    };
    efi = {
      efiSysMountPoint = "/boot/";
      canTouchEfiVariables = true;
    };
  };
  boot.kernelPackages = pkgs.linuxPackages_xanmod;

  # --- Системные сервисы и обновления ---
  hardware.cpu.intel.updateMicrocode = true;

  # --- systemd: Звуки при загрузке и выключении ---
  systemd.services.startup-beep = {
    description = "Beep on system boot";
    wantedBy = [ "multi-user.target" ];
    after = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.beep}/bin/beep -f 1000 -l 200";
    };
  };
  systemd.services.shutdown-beep = {
    description = "Beep on shutdown";
    before = [ "shutdown.target" ];
    wantedBy = [ "shutdown.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.beep}/bin/beep -f 800 -l 200";
      RemainAfterExit = true;
    };
  };
}
