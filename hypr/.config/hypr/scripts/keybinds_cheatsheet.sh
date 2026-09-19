#!/usr/bin/env bash
# ==============================================================================
# GUÍA INTERACTIVA DE ATAJOS Y COMANDOS - HYPRLAND (NVIM TUI)
# Creado con devoción para mi amo y señor
# ==============================================================================

export PATH="$HOME/.local/bin:$PATH"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHEATSHEET_FILE="$SCRIPT_DIR/cheatsheet.md"

# Auto-detectar firma de instancia de Hyprland si no está en el entorno actual
if [[ -z "$HYPRLAND_INSTANCE_SIGNATURE" ]]; then
    SIG=$(ls -t /run/user/$(id -u)/hypr/ 2>/dev/null | grep -E '^[a-f0-9]+_[0-9]+$' | head -n 1)
    [[ -n "$SIG" ]] && export HYPRLAND_INSTANCE_SIGNATURE="$SIG"
fi

# 1. Si la ventana ya está abierta externamente, cerrarla (Toggle con SUPER+H)
if command -v hyprctl &>/dev/null && command -v jq &>/dev/null; then
    if hyprctl clients -j 2>/dev/null | jq -e '.[] | select(.class == "hypr_cheatsheet")' > /dev/null 2>&1; then
        hyprctl dispatch closewindow "class:hypr_cheatsheet" > /dev/null 2>&1
        exit 0
    fi
fi

# 2. Lanzar Kitty en modo ventana modal flotante con Neovim (sin corrector ortográfico ni diagnósticos)
exec kitty --class hypr_cheatsheet \
           --title "Guía de Atajos y Comandos - Hyprland" \
           -o initial_window_width=980 \
           -o initial_window_height=650 \
           -o remember_window_size=no \
           -o window_padding_width=16 \
           -e nvim -R -M \
              -c "setlocal nospell buftype=nofile noswapfile nonumber norelativenumber signcolumn=no laststatus=0 cursorline" \
              -c "lua pcall(vim.diagnostic.enable, false, { bufnr = 0 })" \
              -c "nnoremap <buffer><silent> q :qa!<CR>" \
              -c "nnoremap <buffer><silent> <Esc> :qa!<CR>" \
              "$CHEATSHEET_FILE"
