{ config, pkgs, ... }:
{
  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  systemd.services.git-update-nixos-config = {
    description = "Update /etc/nixos config from remote git repo";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      WorkingDirectory = "/etc/nixos";
      ExecStart = "${pkgs.git}/bin/git pull --rebase";
    };
  };
  systemd.timers.git-update-nixos-config = {
    description = "Timer for updating /etc/nixos config from git";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };
    unitConfig = {
      Requires = [ "systemd-networkd-wait-online.service" ];
    };
  };
  environment.systemPackages = with pkgs; [
    (writeShellScriptBin "nixos-super-upgrade" ''
      set -e
      if [ "$EUID" -ne 0 ]; then
        echo "Requesting sudo to run nixos-super-upgrade..."
        exec sudo "$0" "$@"
      fi
      cd /etc/nixos
      ${pkgs.git}/bin/git pull --rebase
      ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch
    '')
  ];
}
