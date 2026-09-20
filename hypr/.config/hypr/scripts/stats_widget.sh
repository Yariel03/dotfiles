#!/usr/bin/env bash
# Script para alternar o iniciar el Widget de Estado (Quickshell Stats)
set -euo pipefail

if pkill -f 'quickshell.*widgets' 2>/dev/null; then
    exit 0
fi

WIDGETS_DIR="$HOME/.config/hypr/widgets"

if ! command -v quickshell >/dev/null 2>&1; then
    notify-send -u critical "Stats Widget" "Quickshell no está instalado. Ejecuta: sudo pacman -S quickshell"
    exit 1
fi

exec quickshell -c "$WIDGETS_DIR"
