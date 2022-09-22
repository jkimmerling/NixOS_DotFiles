#!/run/current-system/sw/bin/bash

while getopts u:c: flag
do
        case "${flag}" in
            u) username=${OPTARG};;
            c) channel=${OPTARG};;
        esac
done

cd /home/$username
mkdir AppImages
mkdir Development

git clone git@github.com:jkimmerling/NixOS_DotFiles.git

if [ ${channel:-0} == 0 ] ; then
    sudo nix-channel --add https://github.com/nix-community/home-manager/archive/release-22.05.tar.gz home-manager
    sudo nix-channel --update
elif [ ${channel:-0} == 'unstable' ]; then
    sudo nix-channel --remove nixos
    sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos
    sudo nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
    sudo nix-channel --update
else
    sudo nix-channel --add https://github.com/nix-community/home-manager/archive/release-$channel.tar.gz home-manager
    sudo nix-channel --update
    sed -i "s/22.05/$channel" /home/$username/NixOS_DotFiles/nixos/configuration.nix
fi

sudo mv /etc/nixos/configuration.nix /etc/nixos/configuration.nix-BAK
sudo ln -s /home/$username/NixOS_DotFiles/nixos/configuration.nix /etc/nixos/configuration.nix

sed -i "s/jasonk/$username" /home/$username/NixOS_DotFiles/nixos/configuration.nix

ln -s /home/$username/NixOS_DotFiles/qtile /home/$username/.config/qtile

sudo nixos-rebuild switch --upgrade