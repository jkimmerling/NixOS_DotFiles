with import <nixpkgs> {};
let

  # define packages to install with special handling for OSX
  basePackages = [
    gnumake
    gcc
    readline
    openssl
    zlib
    libxml2
    curl
    libiconv
    elixir_1_14
    erlang
    glibcLocales
    nodejs-18_x
    yarn
  ];

  inputs = basePackages
    ++ lib.optional stdenv.isLinux inotify-tools
    ++ lib.optionals stdenv.isDarwin (with darwin.apple_sdk.frameworks; [
        CoreFoundation
        CoreServices
      ]);

  # define shell startup command
  hooks = ''
    # this allows mix to work on the local directory
    mkdir -p .nix-mix
    mkdir -p .nix-hex
    export MIX_HOME=$PWD/.nix-mix
    export HEX_HOME=$PWD/.nix-hex
    export PATH=$MIX_HOME/bin:$PATH
    export PATH=$HEX_HOME/bin:$PATH
    export LIVEBOOK_HOME=$PWD
    export PATH=$MIX_HOME/escripts:$PATH
    export LANG=en_US.UTF-8
    export ERL_AFLAGS="-kernel shell_history enabled"

    if ! command -v livebook &> /dev/null
    then
      mix do local.rebar --force, local.hex --force
      mix escript.install hex --force livebook
    else
      echo "Livebook already installed, skipping installation"
    fi    

    livebook server
  '';

in mkShell {
  buildInputs = inputs;
  shellHook = hooks;
}
