{ config, pkgs, ... }:

let

  nixos-hardware = builtins.fetchTarball https://github.com/NixOS/nixos-hardware/archive/master.tar.gz;

in

{
  imports = [ 
    ../hardware-configuration.nix
    (import "${nixos-hardware}/lenovo/thinkpad/t430")
   ];

  networking.hostName = "t430";

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  hardware.firmware = 
    with pkgs;
    [ 
      linux-firmware
      broadcom-bt-firmware  
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  services.thermald.enable = true;
  services.fwupd.enable = true;
  boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;


  services.logind = {
    lidSwitch = "suspend";
    lidSwitchDocked = "ignore";
  };


}