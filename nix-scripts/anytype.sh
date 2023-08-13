#! /usr/bin/env nix-shell
#! nix-shell -i bash -p bash appimage-run libsecret

p="/nix/store/$(ls /nix/store | grep libsecret | grep -v ".drv$" | head -n 1)/lib"

echo "using LD_LIBRARY_PATH: $p"

env LD_LIBRARY_PATH="$p" appimage-run /home/jasonk/app_images/Anytype-0.33.2.AppImage