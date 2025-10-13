{ config, pkgs, ... }:

{
  # ===== SHELL CONFIGURATION =====

  # Fish shell configuration
  programs.fish = {
    enable = true;
    shellAliases = {
      ll = "eza -l";
      la = "eza -la";
      ls = "eza";
      ".." = "cd ..";
      rebuild = "sudo nixos-rebuild switch --flake /home/jasonk/Dot_Files#nixos";
      update = "sudo nixos-rebuild switch --flake /home/jasonk/Dot_Files#nixos";
    };
    shellInit = ''
      # Disable fish greeting
      set -g fish_greeting
    '';
  };

  # Bash configuration (keep as fallback)
  programs.bash = {
    enable = true;
    shellAliases = {
      ll = "ls -l";
      la = "ls -la";
      ".." = "cd ..";
      rebuild = "sudo nixos-rebuild switch --flake /home/jasonk/Dot_Files#nixos";
      update = "sudo nixos-rebuild switch --flake /home/jasonk/Dot_Files#nixos";
    };
  };

  # Starship prompt
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
  };
}
