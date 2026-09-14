#!/data/data/com.termux/files/usr/bin/bash
# Board selection module

select_board() {
    print_header
    print_status
    echo
    echo -e "  ${BOLD}Select Board${NC}"
    echo
    echo -e "  ${CYAN}1)${NC}  Arduino Uno"
    echo -e "  ${CYAN}2)${NC}  Arduino Nano"
    echo -e "  ${CYAN}3)${NC}  Arduino Mega 2560"
    echo -e "  ${CYAN}4)${NC}  Arduino Leonardo"
    echo -e "  ${CYAN}5)${NC}  Arduino Pro Mini"
    echo -e "  ${CYAN}6)${NC}  ESP32 Dev Module"
    echo -e "  ${CYAN}7)${NC}  ESP8266 NodeMCU"
    echo -e "  ${CYAN}0)${NC}  Back"
    echo
    echo -ne "  ${GREEN}❯${NC} "
    read -r choice

    case $choice in
        1) CURRENT_FQBN="arduino:avr:uno" ;;
        2) CURRENT_FQBN="arduino:avr:nano" ;;
        3) CURRENT_FQBN="arduino:avr:mega" ;;
        4) CURRENT_FQBN="arduino:avr:leonardo" ;;
        5) CURRENT_FQBN="arduino:avr:pro" ;;
        6)
            CURRENT_FQBN="esp32:esp32:esp32"
            step "Ensuring ESP32 core is installed..."
            $ARDUINO_CLI core install esp32:esp32 > /tmp/malina_core.log 2>&1 &
            spinner $! "Installing ESP32 core..."
            ;;
        7)
            CURRENT_FQBN="esp8266:esp8266:nodemcuv2"
            step "Ensuring ESP8266 core is installed..."
            $ARDUINO_CLI core install esp8266:esp8266 > /tmp/malina_core.log 2>&1 &
            spinner $! "Installing ESP8266 core..."
            ;;
        0) return ;;
        *)
            fail "Invalid choice"
            sleep 0.8
            return
            ;;
    esac

    save_config
    ok "Board set to ${CURRENT_FQBN}"
    sleep 0.9
}
