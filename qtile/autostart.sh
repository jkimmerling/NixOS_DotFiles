#!/bin/sh
brightnessctl --device='tpacpi::kbd_backlight' set 2 &
nm-applet &
thunar --daemon &
blueman-applet &
feh --recursive --bg-scale --randomize ~/NixOS_DotFiles/Wallpapers/* &
picom &
flameshot &
xdg-settings set default-web-browser firefox.desktop
