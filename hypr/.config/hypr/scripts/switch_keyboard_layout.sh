#!/usr/bin/env bash
# Auto-detect Hyprland signature if not present
if [ -z "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
    HYPRLAND_INSTANCE_SIGNATURE=$(ls -t /run/user/$(id -u)/hypr/ 2>/dev/null | grep -E '^[^.]+$' | head -n 1)
    export HYPRLAND_INSTANCE_SIGNATURE
fi

# Switch layout on all keyboards to the next configured layout
hyprctl switchxkblayout all next >/dev/null 2>&1

# Query active keymap dynamically and notify via SwayOSD and notify-send
python3 -c '
import json, subprocess

try:
    out = subprocess.check_output(["hyprctl", "-j", "devices"]).decode("utf-8", "ignore")
    data = json.loads(out)
    keyboards = data.get("keyboards", [])
    main_kb = next((k for k in keyboards if k.get("main")), None) or (keyboards[0] if keyboards else {})
    keymap = main_kb.get("active_keymap", "Desconocido")

    # Map friendly names / flags, while supporting any dynamic future layout automatically
    flags = {
        "English (US)": "🇺🇸 English (US)",
        "English (US, intl., with dead keys)": "🇺🇸 English (Intl)",
        "Spanish (Latin American)": "🌎 Español (Latam)",
        "Spanish": "🇪🇸 Español (España)",
        "French": "🇫🇷 Français",
        "German": "🇩🇪 Deutsch",
        "Portuguese": "🇧🇷 Português",
        "Japanese": "🇯🇵 日本語",
        "Russian": "🇷🇺 Русский",
        "Italian": "🇮🇹 Italiano",
    }
    display = flags.get(keymap, f"⌨️ {keymap}")

    # 1. SwayOSD overlay banner
    subprocess.run(["swayosd-client", "--custom-message", display, "--custom-icon", "input-keyboard"], check=False)

    # 2. Synchronous desktop notification (replaces existing notification)
    subprocess.run(["notify-send", "-a", "hyprland", "-h", "string:x-canonical-private-synchronous:keyboard-layout", "-i", "input-keyboard", "-t", "1500", "Idioma del Teclado", display], check=False)
except Exception:
    pass
'
