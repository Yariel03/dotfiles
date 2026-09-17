#!/bin/bash
# Colores seleccionados para un contraste fluido
L="rgba(f0e6ffff)" # Lila
R="rgba(ff0000ff)" # Rojo
angle=0

while true; do
    # Usando 2 colores para asegurar que el motor de renderizado de la 0.55 rote correctamente
    hyprctl eval "hl.config({ general = { col = { active_border = { colors = { '$R', '$L' }, angle = $angle } } } })" > /dev/null
    
    # Aumentamos el salto de ángulo y reducimos el tiempo de espera para máxima fluidez
    angle=$(( (angle + 10) % 360 ))
    sleep 0.02
done
