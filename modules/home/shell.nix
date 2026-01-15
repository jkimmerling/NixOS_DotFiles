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
      update = "nix --extra-experimental-features 'nix-command flakes' flake update /home/jasonk/Dot_Files && sudo nixos-rebuild switch --flake /home/jasonk/Dot_Files#nixos";
    };
    shellInit = ''
      # Disable fish greeting
      set -g fish_greeting
    '';
  };

  # Starship prompt
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
  };
}
