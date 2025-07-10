{ config, pkgs, ... }:
{
  imports = [ ../hardware-configuration.nix ];

  networking.hostName = "btc-macbook-work";

  # Видео и звук (nvidia, modesetting, etc)
  services.xserver.enable = true;
  boot.kernelPackages = pkgs.linuxPackages_xanmod;
  hardware.graphics.enable = true;
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    jack.enable = false;
  };
}
