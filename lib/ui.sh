#!/data/data/com.termux/files/usr/bin/bash
# Malina UI library — colors, animations, modern CLI effects

# ── Colors ──────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'
BG='\033[40m'

# Cursor helpers
hide_cursor() { printf '\033[?25l'; }
show_cursor() { printf '\033[?25h'; }
clear_line()  { printf '\033[2K\r'; }

# ── Logo ────────────────────────────────────────────────
print_logo() {
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
}

print_header() {
    clear
    print_logo
    echo -e "  ${DIM}v${VERSION}  ·  Arduino Terminal for Termux${NC}"
    echo -e "  ${DIM}────────────────────────────────────────────${NC}"
}

print_status() {
    local board_short=$(echo "${CURRENT_FQBN:-none}" | awk -F: '{print $NF}')
    local sketch_name="none"
    [ -n "$CURRENT_SKETCH" ] && sketch_name=$(basename "$CURRENT_SKETCH")
    echo -e "  ${DIM}Board:${NC} ${GREEN}${board_short}${NC}  ${DIM}│${NC}  ${DIM}Sketch:${NC} ${CYAN}${sketch_name}${NC}"
    echo -e "  ${DIM}────────────────────────────────────────────${NC}"
}

# ── Typewriter effect ───────────────────────────────────
typewrite() {
    local text="$1"
    local delay="${2:-0.012}"
    local i=0
    while [ $i -lt ${#text} ]; do
        printf "%s" "${text:$i:1}"
        sleep "$delay"
        i=$((i+1))
    done
    echo
}

# ── Spinner ─────────────────────────────────────────────
# Modern braille spinner like Claude / Codex style
SPINNER_FRAMES=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')

spinner() {
    local pid=$1
    local message="${2:-Working}"
    local i=0
    hide_cursor
    while kill -0 "$pid" 2>/dev/null; do
        printf "\r  ${CYAN}${SPINNER_FRAMES[$i]}${NC}  ${message}"
        i=$(( (i + 1) % ${#SPINNER_FRAMES[@]} ))
        sleep 0.08
    done
    clear_line
    show_cursor
}

# Spinner with random funny statuses (like modern AI CLIs)
FUNNY_STATUS=(
    "Compiling the matrix..."
    "Talking to the silicon..."
    "Waking up the AVR..."
    "Asking the bootloader nicely..."
    "Counting electrons..."
    "Brewing some hex..."
    "Aligning the bits..."
    "Petting the watchdog..."
    "Convincing the fuses..."
    "Almost there, promise..."
    "Summoning avrdude..."
    "Checking the vibes..."
)

random_status() {
    echo "${FUNNY_STATUS[$RANDOM % ${#FUNNY_STATUS[@]}]}"
}

spinner_with_jokes() {
    local pid=$1
    local base_msg="${2:-Working}"
    local i=0
    local joke_timer=0
    local current_joke=$(random_status)
    hide_cursor
    while kill -0 "$pid" 2>/dev/null; do
        printf "\r  ${CYAN}${SPINNER_FRAMES[$i]}${NC}  ${current_joke}   "
        i=$(( (i + 1) % ${#SPINNER_FRAMES[@]} ))
        joke_timer=$((joke_timer + 1))
        if [ $joke_timer -ge 25 ]; then
            current_joke=$(random_status)
            joke_timer=0
        fi
        sleep 0.08
    done
    clear_line
    show_cursor
}

# ── Progress / Status messages ──────────────────────────
ok() {
    echo -e "  ${GREEN}✔${NC}  $1"
}

fail() {
    echo -e "  ${RED}✖${NC}  $1"
}

info() {
    echo -e "  ${CYAN}→${NC}  $1"
}

warn() {
    echo -e "  ${YELLOW}!${NC}  $1"
}

step() {
    echo -e "  ${MAGENTA}▸${NC}  $1"
}

press_enter() {
    echo
    echo -e "  ${DIM}Press Enter to continue...${NC}"
    read -r
}

# ── Fancy box ───────────────────────────────────────────
box() {
    local title="$1"
    local width=44
    echo -e "  ${DIM}┌$(printf '─%.0s' $(seq 1 $width))┐${NC}"
    printf "  ${DIM}│${NC} %-$((width-2))s ${DIM}│${NC}\n" "$title"
    echo -e "  ${DIM}└$(printf '─%.0s' $(seq 1 $width))┘${NC}"
}
