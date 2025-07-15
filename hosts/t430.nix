{ config, pkgs, ... }:

# --- Импорт аппаратных профилей и внешних модулей ---
let
  # Официальный модуль nixos-hardware для ThinkPad T430
  nixos-hardware = builtins.fetchTarball https://github.com/NixOS/nixos-hardware/archive/master.tar.gz;
in

{
  imports = [ 
    ../hardware-configuration.nix
    (import "${nixos-hardware}/lenovo/thinkpad/t430")
  ];

  # --- Сетевые параметры ---
  networking.hostName = "t430";

  # --- Bluetooth и прошивки ---
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  hardware.firmware = with pkgs; [
    linux-firmware
    broadcom-bt-firmware  # Прошивка для Bluetooth
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
}