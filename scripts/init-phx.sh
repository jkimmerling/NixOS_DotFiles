#!/usr/bin/env bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

PROJECT_NAME="$1"
CURRENT_DIR="$PWD"

# Template path
TEMPLATE_DIR="$HOME/Dot_Files/flake_templates/dev/elixir"

usage() {
  echo "Usage: init-phx <project_name> [mix phx.new options...]"
  echo ""
  echo "Creates a new Phoenix project with Nix flake template and git setup."
  echo "All arguments after project_name are passed directly to 'mix phx.new'."
  echo ""
  echo "Examples:"
  echo "  init-phx my_app                           # Full Phoenix app with LiveView"
  echo "  init-phx my_app --no-ecto                 # Without database"
  echo "  init-phx my_app --database sqlite3        # With SQLite"
  echo "  init-phx my_api --no-html --no-assets     # API-only app"
  echo "  init-phx my_app --live                    # LiveView app (default)"
  exit 1
}

if [ -z "$PROJECT_NAME" ]; then
  echo -e "${RED}Error: Project name is required${NC}"
  usage
fi

echo -e "${GREEN}🚀 Initializing Phoenix project: $PROJECT_NAME${NC}"
echo ""

# Create project directory
if [ -d "$PROJECT_NAME" ]; then
  echo -e "${RED}Error: Directory '$PROJECT_NAME' already exists${NC}"
  exit 1
fi

# Create the Phoenix project using mix phx.new
echo -e "${YELLOW}🏗️  Creating Phoenix project...${NC}"
if ! command -v mix &> /dev/null; then
  echo -e "${YELLOW}⚠️  Mix not found. Loading Nix environment...${NC}"
  nix develop "$TEMPLATE_DIR#default" --command mix phx.new "$@"
else
  mix phx.new "$@"
fi

# Enter project directory
cd "$PROJECT_NAME"

# Copy template files
echo -e "${YELLOW}📋 Copying Nix template files...${NC}"
cp "$TEMPLATE_DIR/flake.nix" .
cp "$TEMPLATE_DIR/.envrc" .
cp "$TEMPLATE_DIR/README.md" .

# Phoenix creates its own .formatter.exs with proper config, so we don't overwrite it

# Update .gitignore to include Nix-specific entries
if [ -f ".gitignore" ]; then
  # Append Nix entries if they don't exist
  if ! grep -q "# Nix" .gitignore; then
    cat >> .gitignore << 'EOF'

# Nix
.nix-shell/
result
result-*
.direnv/
EOF
  fi
else
  # Create comprehensive .gitignore if Phoenix didn't create one
  cat > .gitignore << 'EOF'
# Elixir
/_build
/cover
/deps
/doc
/.fetch
erl_crash.dump
*.ez
*.beam
/config/*.secret.exs
.elixir_ls/

# Phoenix
/priv/static/
/priv/cert/
npm-debug.log
/assets/node_modules/

# Database
postgres_data/
*.db
*.db-shm
*.db-wal

# Nix
.nix-shell/
result
result-*
.direnv/

# Environment
.env
.env.local

# IDEs
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db
EOF
fi

# Create docker-compose reference file
cat > docker-compose.yml << EOF
# Quick reference to docker services
# Start PostgreSQL: docker-compose -f ~/Dot_Files/docker/postgres/docker-compose.yml up -d
# Start Redis: docker-compose -f ~/Dot_Files/docker/redis/docker-compose.yml up -d

# Or create symlinks:
# ln -s ~/Dot_Files/docker/postgres/docker-compose.yml docker-compose.postgres.yml
# ln -s ~/Dot_Files/docker/redis/docker-compose.yml docker-compose.redis.yml
EOF

# Initialize git (if not already initialized by Phoenix)
if [ ! -d ".git" ]; then
  echo -e "${YELLOW}📦 Initializing git repository...${NC}"
  git init
fi

git add .

# Setup direnv
echo -e "${YELLOW}🔧 Setting up direnv...${NC}"
if command -v direnv &> /dev/null; then
  direnv allow
else
  echo -e "${YELLOW}⚠️  direnv not found. Run 'direnv allow' after installation.${NC}"
fi

# Initial git commit
git commit -m "Initial commit: Phoenix project setup

🧪 Generated with init-phx
- Phoenix/Elixir development environment
- Nix flake for reproducible builds
- Docker-ready configuration
"

echo ""
echo -e "${GREEN}✅ Project initialized successfully!${NC}"
echo ""
echo -e "${GREEN}📍 Next steps:${NC}"
echo "   cd $PROJECT_NAME"
echo ""
echo "   # Start databases (if using Ecto)"
echo "   docker-compose -f ~/Dot_Files/docker/postgres/docker-compose.yml up -d"
echo "   docker-compose -f ~/Dot_Files/docker/redis/docker-compose.yml up -d"
echo ""
echo "   # Setup database"
echo "   mix ecto.create"
echo "   mix ecto.migrate"
echo ""
echo "   # Install dependencies"
echo "   mix deps.get"
echo ""
echo "   # Start server"
echo "   mix phx.server"
echo ""
echo "   # Visit: http://localhost:4000"
echo ""
echo -e "${GREEN}Happy coding! 🎉${NC}"
