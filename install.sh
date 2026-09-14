#!/data/data/com.termux/files/usr/bin/bash
# Malina installer — one command setup

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

clear
echo -e "${CYAN}"
cat << "EOF"
  ███╗   ███╗ █████╗ ██╗     ██╗███╗   ██╗ █████╗ 
  ████╗ ████║██╔══██╗██║     ██║████╗  ██║██╔══██╗
  ██╔████╔██║███████║██║     ██║██╔██╗ ██║███████║
  ██║╚██╔╝██║██╔══██║██║     ██║██║╚██╗██║██╔══██║
  ██║ ╚═╝ ██║██║  ██║███████╗██║██║ ╚████║██║  ██║
  ╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝
EOF
echo -e "${NC}"
echo -e "  ${BOLD}Arduino Terminal for Termux${NC}"
echo -e "  ${DIM}Installing...${NC}\n"

# Must be Termux
if [ ! -d "/data/data/com.termux" ]; then
    echo -e "${RED}[!] This installer is for Termux only.${NC}"
    exit 1
fi

PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"
HOME_DIR="${HOME:-/data/data/com.termux/files/home}"
INSTALL_DIR="$HOME_DIR/.malina"
BIN_DIR="$PREFIX/bin"

echo -e "  ${CYAN}→${NC}  Updating packages..."
pkg update -y >/dev/null 2>&1 || true

echo -e "  ${CYAN}→${NC}  Installing dependencies..."
pkg install -y git curl wget nano micro tar unzip 2>/dev/null || true

# Create structure
mkdir -p "$INSTALL_DIR"/{bin,lib,config,sketches}
mkdir -p "$HOME_DIR/Arduino/libraries"

# ── Install arduino-cli ─────────────────────────────────
echo -e "  ${CYAN}→${NC}  Installing arduino-cli..."

ARCH=$(uname -m)
case $ARCH in
    aarch64|arm64) CLI_ARCH="Linux_ARM64" ;;
    armv7l|armhf)  CLI_ARCH="Linux_ARMv7" ;;
    x86_64)        CLI_ARCH="Linux_64bit" ;;
    *)             CLI_ARCH="Linux_ARM64" ;;
esac

CLI_VERSION="1.2.0"
CLI_URL="https://github.com/arduino/arduino-cli/releases/download/v${CLI_VERSION}/arduino-cli_${CLI_VERSION}_${CLI_ARCH}.tar.gz"

cd /tmp
if curl -fsSL "$CLI_URL" -o arduino-cli.tar.gz 2>/dev/null; then
    tar -xzf arduino-cli.tar.gz
    mv -f arduino-cli "$INSTALL_DIR/bin/"
    chmod +x "$INSTALL_DIR/bin/arduino-cli"
    rm -f arduino-cli.tar.gz
    echo -e "  ${GREEN}✔${NC}  arduino-cli installed"
else
    echo -e "  ${YELLOW}!${NC}  Binary download failed, trying official script..."
    curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | BINDIR="$INSTALL_DIR/bin" sh
fi

# ── Copy Malina files ───────────────────────────────────
# When run from a cloned repo / extracted zip this script
# lives next to bin/ lib/ etc. When run via curl we need
# another way — for now we assume the full project is present
# or the user extracted the zip.

SCRIPT_PATH="$(realpath "$0" 2>/dev/null || echo "$0")"
PROJECT_ROOT="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"

if [ -d "$PROJECT_ROOT/lib" ] && [ -f "$PROJECT_ROOT/bin/malina" ]; then
    echo -e "  ${CYAN}→${NC}  Copying Malina files..."
    cp -f "$PROJECT_ROOT/bin/malina"          "$INSTALL_DIR/bin/"
    cp -f "$PROJECT_ROOT/lib/"*.sh            "$INSTALL_DIR/lib/"
    cp -f "$PROJECT_ROOT/config/default.conf" "$INSTALL_DIR/config/" 2>/dev/null || true
    cp -f "$PROJECT_ROOT/VERSION"             "$INSTALL_DIR/" 2>/dev/null || echo "1.0.0" > "$INSTALL_DIR/VERSION"
    chmod +x "$INSTALL_DIR/bin/malina"
    chmod +x "$INSTALL_DIR/lib/"*.sh
else
    echo -e "  ${YELLOW}!${NC}  Project files not found next to installer."
    echo -e "     Make sure you extracted the full zip or cloned the repo."
    exit 1
fi

# Symlink into PATH
ln -sf "$INSTALL_DIR/bin/malina" "$BIN_DIR/malina"

# PATH helper
if ! grep -q '\.malina/bin' "$HOME_DIR/.bashrc" 2>/dev/null; then
    echo '' >> "$HOME_DIR/.bashrc"
    echo '# Malina' >> "$HOME_DIR/.bashrc"
    echo 'export PATH="$HOME/.malina/bin:$PATH"' >> "$HOME_DIR/.bashrc"
fi

# Init arduino-cli
echo -e "  ${CYAN}→${NC}  Configuring arduino-cli..."
"$INSTALL_DIR/bin/arduino-cli" config init --overwrite >/dev/null 2>&1 || true
"$INSTALL_DIR/bin/arduino-cli" core update-index >/dev/null 2>&1 || true

echo -e "  ${CYAN}→${NC}  Installing Arduino AVR core..."
"$INSTALL_DIR/bin/arduino-cli" core install arduino:avr >/dev/null 2>&1 || {
    echo -e "  ${YELLOW}!${NC}  AVR core will be installed on first use"
}

echo
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo -e "${GREEN}  Malina installed successfully!${NC}"
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo
echo -e "  Run:  ${CYAN}malina${NC}"
echo
echo -e "  ${DIM}Sketches → ~/.malina/sketches${NC}"
echo -e "  ${DIM}Restart Termux or: source ~/.bashrc${NC}"
echo
echo -e "  ${CYAN}Enjoy. 🍓${NC}"
echo
