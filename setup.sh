#!/bin/bash

# get username from variable

cd /home/jasonk

git clone git@github.com:jkimmerling/NixOS_DotFiles.git

sudo rm /etc/nixos/configuration.nix
ln -s /home/jasonk/NixOS_DotFiles/nixos/configuration.nix /etc/nixos/configuration.nix
