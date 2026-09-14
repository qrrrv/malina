#!/data/data/com.termux/files/usr/bin/bash
# Upload module

upload_sketch() {
    if [ -z "$CURRENT_SKETCH" ] || [ ! -d "$CURRENT_SKETCH" ]; then
        fail "No sketch selected"
        press_enter
        return
    fi

    print_header
    print_status
    echo
    echo -e "  ${BOLD}Upload${NC}"
    echo
    echo -e "  ${YELLOW}Note:${NC} Pure USB on non-root Termux is limited."
    echo
    echo -e "  ${CYAN}1)${NC}  Try direct upload"
    echo -e "  ${CYAN}2)${NC}  TCP-bridge instructions (recommended)"
    echo -e "  ${CYAN}0)${NC}  Back"
    echo
    echo -ne "  ${GREEN}❯${NC} "
    read -r choice

    case $choice in
        1)
            echo
            step "Looking for ports..."
            $ARDUINO_CLI board list 2>/dev/null || true
            echo
            echo -ne "  Port (e.g. /dev/ttyACM0 or \$HOME/ptyACM0): ${GREEN}"
            read -r port
            echo -e "${NC}"

            if [ -z "$port" ]; then
                warn "No port specified"
                press_enter
                return
            fi

            # Expand $HOME if user typed it literally
            port="${port/\$HOME/$HOME}"

            echo
            step "Uploading..."
            $ARDUINO_CLI upload -p "$port" --fqbn "$CURRENT_FQBN" "$CURRENT_SKETCH" > /tmp/malina_upload.log 2>&1 &
            local pid=$!
            spinner_with_jokes $pid "Uploading to board"
            wait $pid
            local status=$?

            echo
            if [ $status -eq 0 ]; then
                ok "Upload successful"
            else
                fail "Upload failed"
                echo
                tail -n 10 /tmp/malina_upload.log 2>/dev/null | sed 's/^/  /'
            fi
            press_enter
            ;;
        2)
            print_header
            echo
            echo -e "  ${BOLD}TCP Bridge Method (no root)${NC}"
            echo
            typewrite "  This is the most reliable way without root." 0.008
            echo
            echo -e "  ${CYAN}1.${NC} Install app: ${BOLD}TCP UART Bridge${NC} or ${BOLD}ServerBridgeX${NC}"
            echo -e "  ${CYAN}2.${NC} Connect Arduino via OTG cable"
            echo -e "  ${CYAN}3.${NC} In the app: USB → TCP server on port ${GREEN}8080${NC}"
            echo
            echo -e "  ${CYAN}4.${NC} In Termux (another session / tmux):"
            echo -e "     ${GREEN}socat pty,link=\$HOME/ptyACM0,raw tcp:127.0.0.1:8080${NC}"
            echo
            echo -e "  ${CYAN}5.${NC} Come back here → Upload → Direct → port:"
            echo -e "     ${GREEN}\$HOME/ptyACM0${NC}"
            echo
            echo -e "  ${DIM}Tip: keep socat running while you upload.${NC}"
            press_enter
            ;;
        *) return ;;
    esac
}
