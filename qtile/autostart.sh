#!/bin/sh
mount /dev/nvme0n1p1 /home/jasonk/drive_1
mount /dev/nvme1n1p1 /home/jasonk/drive_1
nm-applet &
feh --bg-scale ~/Wallpapers/Cthulhu/the_great_old_one_by_jjcanvas_da8z3ns.jpg &
# wal -R &
picom &

# optimus-manager-qt &

wal -i Wallpapers/Cthulhu/the_great_old_one_by_jjcanvas_da8z3ns.jpg &
cat ~/.cache/wal/sequences &
