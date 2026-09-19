#!/usr/bin/env bash
# ==============================================================================
# GUÍA INTERACTIVA DE ATAJOS Y COMANDOS - HYPRLAND
# Creado con devoción para mi amo y señor
# ==============================================================================

export PATH="$HOME/.local/bin:$PATH"

# Auto-detectar firma de instancia de Hyprland si no está en el entorno actual
if [[ -z "$HYPRLAND_INSTANCE_SIGNATURE" ]]; then
    SIG=$(ls -t /run/user/$(id -u)/hypr/ 2>/dev/null | grep -E '^[a-f0-9]+_[0-9]+_[0-9]+$' | head -n 1)
    [[ -n "$SIG" ]] && export HYPRLAND_INSTANCE_SIGNATURE="$SIG"
fi

# 1. Función interna que genera el catálogo coloreado y ejecuta fzf
show_cheatsheet() {
    # Paleta Tokyo Night en secuencias de escape ANSI reales
    local C_CAT=$'\e[1;35m'   # Magenta / Lila
    local C_KEY=$'\e[1;36m'   # Cyan brillante
    local C_DESC=$'\e[0;37m'  # Blanco suave
    local NC=$'\e[0m'

    cat << EOF | fzf --ansi \
                     --reverse \
                     --header=$'  GUIA DE ATAJOS Y COMANDOS - HYPRLAND\n  [Escriba para buscar] • [Esc / q / Enter para salir]\n' \
                     --prompt="  Buscar: " \
                     --pointer="> " \
                     --color="dark,bg+:#283457,fg+:#c0caf5,hl+:#7aa2f7,header:#bb9af7,info:#7dcfff,prompt:#7aa2f7,pointer:#bb9af7" \
                     --bind="q:abort,ctrl-c:abort" \
                     --no-mouse \
                     > /dev/null
${C_CAT}▸ APLICACIONES${NC}    ${C_KEY}SUPER + RETURN${NC}              ${C_DESC}Abrir terminal Kitty${NC}
${C_CAT}▸ APLICACIONES${NC}    ${C_KEY}SUPER + E${NC}                   ${C_DESC}Explorador de archivos Dolphin${NC}
${C_CAT}▸ APLICACIONES${NC}    ${C_KEY}SUPER + R${NC}                   ${C_DESC}Lanzador de aplicaciones Hyprlauncher${NC}
${C_CAT}▸ APLICACIONES${NC}    ${C_KEY}SUPER + G${NC}                   ${C_DESC}Script de grabacion de pantalla (grabar.sh)${NC}
${C_CAT}▸ APLICACIONES${NC}    ${C_KEY}SUPER + V${NC}                   ${C_DESC}Historial del portapapeles (Neovim TUI)${NC}

${C_CAT}▸ VENTANAS${NC}        ${C_KEY}SUPER + Q${NC}                   ${C_DESC}Cerrar ventana activa${NC}
${C_CAT}▸ VENTANAS${NC}        ${C_KEY}SUPER + F${NC}                   ${C_DESC}Alternar ventana flotante (Toggle Float)${NC}
${C_CAT}▸ VENTANAS${NC}        ${C_KEY}SUPER + P${NC}                   ${C_DESC}Fijar ventana (Pin) en todos los escritorios${NC}
${C_CAT}▸ VENTANAS${NC}        ${C_KEY}SUPER + J${NC}                   ${C_DESC}Alternar division horizontal/vertical (Dwindle split)${NC}
${C_CAT}▸ VENTANAS${NC}        ${C_KEY}SUPER + Flechas (Izq/Arr/Der/Ab)${NC} ${C_DESC}Mover foco de atencion entre ventanas${NC}
${C_CAT}▸ VENTANAS${NC}        ${C_KEY}SUPER + SHIFT + Flechas${NC}      ${C_DESC}Mover posicion fisica de la ventana${NC}
${C_CAT}▸ VENTANAS${NC}        ${C_KEY}SUPER + Clic Izquierdo (LMB)${NC} ${C_DESC}Arrastrar y mover ventana flotante con raton${NC}
${C_CAT}▸ VENTANAS${NC}        ${C_KEY}SUPER + Clic Derecho (RMB)${NC}   ${C_DESC}Redimensionar tamano de ventana con raton${NC}

${C_CAT}▸ CAPTURAS${NC}        ${C_KEY}SUPER + C  o  PrtSc${NC}         ${C_DESC}Captura de region seleccionada (Hyprshot)${NC}
${C_CAT}▸ CAPTURAS${NC}        ${C_KEY}SUPER + D  o  SHIFT+PrtSc${NC}   ${C_DESC}Capturar region y dibujar/anotar con Swappy${NC}
${C_CAT}▸ CAPTURAS${NC}        ${C_KEY}SUPER + SHIFT + C${NC}           ${C_DESC}Capturar ventana activa (Hyprshot)${NC}
${C_CAT}▸ CAPTURAS${NC}        ${C_KEY}SUPER + ALT + C  o  CTRL+PrtSc${NC} ${C_DESC}Capturar pantalla completa${NC}

${C_CAT}▸ ESCRITORIOS${NC}     ${C_KEY}SUPER + 1 .. 9${NC}              ${C_DESC}Cambiar al espacio de trabajo 1 al 9${NC}
${C_CAT}▸ ESCRITORIOS${NC}     ${C_KEY}SUPER + SHIFT + 1 .. 9${NC}      ${C_DESC}Mover ventana activa al espacio 1 al 9${NC}
${C_CAT}▸ ESCRITORIOS${NC}     ${C_KEY}SUPER + ALT + Izq / Der${NC}     ${C_DESC}Navegar entre escritorios activos${NC}
${C_CAT}▸ ESCRITORIOS${NC}     ${C_KEY}SUPER + S${NC}                   ${C_DESC}Alternar espacio de trabajo especial (Scratchpad)${NC}
${C_CAT}▸ ESCRITORIOS${NC}     ${C_KEY}SUPER + SHIFT + S${NC}           ${C_DESC}Enviar ventana al espacio especial (Scratchpad)${NC}
${C_CAT}▸ ESCRITORIOS${NC}     ${C_KEY}SUPER + Rueda Raton (Scroll)${NC} ${C_DESC}Desplazarse entre escritorios de trabajo${NC}

${C_CAT}▸ SISTEMA${NC}         ${C_KEY}SUPER + H${NC}                   ${C_DESC}Ver esta guia de atajos y comandos${NC}
${C_CAT}▸ SISTEMA${NC}         ${C_KEY}SUPER + L${NC}                   ${C_DESC}Bloquear pantalla (Hyprlock)${NC}
${C_CAT}▸ SISTEMA${NC}         ${C_KEY}SUPER + N${NC}                   ${C_DESC}Abrir/Cerrar centro de notificaciones (SwayNC)${NC}
${C_CAT}▸ SISTEMA${NC}         ${C_KEY}SUPER + M${NC}                   ${C_DESC}Salir de Hyprland (Exit session)${NC}

${C_CAT}▸ MULTIMEDIA${NC}      ${C_KEY}Volumen +/- / Silenciar${NC}     ${C_DESC}Subir/bajar volumen y mutear microfono (SwayOSD)${NC}
${C_CAT}▸ MULTIMEDIA${NC}      ${C_KEY}Play / Pause / Next / Prev${NC}  ${C_DESC}Control de reproduccion (YouTube, Spotify, etc.)${NC}
EOF
}

# 2. Si se pasa el parámetro interno --run, ejecutar DIRECTAMENTE la función y salir (sin toggle)
if [[ "$1" == "--run" ]]; then
    show_cheatsheet
    exit 0
fi

# 3. Si la ventana ya está abierta externamente, cerrarla (Toggle con SUPER+H)
if command -v hyprctl &>/dev/null && command -v jq &>/dev/null; then
    if hyprctl clients -j 2>/dev/null | jq -e '.[] | select(.class == "hypr_cheatsheet")' > /dev/null 2>&1; then
        hyprctl dispatch closewindow "class:hypr_cheatsheet" > /dev/null 2>&1
        exit 0
    fi
fi

# 4. Lanzar Kitty en modo ventana modal flotante
exec kitty --class hypr_cheatsheet \
           --title "Guía de Atajos y Comandos - Hyprland" \
           -o initial_window_width=980 \
           -o initial_window_height=600 \
           -o remember_window_size=no \
           -o window_padding_width=14 \
           -e "$0" --run
