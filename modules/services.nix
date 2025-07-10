{ config, pkgs, ... }:
{
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server";
  };
  services.syncthing = {
    enable = true;
    group = "users";
    user = "no1_tx";
    dataDir = "/home/no1_tx/";
    configDir = "/home/no1_tx/.config/syncthing";
  };
  programs.kdeconnect.enable = true;
}
