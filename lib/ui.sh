#!/data/data/com.termux/files/usr/bin/bash
# Malina UI library — modern animations & effects
# Drop this file into: lib/ui.sh

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

# Bright / extra
BCYAN='\033[1;36m'
BBLUE='\033[1;34m'
BMAGENTA='\033[1;35m'
BGREEN='\033[1;32m'

# Cursor helpers
hide_cursor() { printf '\033[?25l'; }
show_cursor() { printf '\033[?25h'; }
clear_line()  { printf '\033[2K\r'; }
save_cursor() { printf '\033[s'; }
restore_cursor() { printf '\033[u'; }

# ── Logo frames (subtle wave / glow) ────────────────────
# We cycle colors across the logo lines for a soft shimmer

LOGO_LINES=(
"  ███╗   ███╗ █████╗ ██╗     ██╗███╗   ██╗ █████╗ "
"  ████╗ ████║██╔══██╗██║     ██║████╗  ██║██╔══██╗"
"  ██╔████╔██║███████║██║     ██║██╔██╗ ██║███████║"
"  ██║╚██╔╝██║██╔══██║██║     ██║██║╚██╗██║██╔══██║"
"  ██║ ╚═╝ ██║██║  ██║███████╗██║██║ ╚████║██║  ██║"
"  ╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝"
)

# Soft cyan → blue → magenta cycle
LOGO_COLORS=(
  '\033[38;5;51m'   # bright cyan
  '\033[38;5;45m'   # cyan
  '\033[38;5;39m'   # deep sky
  '\033[38;5;33m'   # blue
  '\033[38;5;99m'   # soft purple
  '\033[38;5;51m'   # back to cyan
)

print_logo_static() {
    local color="${1:-$CYAN}"
    echo -e "${color}"
    for line in "${LOGO_LINES[@]}"; do
        echo "$line"
    done
    echo -e "${NC}"
}

# Animated logo — gentle color wave (runs a few frames)
animate_logo() {
    local frames=${1:-8}
    local delay=${2:-0.07}
    hide_cursor

    for ((f=0; f<frames; f++)); do
        # Move cursor up to redraw logo in place (6 lines + 1 empty)
        if [ $f -gt 0 ]; then
            printf '\033[7A'
        fi

        for i in "${!LOGO_LINES[@]}"; do
            local color_idx=$(( (f + i) % ${#LOGO_COLORS[@]} ))
            echo -e "${LOGO_COLORS[$color_idx]}${LOGO_LINES[$i]}${NC}"
        done
        echo
        sleep "$delay"
    done
    show_cursor
}

# Single soft glow pass (nice for headers)
print_logo_glow() {
    hide_cursor
    for i in "${!LOGO_LINES[@]}"; do
        local color_idx=$(( i % ${#LOGO_COLORS[@]} ))
        echo -e "${LOGO_COLORS[$color_idx]}${LOGO_LINES[$i]}${NC}"
        sleep 0.03
    done
    echo
    show_cursor
}

print_header() {
    clear
    animate_logo 6 0.06
    echo -e "  ${DIM}v${VERSION:-1.0.0}  ·  Arduino Terminal for Termux${NC}"
    echo -e "  ${DIM}────────────────────────────────────────────${NC}"
}

print_status() {
    local board_short=$(echo "${CURRENT_FQBN:-none}" | awk -F: '{print $NF}')
    local sketch_name="none"
    [ -n "$CURRENT_SKETCH" ] && sketch_name=$(basename "$CURRENT_SKETCH")
    echo -e "  ${DIM}Board:${NC} ${GREEN}${board_short}${NC}  ${DIM}│${NC}  ${DIM}Sketch:${NC} ${CYAN}${sketch_name}${NC}"
    echo -e "  ${DIM}────────────────────────────────────────────${NC}"
}

# ── Typewriter ──────────────────────────────────────────
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

# ── Modern spinner ──────────────────────────────────────
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

# Funny status lines (Claude / Codex style)
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
    "Warming up the quartz..."
    "Negotiating with the MCU..."
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
        if [ $joke_timer -ge 22 ]; then
            current_joke=$(random_status)
            joke_timer=0
        fi
        sleep 0.08
    done
    clear_line
    show_cursor
}

# ── Status helpers ──────────────────────────────────────
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

# Soft progress bar (optional use)
progress_bar() {
    local current=$1
    local total=$2
    local width=28
    local filled=$(( current * width / total ))
    local empty=$(( width - filled ))
    printf "\r  ${CYAN}"
    printf '█%.0s' $(seq 1 $filled)
    printf "${DIM}"
    printf '░%.0s' $(seq 1 $empty)
    printf "${NC}  %3d%%" $(( current * 100 / total ))
}
