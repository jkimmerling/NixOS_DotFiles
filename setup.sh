#!/bin/bash

# get username from variable
# get channel version (22.05 or Unstable)

cd /home/jasonk
mkdir AppImages
mkdir Development

git clone git@github.com:jkimmerling/NixOS_DotFiles.git

sudo nix-channel --add https://github.com/nix-community/home-manager/archive/release-22.05.tar.gz home-manager
sudo nix-channel --update

sudo mv /etc/nixos/configuration.nix /etc/nixos/configuration.nix-BAK
sudo ln -s /home/jasonk/NixOS_DotFiles/nixos/configuration.nix /etc/nixos/configuration.nix

ln -s /home/jasonk/NixOS_DotFiles/qtile /home/jasonk/.config/qtile