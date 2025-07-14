{ config, pkgs, ... }:
{
  services.thermald.enable = true;
  services.fwupd.enable = true;
  services.openssh.enable = true;
  boot.plymouth.enable = true;
}
