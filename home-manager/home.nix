{ config, pkgs, ... }:

{
  home.username = "bloppai";
  home.homeDirectory = "/home/bloppai";

  home.stateVersion = "25.11"; # like nixos stateVersion, dont change

  home.packages = [
  ];

  home.sessionVariables = {
    NIXOS_OZONE_WL = "1"; #wayland apps use ozone
    grim="grimblast";
    wl="wl-copy";
    MOZ_ENABLE_WAYLAND = 0;
    cmpl="g++ -std=c++17 -Wall -Wextra -pedantic-errors -Weffc++ -Wno-unused-parameter -fsanitize=undefined,address *.cpp"; #for CSCE120 cpp compiler options
  };

  # Let Home Manager install and manage itself.
  
  programs = {
    home-manager.enable = true;

    caelestia = {
      enable = true;
      systemd = {
        #enable = false; # if you prefer starting from your compositor
        target = "graphical-session.target";
        environment = [];
      };
      settings = {
        bar.status = {
          showBattery = true;
        };
        paths.wallpaperDir = "~/.config/wallpapers/astronaut.png";
      };
      cli = {
        enable = true; # Also add caelestia-cli to path
        settings = {
          theme.enableGtk = false;
        };
      };
    };

    bash = {
      enable = true;
      initExtra = ''
        testCpp() {
          if [ -z "$1" ]; then
            make -C tests -j12 run-all -k
          else
            make -C tests -j12 run/$1
          fi
        }
      '';
    };


    firefox.enable = true;
    chromium.enable = true;

    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };

    git.enable = true;
    tmux.enable = true;

    waybar.enable = true;
    hyprlock.enable = true;
  };
}
