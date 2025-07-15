{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    zsh tmux neofetch htop btop tree ripgrep fd bat
    starship curl wget unzip git podman-compose
    python3 poetry gcc gnumake openssh
    helix vim neovim
    terminus_font beep lnav firefox home-manager virt-manager-qt
    virt-manager syncthing jetbrains.pycharm-community vscode
    arc-theme mc flashrom dmidecode code-cursor direnv
  ];
  nixpkgs.config.allowUnfree = true;

}
