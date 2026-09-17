local hl = hl

hl.config({
	binds = {
		scroll_event_delay = 300,
	},
	gestures = {
		workspace_swipe_distance = 700,
		workspace_swipe_cancel_ratio = 0.2,
		workspace_swipe_min_speed_to_force = 5,
		workspace_swipe_direction_lock = true,
		workspace_swipe_direction_lock_threshold = 10,
		workspace_swipe_create_new = true,
	},
	general = {
		-- Gaps and border
		col = {
			active_border = {
				colors = { "rgba(bb9af7ff)", "rgba(9d7cd8ff)", "rgba(ff007cff)", "rgba(7aa2f7ff)" },
				angle = 0,
			},
		},
		gaps_in = 5,
		gaps_out = 15,
		-- gaps_workspaces = 50,

		border_size = 4,

		resize_on_border = true,

		no_focus_fallback = true,
		allow_tearing = true, -- This just allows the `immediate` window rule to work
	},

	animations = {
		enabled = true,
		bezier = {
			{ name = "linear", x0 = 0, y0 = 0, x1 = 1, y1 = 1 },
		},
	},

	dwindle = {
		force_split = 2,
		preserve_split = true,
		smart_split = false,
		smart_resizing = true,

		-- precise_mouse_move = true,
	},

	misc = {
		disable_hyprland_logo = true,
		force_default_wallpaper = 0,
	},
})

-- Animación nativa de ángulo de borde en bucle
hl.animation({
	leaf = "borderangle",
	enabled = true,
	speed = 30,
	bezier = "linear",
	style = "loop",
})
