{ config, pkgs, ... }:
{
  services.desktopManager.plasma6.enable = true;
  services.flatpak.enable = true;
  fonts.packages = with pkgs; [
    terminus_font
    dejavu_fonts
    liberation_ttf
    noto-fonts
    noto-fonts-emoji
    nerd-fonts.jetbrains-mono
    inter
    nerd-fonts.fira-code
    nerd-fonts.droid-sans-mono
  ];
  fonts.fontconfig = {
    enable = true;
    antialias = true;
    hinting.enable = true;
    hinting.autohint = true;
  };
  fonts.fontDir.enable = true;

}
