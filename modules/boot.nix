{ config, pkgs, ... }:
{
  zramSwap.enable = true;
  services.thermald.enable = true;
  services.fwupd.enable = true;
  services.openssh.enable = true;
}
