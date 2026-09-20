#!/usr/bin/env bash
# Script de comprobación de actualizaciones para ashell

notify-send -a "ashell" -h string:x-canonical-private-synchronous:ashell-updates -i software-update-available -t 1500 "Actualizaciones" "Comprobando paquetes..."

updates=$(checkupdates 2>/dev/null)
status=$?

if [ $status -eq 0 ] && [ -n "$updates" ]; then
    count=$(echo "$updates" | wc -l)
    notify-send -a "ashell" -h string:x-canonical-private-synchronous:ashell-updates -i software-update-available -t 4000 "Actualizaciones" "Hay $count paquete(s) listos para actualizar"
    echo "$updates"
elif [ $status -eq 2 ] || [ -z "$updates" ]; then
    notify-send -a "ashell" -h string:x-canonical-private-synchronous:ashell-updates -i software-update-available -t 2500 "Actualizaciones" "El sistema está completamente al día"
else
    notify-send -a "ashell" -h string:x-canonical-private-synchronous:ashell-updates -i dialog-warning -t 3000 "Actualizaciones" "Error al conectar con los servidores"
fi
