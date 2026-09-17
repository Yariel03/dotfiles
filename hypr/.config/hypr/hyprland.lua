-- Configuración principal de Hyprland en Lua
-- Organizada por módulos en la carpeta ~/.config/hypr/modulos/

local hl = hl

-- Cargar variables de entorno
require("modulos.env")

-- Configuración de monitores
require("modulos.monitors")

-- Configuración general (gestos, gaps, etc.)
require("modulos.config")

-- Atajos de teclado y mouse
require("modulos.keybinds")

-- Comandos de inicio (Autostart)
require("modulos.autostart")


 
