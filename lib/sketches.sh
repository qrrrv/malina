#!/data/data/com.termux/files/usr/bin/bash
# Sketch management module

new_sketch() {
    print_header
    print_status
    echo
    echo -e "  ${BOLD}New Sketch${NC}"
    echo
    echo -ne "  Name: ${GREEN}"
    read -r name
    echo -e "${NC}"

    if [ -z "$name" ]; then
        fail "Name cannot be empty"
        press_enter
        return
    fi

    # Sanitize
    name=$(echo "$name" | tr -cd '[:alnum:]_-' )

    local sketch_path="${SKETCHES_DIR}/${name}"
    if [ -d "$sketch_path" ]; then
        warn "Sketch already exists"
        press_enter
        return
    fi

    step "Creating sketch..."
    $ARDUINO_CLI sketch new "$sketch_path" > /dev/null 2>&1
    CURRENT_SKETCH="$sketch_path"
    save_config
    ok "Created ${name}"
    sleep 0.6
    info "Opening editor..."
    sleep 0.4
    edit_sketch
}

open_sketch() {
    print_header
    print_status
    echo
    echo -e "  ${BOLD}Open Sketch${NC}"
    echo

    local sketches=()
    local i=1
    for dir in "$SKETCHES_DIR"/*/; do
        [ -d "$dir" ] || continue
        local sname=$(basename "$dir")
        sketches+=("$sname")
        echo -e "  ${CYAN}${i})${NC}  ${sname}"
        i=$((i+1))
    done

    if [ ${#sketches[@]} -eq 0 ]; then
        warn "No sketches found. Create one first."
        press_enter
        return
    fi

    echo -e "  ${CYAN}0)${NC}  Back"
    echo
    echo -ne "  ${GREEN}❯${NC} "
    read -r choice

    if [ "$choice" = "0" ] || [ -z "$choice" ]; then
        return
    fi

    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le ${#sketches[@]} ]; then
        CURRENT_SKETCH="${SKETCHES_DIR}/${sketches[$((choice-1))]}"
        save_config
        ok "Opened ${sketches[$((choice-1))]}"
        sleep 0.7
    else
        fail "Invalid choice"
        sleep 0.8
    fi
}

edit_sketch() {
    if [ -z "$CURRENT_SKETCH" ] || [ ! -d "$CURRENT_SKETCH" ]; then
        fail "No sketch selected"
        press_enter
        return
    fi

    local ino_file
    ino_file=$(find "$CURRENT_SKETCH" -maxdepth 1 -name "*.ino" | head -1)

    if [ -z "$ino_file" ]; then
        fail "No .ino file found"
        press_enter
        return
    fi

    if command -v micro >/dev/null 2>&1; then
        micro "$ino_file"
    elif command -v nano >/dev/null 2>&1; then
        nano "$ino_file"
    else
        fail "No editor found (micro/nano)"
        press_enter
    fi
}
