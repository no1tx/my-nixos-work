{ config, pkgs, lib, ... }:
{
  imports = [ 
    ../hardware-configuration.nix
  ];

  # --- Сетевые параметры ---
  networking.hostName = "hp-tablet";

  # --- Bluetooth и прошивки ---
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  hardware.firmware = with pkgs; [
    linux-firmware
  ];

  # --- Загрузчик и ядро ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;

  # --- Системные сервисы и обновления ---
  services.thermald.enable = true;      # Контроль температуры CPU
  services.fwupd.enable = true;         # Обновление прошивок

  # --- Графическая оболочка и дисплей: GNOME + GDM ---
  services.xserver.enable = true;
  services.xserver.desktopManager.gnome.enable = true;   # GNOME как DE
  services.xserver.displayManager.gdm.enable = true;     # GDM как DM
  # Можно добавить Wayland:
  services.xserver.displayManager.gdm.wayland = true;

  # --- Поведение при закрытии крышки и кнопках питания ---
  services.logind = {
    lidSwitch = "suspend";         # При закрытии крышки — suspend
    lidSwitchDocked = "ignore";   # В доке — игнорировать
  };

  services.libinput.enable = true;

  programs.kdeconnect = {
    enable = true;
    package = pkgs.gnomeExtensions.gsconnect;
  };

  # Отключаем Plasma, если она включена в общем desktop.nix
  services.desktopManager.plasma6.enable = lib.mkForce false;

  environment.systemPackages = [ pkgs.gnomeExtensions.appindicator pkgs.gnome-tweaks  ];
  services.udev.packages = [ pkgs.gnome-settings-daemon ];
  hardware.sensor.iio.enable = true;

}