{ config, pkgs, ... }:

{
  ##########################################################################
  # 1. Импорты модулей
  ##########################################################################

  # Выберите нужный хост:
  # imports = [ ./modules/* ./hosts/desktop.nix ];
  # imports = [ ./modules/* ./hosts/laptop.nix ];
  imports = [
    ./modules/system.nix
    ./modules/networking.nix
    ./modules/boot.nix
    ./modules/desktop.nix
    ./modules/packages.nix
    ./modules/virtualization.nix
    ./modules/services.nix
    ./modules/maintenance.nix
    ./modules/users.nix
    ./hosts/desktop.nix
  ];
}
