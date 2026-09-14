#!/data/data/com.termux/files/usr/bin/bash
# Libraries module

install_library() {
    print_header
    print_status
    echo
    echo -e "  ${BOLD}Install Library from GitHub${NC}"
    echo
    echo -e "  Paste full GitHub URL"
    echo -e "  ${DIM}Example: https://github.com/adafruit/Adafruit_NeoPixel${NC}"
    echo
    echo -ne "  ${GREEN}❯${NC} "
    read -r url

    if [ -z "$url" ]; then
        return
    fi

    echo
    step "Installing library..."
    $ARDUINO_CLI lib install --git-url "$url" > /tmp/malina_lib.log 2>&1 &
    local pid=$!
    spinner $pid "Fetching from GitHub..."
    wait $pid
    local status=$?

    echo
    if [ $status -eq 0 ]; then
        ok "Library installed via arduino-cli"
    else
        warn "arduino-cli method failed, trying git clone..."
        local repo_name
        repo_name=$(basename "$url" .git)
        mkdir -p "$LIBRARIES_DIR"
        if git clone --depth 1 "$url" "$LIBRARIES_DIR/$repo_name" > /tmp/malina_lib.log 2>&1; then
            ok "Library cloned to ~/Arduino/libraries/${repo_name}"
        else
            fail "Failed to install library"
            tail -n 6 /tmp/malina_lib.log 2>/dev/null | sed 's/^/  /'
        fi
    fi
    press_enter
}

list_libraries() {
    print_header
    print_status
    echo
    echo -e "  ${BOLD}Installed Libraries${NC}"
    echo
    $ARDUINO_CLI lib list 2>/dev/null || echo -e "  ${DIM}No libraries found or arduino-cli error${NC}"
    press_enter
}
