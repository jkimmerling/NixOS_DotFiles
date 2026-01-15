# Elixir/Phoenix Development Template

This template provides a complete Nix-based development environment for Elixir and Phoenix projects.

## What's Included

- **Elixir 1.18** on Erlang/OTP 28
- **PostgreSQL 16** - Primary database
- **Redis** - Caching and sessions
- **Node.js 24** - For Phoenix asset compilation
- **inotify-tools** - For Phoenix live reload
- Automatic environment setup via direnv

## Quick Start

### Option 1: Using `init-elixir` Command

```bash
# Create a new Phoenix project
init-elixir my_app phoenix

# Create a new Elixir library
init-elixir my_lib library

# Create an umbrella project
init-elixir my_umbrella umbrella
```

### Option 2: Manual Setup

```bash
# Create project directory
mkdir my_app && cd my_app

# Copy template files
nix flake init -t ~/Dot_Files/flake_templates/dev/elixir

# Allow direnv
direnv allow

# Create Phoenix app
mix phx.new . --app my_app

# Start services (if using docker)
docker-compose -f ~/Dot_Files/docker/postgres/docker-compose.yml up -d
docker-compose -f ~/Dot_Files/docker/redis/docker-compose.yml up -d

# Setup database
mix ecto.create
mix ecto.migrate

# Start server
mix phx.server
```

## Project Structure

```
my_app/
├── flake.nix           # Nix development environment
├── .envrc              # Direnv configuration
├── .formatter.exs      # Elixir code formatter config
├── mix.exs             # Project dependencies
├── config/             # Application configuration
├── lib/                # Application code
├── test/               # Tests
└── .nix-shell/         # Local Nix shell data (gitignored)
```

## Environment Variables

The template sets up:

- `MIX_HOME` - Mix cache directory
- `HEX_HOME` - Hex cache directory
- `PGDATA` - PostgreSQL data directory
- `PGHOST` - PostgreSQL socket directory

Add custom variables to `.env` file (which is loaded by `.envrc`):

```bash
# .env
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/myapp_dev
SECRET_KEY_BASE=your-secret-key-base
```

## Database Setup

### Using Docker (Recommended)

```bash
# Start PostgreSQL
docker-compose -f ~/Dot_Files/docker/postgres/docker-compose.yml up -d

# Access from your app
# Host: localhost:5432
# Container-to-container: postgres:5432
```

### Using Local PostgreSQL

The flake sets up local PostgreSQL in `.nix-shell/postgres`:

```bash
initdb
pg_ctl start
createdb myapp_dev
```

## Common Commands

```bash
# Install dependencies
mix deps.get

# Run tests
mix test

# Run tests with coverage
mix test --cover

# Format code
mix format

# Start interactive shell
iex -S mix

# Start Phoenix server
mix phx.server

# Create database
mix ecto.create

# Run migrations
mix ecto.migrate

# Generate migration
mix ecto.gen.migration add_users_table
```

## IDE Setup

### VS Code

The development environment works automatically with VS Code when you have:
- ElixirLS extension
- Phoenix Framework extension

### Other Editors

Make sure to enable direnv integration for automatic environment loading.

## Troubleshooting

### "mix: command not found"

```bash
# Make sure direnv is allowed
direnv allow
```

### PostgreSQL connection errors

```bash
# Check if PostgreSQL is running
docker ps

# Or check local PostgreSQL
pg_ctl status
```

### Asset compilation errors

```bash
# Install Node dependencies
cd assets && npm install
```

## Next Steps

1. Read the [Phoenix Guides](https://hexdocs.pm/phoenix/overview.html)
2. Check out [Elixir School](https://elixirschool.com/)
3. Join the [Elixir Forum](https://elixirforum.com/)

## Customization

Edit `flake.nix` to add additional packages:

```nix
buildInputs = with pkgs; [
  # ... existing packages ...
  imagemagick  # For image processing
  ffmpeg       # For video processing
];
```
