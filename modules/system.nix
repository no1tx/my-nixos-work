{ config, pkgs, ... }:
{
  zramSwap.enable = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.nvidia.acceptLicense = true;
  system.stateVersion = "25.05";
  time.timeZone = "Europe/Moscow";
  i18n.defaultLocale = "ru_RU.UTF-8";
  programs.zsh.enable = true;
  console = {
    keyMap = "ruwin_alt_sh-UTF-8";
    font = "ter-v22n";
  };
}
