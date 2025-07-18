{ config, pkgs, ... }:
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

  # --- Графическая оболочка и дисплей ---
  services.displayManager.sddm.enable = true;         # Графический дисплей-менеджер SDDM
  services.displayManager.sddm.wayland.enable = true; # Поддержка Wayland

  # --- Поведение при закрытии крышки и кнопках питания ---
  services.logind = {
    lidSwitch = "suspend";         # При закрытии крышки — suspend
    lidSwitchDocked = "ignore";   # В доке — игнорировать
  };

  environment.systemPackages = with pkgs; [
    maliit-keyboard maliit-framework
  ];

  environment.sessionVariables = {
    QT_IM_MODULE = "maliit";
  };
  services.libinput.enable = true;
}