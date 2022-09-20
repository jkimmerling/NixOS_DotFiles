#!/bin/sh
nm-applet &
thunar --daemon &
blueman-applet &
feh --recursive --bg-scale --randomize ~/NixOS_DotFiles/Wallpapers/* &
picom &
flameshot &
