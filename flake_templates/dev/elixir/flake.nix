{
  description = "Elixir/Phoenix development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          # Elixir/Erlang
          beam.packages.erlang_28.elixir_1_18
          beam.packages.erlang_28.erlang

          # Database & Cache
          postgresql_16
          redis

          # Build tools
          inotify-tools  # For Phoenix live reload
          nodejs_24      # For Phoenix assets

          # Development tools
          git
        ];

        shellHook = ''
          # Create local directories for development databases
          mkdir -p .nix-shell
          export PGDATA="$PWD/.nix-shell/postgres"
          export PGHOST="$PWD/.nix-shell/postgres"
          export PGPORT=5432

          # Set up Mix environment
          export MIX_HOME="$PWD/.nix-shell/mix"
          export HEX_HOME="$PWD/.nix-shell/hex"

          # Phoenix setup
          export POOL_SIZE=15

          echo "🧪 Elixir development environment loaded!"
          echo ""
          echo "📦 Installed:"
          echo "   - Elixir $(elixir --version | grep Elixir)"
          echo "   - Erlang $(erl -eval 'erlang:display(erlang:system_info(otp_release)), halt().' -noshell)"
          echo "   - PostgreSQL $(postgres --version | awk '{print $3}')"
          echo "   - Node.js $(node --version)"
          echo ""
          echo "💡 Quick start:"
          echo "   - Create Phoenix app: mix phx.new ."
          echo "   - Start databases: docker-compose up -d (if using docker)"
          echo "   - Run tests: mix test"
          echo "   - Start server: mix phx.server"
          echo ""
        '';
      };
    };
}
