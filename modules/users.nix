{ config, pkgs, ... }:

let
  home-manager = builtins.fetchTarball https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz;
in

{
  imports = [
    (import "${home-manager}/nixos")
  ];

  # --- Пользователь no1_tx ---
  users.users.no1_tx = {
    isNormalUser = true;
    shell = pkgs.zsh;
    description = "Pavel Isaev";
    extraGroups = [
      "wheel" "docker" "networkmanager" "video"
      "audio" "libvirtd" "podman"
    ];
  };

  # --- Пользователь root: shell и prompt ---
  users.users.root = {
    shell = pkgs.zsh;
  };
  environment.systemPackages = with pkgs; [ zsh starship ];

  # --- Home Manager: пользовательские настройки ---
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "backup";
  home-manager.users.no1_tx = { pkgs, ... }: {
    home.username = "no1_tx";
    home.homeDirectory = "/home/no1_tx";
    home.stateVersion = "25.05";
    programs = {
      zsh.enable = true;
      git.enable = true;
      starship = {
        enable = true;
        enableZshIntegration = true;
        # Внедряем пресет pastel-powerline
        settings = builtins.fromTOML (builtins.readFile ./configs/catppuccin-powerline.toml);
      };
    };
    home.packages = with pkgs; [
      zsh-autosuggestions
      zsh-syntax-highlighting
      btop
      jq
      tmux
      fastfetch
    ];
    programs.zsh.shellAliases = {
      ll = "ls -lh";
      gs = "git status";
      ga = "git add";
      gc = "git commit";
    };
    xdg.configFile."fontconfig/conf.d/50-user-fonts.conf".text = ''
      <?xml version="1.0"?>
      <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
      <fontconfig>
        <match target="font">
          <edit name="rgba" mode="assign">
            <const>rgb</const>
          </edit>
        </match>
       <match target="font">
          <edit name="hinting" mode="assign">
            <bool>true</bool>
          </edit>
        </match>
        <match target="font">
          <edit name="hintstyle" mode="assign">
            <const>hintslight</const>
          </edit>
        </match>
        <match target="font">
          <edit name="antialias" mode="assign">
            <bool>true</bool>
          </edit>
        </match>
      </fontconfig>
    '';
  };

  # --- Настройка starship для root через system-wide конфиг ---
  environment.etc."starship.toml".source = ./configs/catppuccin-powerline.toml;
}
