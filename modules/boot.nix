{ config, pkgs, ... }:
{
  boot.plymouth.enable = true;
  zramSwap.enable = true;
  services.thermald.enable = true;
  services.fwupd.enable = true;
  services.openssh.enable = true;
}
