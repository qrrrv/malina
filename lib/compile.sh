#!/data/data/com.termux/files/usr/bin/bash
# Compile module

compile_sketch() {
    if [ -z "$CURRENT_SKETCH" ] || [ ! -d "$CURRENT_SKETCH" ]; then
        fail "No sketch selected"
        press_enter
        return
    fi

    print_header
    print_status
    echo
    echo -e "  ${BOLD}Compile${NC}"
    echo

    step "Starting compilation..."
    echo

    # Run compile in background so we can show spinner + jokes
    $ARDUINO_CLI compile --fqbn "$CURRENT_FQBN" "$CURRENT_SKETCH" > /tmp/malina_compile.log 2>&1 &
    local pid=$!
    spinner_with_jokes $pid "Compiling"
    wait $pid
    local status=$?

    echo
    if [ $status -eq 0 ]; then
        ok "Compilation successful"
        # Show short summary if available
        if grep -q "Sketch uses" /tmp/malina_compile.log 2>/dev/null; then
            echo
            grep -E "Sketch uses|Global variables" /tmp/malina_compile.log | while read -r line; do
                echo -e "  ${DIM}${line}${NC}"
            done
        fi
    else
        fail "Compilation failed"
        echo
        echo -e "  ${DIM}── last lines of log ──${NC}"
        tail -n 12 /tmp/malina_compile.log 2>/dev/null | sed 's/^/  /'
    fi

    press_enter
}
