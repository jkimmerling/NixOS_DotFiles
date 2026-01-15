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
  echo "Usage: init-elixir <project_name> [mix new options...]"
  echo ""
  echo "Creates a new Elixir project with Nix flake template and git setup."
  echo "All arguments after project_name are passed directly to 'mix new'."
  echo ""
  echo "Examples:"
  echo "  init-elixir my_app                    # Basic Elixir app"
  echo "  init-elixir my_app --sup              # With supervision tree"
  echo "  init-elixir my_app --umbrella         # Umbrella project"
  echo "  init-elixir my_lib --module MyLib     # Custom module name"
  exit 1
}

if [ -z "$PROJECT_NAME" ]; then
  echo -e "${RED}Error: Project name is required${NC}"
  usage
fi

echo -e "${GREEN}🚀 Initializing Elixir project: $PROJECT_NAME${NC}"
echo ""

# Create project directory
if [ -d "$PROJECT_NAME" ]; then
  echo -e "${RED}Error: Directory '$PROJECT_NAME' already exists${NC}"
  exit 1
fi

# Create the Elixir project using mix new
echo -e "${YELLOW}🏗️  Creating Elixir project...${NC}"
if ! command -v mix &> /dev/null; then
  echo -e "${YELLOW}⚠️  Mix not found. Loading Nix environment...${NC}"
  nix develop "$TEMPLATE_DIR#default" --command mix new "$@"
else
  mix new "$@"
fi

# Enter project directory
cd "$PROJECT_NAME"

# Copy template files
echo -e "${YELLOW}📋 Copying Nix template files...${NC}"
cp "$TEMPLATE_DIR/flake.nix" .
cp "$TEMPLATE_DIR/.envrc" .
cp "$TEMPLATE_DIR/README.md" .

# Use the .formatter.exs that mix created, or copy template if it doesn't exist
if [ ! -f ".formatter.exs" ]; then
  cp "$TEMPLATE_DIR/.formatter.exs" .
fi

# Create comprehensive .gitignore
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

# Database
*.db
*.db-shm
*.db-wal
EOF

# Initialize git
echo -e "${YELLOW}📦 Initializing git repository...${NC}"
git init
git add .

# Setup direnv
echo -e "${YELLOW}🔧 Setting up direnv...${NC}"
if command -v direnv &> /dev/null; then
  direnv allow
else
  echo -e "${YELLOW}⚠️  direnv not found. Run 'direnv allow' after installation.${NC}"
fi

# Initial git commit
git commit -m "Initial commit: Elixir project setup

🧪 Generated with init-elixir
- Elixir development environment
- Nix flake for reproducible builds
"

echo ""
echo -e "${GREEN}✅ Project initialized successfully!${NC}"
echo ""
echo -e "${GREEN}📍 Next steps:${NC}"
echo "   cd $PROJECT_NAME"
echo ""
echo "   # Install dependencies"
echo "   mix deps.get"
echo ""
echo "   # Run tests"
echo "   mix test"
echo ""
echo -e "${GREEN}Happy coding! 🎉${NC}"
