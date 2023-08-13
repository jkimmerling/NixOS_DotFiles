let
  pkgs = import <nixpkgs> {};

  unstable = import <nixos-unstable> {config = { allowUnfree = true};};

in pkgs.mkShell rec {
  name = "anytype";

  buildInputs = wit pkgs; [
    libsecret
    appimage-run
  ];

  shellHook = ''
    p="/nix/store/$(ls /nix/store | grep libsecret | grep -v ".drv$" | head -n 1)/lib"
    echo "using LD_LIBRARY_PATH: $p"
    export LD_LIBRARY_PATH="$p"
  '';
}