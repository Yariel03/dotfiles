local hl = hl
local home = os.getenv("HOME") or "/home/yariel"

-- Autostart commands
hl.on("hyprland.start", function()
	hl.dispatch(hl.dsp.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP QT_QPA_PLATFORMTHEME GTK_THEME"))
	hl.dispatch(hl.dsp.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1"))
	hl.dispatch(hl.dsp.exec_cmd("linux-wallpaperengine --scaling stretch --screen-root DP-2 --bg 3308404912"))
	hl.dispatch(hl.dsp.exec_cmd("ashell"))
	hl.dispatch(hl.dsp.exec_cmd("hypridle"))
	hl.dispatch(hl.dsp.exec_cmd("swaync"))
	hl.dispatch(hl.dsp.exec_cmd("swayosd-server"))
	hl.dispatch(hl.dsp.exec_cmd("wl-paste --type text --watch cliphist store"))
	hl.dispatch(hl.dsp.exec_cmd("wl-paste --type image --watch cliphist store"))
	hl.dispatch(hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/stats_widget.sh"))
end)
