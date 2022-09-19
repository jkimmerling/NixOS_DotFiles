#!/bin/sh
mount /dev/nvme0n1p1 /home/jasonk/drive_1
mount /dev/nvme1n1p1 /home/jasonk/drive_1
nm-applet &
blueman-applet &
feh --recursive --bg-scale --randomize ~/NixOS_DotFiles/Wallpapers/* &
picom &
