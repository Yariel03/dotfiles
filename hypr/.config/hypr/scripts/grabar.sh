#!/bin/zsh
# Script: grabar.sh

# 1. Crear la salida virtual
hyprctl output create headless

# Pequeña espera para que el sistema reconozca el nuevo monitor
sleep 1

# 2. Detectar el nombre del monitor headless recién creado
HEADLESS_NAME=$(hyprctl monitors | grep "Monitor HEADLESS-" | tail -n 1 | awk '{print $2}')
if [[ -z "$HEADLESS_NAME" ]]; then
    HEADLESS_NAME="HEADLESS-1"
fi

# Configurar el monitor a 1920x1080 con escala 1 usando el parser de Lua
hyprctl eval "hl.monitor({ output = '$HEADLESS_NAME', mode = '1920x1080@60', position = 'auto', scale = 1.0 })"

# Poner fondo de pantalla a la salida virtual
linux-wallpaperengine --scaling stretch --screen-root "$HEADLESS_NAME" --bg 3308404912 &

# 3. Lanzar herramientas de captura y espejo en segundo plano
wl-mirror "$HEADLESS_NAME" &

# Ejecutar tu capturador específico
# ~/Descargas/temp/mtpglvcap_linux_amd64/mtplvcap &

# 4. Lanzar OBS Studio (Una sola vez)
# Usamos 'disown' para que el script pueda terminar y dejar OBS corriendo
flatpak run com.obsproject.Studio &! 

# print "Captura configurada en HEAD eLESS-2"
