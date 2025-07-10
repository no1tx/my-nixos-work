{ config, pkgs, ... }:
{
  services.desktopManager.plasma6.enable = true;
  services.flatpak.enable = true;
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.droid-sans-mono
  ];
  fonts.fontconfig = {
    enable = true;
    antialias = true;
    hinting.enable = true;
    hinting.autohint = true;
  };
}
