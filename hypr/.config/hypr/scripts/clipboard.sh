#!/usr/bin/env bash

# Export paths so wtype, cliphist, wl-copy, etc. are always found
export PATH="$HOME/.local/bin:$PATH"

# Auto-detect Hyprland instance signature if not present in current env
if [[ -z "$HYPRLAND_INSTANCE_SIGNATURE" ]]; then
    SIG=$(ls -t /run/user/$(id -u)/hypr/ 2>/dev/null | grep -E '^[a-f0-9]+_[0-9]+_[0-9]+$' | head -n 1)
    [[ -n "$SIG" ]] && export HYPRLAND_INSTANCE_SIGNATURE="$SIG"
fi

# Clean previous selection file
rm -f /dev/shm/clip_selected

# 1. Record the active window class and address before opening the clipboard picker
ACTIVE_WIN=$(hyprctl activewindow -j 2>/dev/null)
CLASS=$(echo "$ACTIVE_WIN" | jq -r '.class // empty' 2>/dev/null)
ADDR=$(echo "$ACTIVE_WIN" | jq -r '.address // empty' 2>/dev/null)

# 2. Launch Kitty floating modal Neovim TUI
kitty --class clip_picker \
      --title "Portapapeles" \
      -o initial_window_width=950 \
      -o initial_window_height=580 \
      -o remember_window_size=no \
      -o window_padding_width=12 \
      -e "$HOME/.config/hypr/scripts/clip_tui_rs_bin" "$CLASS" "$ADDR"

# 3. If an item was chosen (written to /dev/shm/clip_selected), decode, copy and paste
if [[ -f /dev/shm/clip_selected ]]; then
    # Decode directly into Wayland clipboard without blocking TUI
    cliphist decode < /dev/shm/clip_selected | wl-copy
    rm -f /dev/shm/clip_selected

    # Wait for the picker window to unmap and focus to return to original window
    sleep 0.18

    # Simulate paste keystroke based on application type
    case "$CLASS" in
        kitty|Alacritty|foot|ghostty|konsole|wezterm|org.gnome.Terminal|xterm|rxvt*|Terminator)
            wtype -M ctrl -M shift -k v -m shift -m ctrl
            ;;
        *)
            wtype -M ctrl -k v -m ctrl
            ;;
    esac
fi
