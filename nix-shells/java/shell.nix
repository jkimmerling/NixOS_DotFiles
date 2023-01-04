{ pkgs ? import <nixpkgs> {} }:

let
  # get a normalized set of packages, from which
  # we will install all the needed dependencies
  # pkgs = import ./pkgs.nix { inherit jdk; };
  # pkgs = { import <nixpkgs> inherit jdk; };
  jdk = "jdk11";
in
  pkgs.mkShell {
    buildInputs = [
      pkgs.${jdk}
      pkgs.gradle
      pkgs.jq
      pkgs.kubectl
      pkgs.kustomize
      pkgs.terraform_1
      pkgs.clojure
      pkgs.leiningen
    ];
    shellHook = ''
      export NIX_ENV=dev
    '';
   

  }