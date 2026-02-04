#!/bin/bash
# Inner Loop Ralph - Setup Script
# Installs beads and verifies prerequisites

set -e

echo "=== Inner Loop Ralph Setup ==="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

success() { echo -e "${GREEN}✓${NC} $1"; }
warn() { echo -e "${YELLOW}!${NC} $1"; }
error() { echo -e "${RED}✗${NC} $1"; }

# Check for Claude Code (check common locations since it might be aliased)
echo "Checking prerequisites..."
CLAUDE_BIN=""
if command -v claude &> /dev/null; then
    CLAUDE_BIN=$(command -v claude)
elif [ -x "$HOME/.claude/local/claude" ]; then
    CLAUDE_BIN="$HOME/.claude/local/claude"
elif [ -x "/usr/local/bin/claude" ]; then
    CLAUDE_BIN="/usr/local/bin/claude"
fi

if [ -n "$CLAUDE_BIN" ]; then
    success "Claude Code found: $CLAUDE_BIN"
else
    error "Claude Code not found"
    echo "  Install from: https://docs.anthropic.com/en/docs/claude-code"
    exit 1
fi

# Check for git
if command -v git &> /dev/null; then
    success "Git found"
else
    error "Git not found - required for beads"
    exit 1
fi

# Check for beads
if command -v bd &> /dev/null; then
    success "Beads already installed: $(bd --version 2>/dev/null | head -1)"
    BEADS_INSTALLED=true
else
    warn "Beads not found - will install"
    BEADS_INSTALLED=false
fi

# Install beads if needed
if [ "$BEADS_INSTALLED" = false ]; then
    echo ""
    echo "Installing beads..."

    # Detect OS and architecture
    OS=$(uname -s | tr '[:upper:]' '[:lower:]')
    ARCH=$(uname -m)

    case "$ARCH" in
        x86_64) ARCH="amd64" ;;
        aarch64|arm64) ARCH="arm64" ;;
        *) error "Unsupported architecture: $ARCH"; exit 1 ;;
    esac

    case "$OS" in
        darwin|linux) ;;
        *) error "Unsupported OS: $OS"; exit 1 ;;
    esac

    # Get latest version
    echo "  Fetching latest beads release..."
    LATEST=$(curl -s https://api.github.com/repos/steveyegge/beads/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
    VERSION=${LATEST#v}  # Remove 'v' prefix

    if [ -z "$VERSION" ]; then
        error "Could not determine latest beads version"
        echo "  Try manual install: https://github.com/steveyegge/beads/releases"
        exit 1
    fi

    echo "  Latest version: $VERSION"

    # Download
    FILENAME="beads_${VERSION}_${OS}_${ARCH}.tar.gz"
    URL="https://github.com/steveyegge/beads/releases/download/v${VERSION}/${FILENAME}"

    echo "  Downloading $FILENAME..."
    TMPDIR=$(mktemp -d)
    curl -sL "$URL" -o "$TMPDIR/$FILENAME"

    if [ ! -f "$TMPDIR/$FILENAME" ]; then
        error "Download failed"
        exit 1
    fi

    # Extract
    echo "  Extracting..."
    tar -xzf "$TMPDIR/$FILENAME" -C "$TMPDIR"

    # Install to ~/.local/bin
    INSTALL_DIR="$HOME/.local/bin"
    mkdir -p "$INSTALL_DIR"

    mv "$TMPDIR/bd" "$INSTALL_DIR/bd"
    chmod +x "$INSTALL_DIR/bd"

    # Cleanup
    rm -rf "$TMPDIR"

    # Check if in PATH
    if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
        warn "Add to your PATH: export PATH=\"\$HOME/.local/bin:\$PATH\""
        echo "  Add this to your ~/.bashrc or ~/.zshrc"
        export PATH="$INSTALL_DIR:$PATH"
    fi

    success "Beads installed to $INSTALL_DIR/bd"
fi

# Verify beads works
echo ""
echo "Verifying installation..."
if bd --version &> /dev/null; then
    success "Beads working: $(bd --version 2>/dev/null | head -1)"
else
    error "Beads installation failed"
    exit 1
fi

# Summary
echo ""
echo "=== Setup Complete ==="
echo ""
echo "Next step - copy the skill:"
echo ""
echo "  mkdir -p ~/.claude/skills"
echo "  cp -r \$(dirname \$0)/../skills/inner-loop-ralph ~/.claude/skills/"
echo ""
echo "Then try it (no restart needed):"
echo "  /inner-loop-ralph --dry-run plan a weekend trip"
echo ""
