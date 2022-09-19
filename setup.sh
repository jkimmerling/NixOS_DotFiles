#!/bin/bash

# get username from variable

cd /home/jasonk
mkdir app_images

git clone git@github.com:jkimmerling/NixOS_DotFiles.git

sudo nix-channel --add https://github.com/nix-community/home-manager/archive/release-22.05.tar.gz home-manager
sudo nix-channel --update

sudo mv /etc/nixos/configuration.nix /etc/nixos/configuration.nix-BAK
sudo ln -s /home/jasonk/NixOS_DotFiles/nixos/configuration.nix /etc/nixos/configuration.nix
