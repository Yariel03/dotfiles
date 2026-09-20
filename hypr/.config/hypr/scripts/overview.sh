#!/usr/bin/env bash
# Script para alternar la vista de escritorios (Quickshell Overview estilo Ryoku)
set -euo pipefail

# Si ya está en ejecución, cerrarlo inmediatamente
if pkill -f 'quickshell.*overview' 2>/dev/null; then
    exit 0
fi

OVERVIEW_DIR="$HOME/.config/hypr/overview"

if ! command -v quickshell >/dev/null 2>&1; then
    notify-send -u critical "Ryoku Overview" "Quickshell no está instalado. Ejecuta: sudo pacman -S quickshell"
    exit 1
fi

exec quickshell -c "$OVERVIEW_DIR"
