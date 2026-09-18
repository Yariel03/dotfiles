local hl = hl
local mainMod = "SUPER"

-- hl.bind("SUPER + Q", hl.dsp.window.close(), { description = "cerrar ventanas" })
hl.bind(mainMod .. " + Q", hl.dsp.window.close(), { description = "cerrar ventanas" })
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd("kitty"), { description = "Open my favourite terminal" })
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("hyprlauncher"), { description = "Open my favourite terminal" })
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("dolphin"), { description = "Open my favourite terminal" })
hl.bind(mainMod .. " + G", hl.dsp.exec_cmd("~/.config/hypr/scripts/grabar.sh"), { description = "Grabar pantalla" })
-- Capturas de pantalla con Hyprshot y Swappy (Optimizado para Corne y tecla Print)
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd("hyprshot -m region --freeze"), { description = "Captura de región seleccionada" })
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("hyprshot -m region --raw --freeze | swappy -f -"), { description = "Capturar y dibujar con Swappy" })
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd("hyprshot -m window --freeze"), { description = "Captura de ventana" })
hl.bind(mainMod .. " + ALT + C", hl.dsp.exec_cmd("hyprshot -m output"), { description = "Captura de pantalla completa" })
hl.bind("Print", hl.dsp.exec_cmd("hyprshot -m region --freeze"), { description = "Captura de región con PrtSc" })
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("hyprshot -m region --raw --freeze | swappy -f -"), { description = "Capturar y dibujar con Swappy (PrtSc)" })
hl.bind("CTRL + Print", hl.dsp.exec_cmd("hyprshot -m output"), { description = "Captura de pantalla completa con PrtSc" })
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock"), { description = "Bloquear pantalla" })
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("swaync-client -t -sw"), { description = "Abrir/Cerrar centro de notificaciones" })

-- Window focus movement (SUPER + Arrows)
hl.bind(mainMod .. " + LEFT", hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + RIGHT", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + UP", hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + DOWN", hl.dsp.focus({ direction = "d" }))

-- Window movement (SUPER + SHIFT + Arrows)
hl.bind(mainMod .. " + SHIFT + LEFT", hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + RIGHT", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + UP", hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + DOWN", hl.dsp.window.move({ direction = "d" }))

-- Toggle Floating (SUPER + F)
hl.bind(mainMod .. " + F", hl.dsp.window.float({ action = "toggle" }), { description = "Alternar ventana flotante" })

-- Historial del Portapapeles (SUPER + V) con Neovim TUI y Auto-pegar
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("~/.config/hypr/scripts/clipboard.sh"), { description = "Historial del portapapeles (Neovim TUI)" })

-- Toggle Split (SUPER + J) - Alterna división horizontal/vertical en Dwindle
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"), { description = "Toggle split orientation" })

-- Pin Window (SUPER + P) - Requiere que la ventana sea flotante
hl.bind(mainMod .. " + P", hl.dsp.window.pin({ action = "toggle" }), { description = "Pin window to all workspaces" })

-- Workspace switching (SUPER + ALT + Arrows)
hl.bind(mainMod .. " + ALT + LEFT", hl.dsp.focus({ workspace = "m-1" }))
hl.bind(mainMod .. " + ALT + RIGHT", hl.dsp.focus({ workspace = "m+1" }))

-- Numeric Workspaces (SUPER + 1-9)
for i = 1, 9 do
	hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

-- Special Workspace (Scratchpad)
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special())
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special" }))

-- Mouse wheel workspace scrolling (SUPER + Scroll)
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))

-- Move/Resize windows with SUPER + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind(mainMod .. " + M", hl.dsp.exit(), { description = "Exit Hyprland" })

-- Control de volumen y micrófono con SwayOSD
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("swayosd-client --output-volume raise --max-volume 150"),
	{ repeating = true, locked = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("swayosd-client --output-volume lower --max-volume 150"),
	{ repeating = true, locked = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("swayosd-client --output-volume mute-toggle"),
	{ locked = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("swayosd-client --input-volume mute-toggle"),
	{ locked = true }
)

-- Control Multimedia con SwayOSD (Play/Pause, Next, Prev) para YouTube, Spotify y Zen Browser
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("swayosd-client --playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("swayosd-client --playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("swayosd-client --playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("swayosd-client --playerctl prev"), { locked = true })
