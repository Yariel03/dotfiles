#!/usr/bin/env python3
import curses
import os
import subprocess
import sys
import time

# Ensure ESCDELAY is minimal so ESC key triggers immediately without delay
os.environ.setdefault("ESCDELAY", "25")


def get_cliphist_items():
    """Retrieve items from cliphist."""
    try:
        res = subprocess.run(
            ["cliphist", "list"], capture_output=True, text=True, check=True
        )
        return [line for line in res.stdout.splitlines() if line.strip()]
    except Exception:
        return []


def delete_cliphist_item(item_line):
    """Delete single item from cliphist using the full raw line."""
    try:
        subprocess.run(
            ["cliphist", "delete"],
            input=(item_line + "\n").encode("utf-8"),
            check=True,
        )
        return True
    except Exception:
        return False


def wipe_cliphist():
    """Wipe entire cliphist history and clear clipboard."""
    try:
        subprocess.run(["cliphist", "wipe"], check=True)
        subprocess.run(["wl-copy", "--clear"], check=True)
        return True
    except Exception:
        return False


def decode_cliphist_item(item_line):
    """Decode an item to raw content or return preview description."""
    try:
        res = subprocess.run(
            ["cliphist", "decode"],
            input=(item_line + "\n").encode("utf-8"),
            capture_output=True,
            timeout=1.0,
        )
        # Check if binary / image
        if b"\x00" in res.stdout[:500] or b"PNG" in res.stdout[:8] or b"JFIF" in res.stdout[:8]:
            return "🖼️  [Datos binarios / Imagen - Lista para ser pegada]"
        return res.stdout.decode("utf-8", errors="replace")
    except Exception:
        return ""


def safe_addstr(win, y, x, text, attr=0):
    """Safely print a string within window bounds without throwing curses error."""
    try:
        max_y, max_x = win.getmaxyx()
        if y < 0 or y >= max_y or x < 0 or x >= max_x:
            return
        avail = max_x - x
        if len(text) > avail:
            text = text[:avail]
        win.addstr(y, x, text, attr)
    except curses.error:
        pass


def main(stdscr):
    # Terminal setup
    curses.raw()
    stdscr.keypad(True)
    curses.curs_set(0)

    # Color initialization
    try:
        curses.use_default_colors()
        bg = -1
    except Exception:
        bg = curses.COLOR_BLACK

    curses.init_pair(1, curses.COLOR_CYAN, bg)      # Accent / Header
    curses.init_pair(2, curses.COLOR_MAGENTA, bg)   # Purple / Border
    curses.init_pair(3, curses.COLOR_GREEN, bg)     # Normal mode
    curses.init_pair(4, curses.COLOR_YELLOW, bg)    # Insert mode
    curses.init_pair(5, curses.COLOR_RED, bg)       # Delete / Warning
    curses.init_pair(6, curses.COLOR_BLACK, curses.COLOR_CYAN)    # Selected item
    curses.init_pair(7, curses.COLOR_BLACK, curses.COLOR_GREEN)   # Normal status tag
    curses.init_pair(8, curses.COLOR_BLACK, curses.COLOR_YELLOW)  # Insert status tag

    # State variables
    mode = "NORMAL"  # "NORMAL" or "INSERT"
    all_items = get_cliphist_items()
    search_query = ""
    filtered_items = list(all_items)
    selected_idx = 0
    scroll_offset = 0
    status_msg = ""
    status_msg_time = 0.0

    preview_cache = {}

    def filter_items():
        nonlocal filtered_items, selected_idx, scroll_offset
        if not search_query.strip():
            filtered_items = list(all_items)
        else:
            q_lower = search_query.lower()
            tokens = q_lower.split()
            filtered_items = [
                it for it in all_items
                if all(tok in it.lower() for tok in tokens)
            ]
        if selected_idx >= len(filtered_items):
            selected_idx = max(0, len(filtered_items) - 1)
        scroll_offset = 0

    while True:
        max_y, max_x = stdscr.getmaxyx()
        stdscr.erase()

        # Layout calculation
        # 0: Header
        # 1: Search bar
        # 2: Divider
        # 3 .. list_end: Items list
        # list_end + 1: Divider
        # list_end + 2 .. max_y - 3: Preview box
        # max_y - 2: Divider
        # max_y - 1: Status bar

        preview_height = max(4, min(7, max_y // 4))
        list_start_y = 3
        list_height = max(3, max_y - preview_height - 6)
        list_end_y = list_start_y + list_height

        # 1. Header
        header_left = " ⚡ PORTAPAPELES (NEOVIM)"
        count_str = f"[{selected_idx + 1}/{len(filtered_items)}] " if filtered_items else "[0/0] "
        safe_addstr(stdscr, 0, 0, header_left, curses.color_pair(1) | curses.A_BOLD)
        safe_addstr(stdscr, 0, max(0, max_x - len(count_str) - 1), count_str, curses.color_pair(2) | curses.A_BOLD)

        # 2. Search bar
        if mode == "INSERT":
            search_prefix = " 🔍 / "
            safe_addstr(stdscr, 1, 0, search_prefix, curses.color_pair(4) | curses.A_BOLD)
            safe_addstr(stdscr, 1, len(search_prefix), search_query, curses.A_BOLD)
        else:
            if search_query:
                search_display = f"    / {search_query}"
            else:
                search_display = "    / [presiona 'i' para buscar...]"
            safe_addstr(stdscr, 1, 0, search_display, curses.color_pair(1))

        # Divider
        safe_addstr(stdscr, 2, 0, "─" * (max_x - 1), curses.color_pair(2))

        # Adjust scroll offset so selected item is always visible
        if selected_idx < scroll_offset:
            scroll_offset = selected_idx
        elif selected_idx >= scroll_offset + list_height:
            scroll_offset = selected_idx - list_height + 1

        # 3. Items list
        if not filtered_items:
            empty_msg = "  (No hay elementos que coincidan)"
            safe_addstr(stdscr, list_start_y, 0, empty_msg, curses.A_DIM)
        else:
            for row in range(list_height):
                item_idx = scroll_offset + row
                if item_idx >= len(filtered_items):
                    break
                y_pos = list_start_y + row
                raw_item = filtered_items[item_idx]

                # Format item
                # Raw item starts with '<id>\t<text>'
                parts = raw_item.split("\t", 1)
                item_id = parts[0].strip()
                item_text = parts[1].strip() if len(parts) > 1 else ""

                is_selected = (item_idx == selected_idx)
                prefix = " ▸ " if is_selected else "   "
                display_line = f"{prefix}[{item_id:>3}]  {item_text}"

                if is_selected:
                    # Fill entire row with selection color
                    padded_line = display_line.ljust(max_x - 1)
                    safe_addstr(stdscr, y_pos, 0, padded_line, curses.color_pair(6) | curses.A_BOLD)
                else:
                    safe_addstr(stdscr, y_pos, 0, display_line)

        # 4. Preview Divider
        preview_div_y = list_end_y
        preview_title = "─── Vista Previa ──────────────────────────────────────────"
        safe_addstr(stdscr, preview_div_y, 0, preview_title[:max_x - 1], curses.color_pair(2))

        # 5. Preview Content
        preview_start_y = preview_div_y + 1
        if filtered_items and 0 <= selected_idx < len(filtered_items):
            curr_item = filtered_items[selected_idx]
            parts = curr_item.split("\t", 1)
            curr_id = parts[0].strip()

            if curr_id not in preview_cache:
                preview_cache[curr_id] = decode_cliphist_item(curr_item)

            preview_text = preview_cache.get(curr_id, "")
            prev_lines = preview_text.splitlines()[:preview_height - 1]
            for p_row, p_line in enumerate(prev_lines):
                safe_addstr(stdscr, preview_start_y + p_row, 2, p_line, curses.A_DIM)
        else:
            safe_addstr(stdscr, preview_start_y, 2, "Sin selección", curses.A_DIM)

        # 6. Bottom Divider
        status_div_y = max_y - 2
        safe_addstr(stdscr, status_div_y, 0, "─" * (max_x - 1), curses.color_pair(2))

        # 7. Status bar
        status_y = max_y - 1
        if time.time() - status_msg_time < 3.0 and status_msg:
            # Show temporary status message
            safe_addstr(stdscr, status_y, 1, f"💡 {status_msg}", curses.color_pair(5) | curses.A_BOLD)
        else:
            if mode == "NORMAL":
                mode_tag = " NORMAL "
                help_text = " i: buscar | j/k: mover | b: borrar | B: borrar todo | Enter: pegar | Esc: salir"
                safe_addstr(stdscr, status_y, 1, mode_tag, curses.color_pair(7) | curses.A_BOLD)
                safe_addstr(stdscr, status_y, len(mode_tag) + 2, help_text, curses.A_DIM)
            else:
                mode_tag = " INSERT "
                help_text = " Esc: modo normal | Enter: pegar selección | ↓/↑: navegar | Ctrl+u: limpiar"
                safe_addstr(stdscr, status_y, 1, mode_tag, curses.color_pair(8) | curses.A_BOLD)
                safe_addstr(stdscr, status_y, len(mode_tag) + 2, help_text, curses.A_DIM)

        # Update cursor visibility and position
        if mode == "INSERT":
            curses.curs_set(1)
            cursor_x = min(len(" 🔍 / ") + len(search_query), max_x - 2)
            stdscr.move(1, cursor_x)
        else:
            curses.curs_set(0)

        stdscr.refresh()

        # Key Input Handling
        try:
            key = stdscr.getch()
        except KeyboardInterrupt:
            return False

        if key == -1:
            continue

        if key == curses.KEY_RESIZE:
            continue

        # ==================== NORMAL MODE ====================
        if mode == "NORMAL":
            # Enter INSERT mode
            if key in (ord('i'), ord('/')):
                mode = "INSERT"
                continue

            # Navigation
            elif key in (ord('j'), curses.KEY_DOWN):
                if filtered_items:
                    selected_idx = min(selected_idx + 1, len(filtered_items) - 1)
            elif key in (ord('k'), curses.KEY_UP):
                if filtered_items:
                    selected_idx = max(0, selected_idx - 1)
            elif key in (ord('g'), curses.KEY_HOME):
                selected_idx = 0
            elif key in (ord('G'), curses.KEY_END):
                if filtered_items:
                    selected_idx = len(filtered_items) - 1
            elif key == 4:  # Ctrl + d (half page down)
                if filtered_items:
                    selected_idx = min(selected_idx + list_height // 2, len(filtered_items) - 1)
            elif key == 21:  # Ctrl + u (half page up)
                if filtered_items:
                    selected_idx = max(0, selected_idx - list_height // 2)

            # Delete single item with 'b' (or 'd' / 'x')
            elif key in (ord('b'), ord('d'), ord('x')):
                if filtered_items and 0 <= selected_idx < len(filtered_items):
                    item_to_delete = filtered_items[selected_idx]
                    if delete_cliphist_item(item_to_delete):
                        # Remove from all_items
                        if item_to_delete in all_items:
                            all_items.remove(item_to_delete)
                        filter_items()
                        status_msg = "Elemento eliminado del historial"
                        status_msg_time = time.time()
                    else:
                        status_msg = "Error al eliminar elemento"
                        status_msg_time = time.time()

            # Wipe all history with 'B' (or 'D')
            elif key in (ord('B'), ord('D')):
                safe_addstr(stdscr, status_y, 0, " " * (max_x - 1))
                prompt_confirm = " ⚠️  ¿Borrar TODO el historial? (s/n): "
                safe_addstr(stdscr, status_y, 0, prompt_confirm, curses.color_pair(5) | curses.A_BOLD)
                stdscr.refresh()
                curses.curs_set(1)
                conf_key = stdscr.getch()
                curses.curs_set(0)
                if conf_key in (ord('s'), ord('S'), ord('y'), ord('Y')):
                    wipe_cliphist()
                    all_items.clear()
                    filtered_items.clear()
                    selected_idx = 0
                    preview_cache.clear()
                    status_msg = "Historial vaciado por completo"
                    status_msg_time = time.time()
                else:
                    status_msg = "Operación cancelada"
                    status_msg_time = time.time()

            # Paste selected item with Enter
            elif key in (10, 13, curses.KEY_ENTER):
                if filtered_items and 0 <= selected_idx < len(filtered_items):
                    chosen = filtered_items[selected_idx]
                    # Decode directly into wl-copy
                    subprocess.run(
                        ["cliphist", "decode"],
                        input=(chosen + "\n").encode("utf-8"),
                        stdout=subprocess.PIPE,
                    )
                    # Pipe decode to wl-copy
                    p_dec = subprocess.Popen(
                        ["cliphist", "decode"],
                        stdin=subprocess.PIPE,
                        stdout=subprocess.PIPE,
                    )
                    p_copy = subprocess.Popen(["wl-copy"], stdin=p_dec.stdout)
                    p_dec.stdin.write((chosen + "\n").encode("utf-8"))
                    p_dec.stdin.close()
                    p_copy.wait()
                    return True

            # Exit / Cancel with Esc or q
            elif key in (27, ord('q')):
                return False

        # ==================== INSERT MODE ====================
        elif mode == "INSERT":
            # Exit INSERT mode back to NORMAL mode with Esc
            if key == 27:
                mode = "NORMAL"
                continue

            # Paste current selection with Enter
            elif key in (10, 13, curses.KEY_ENTER):
                if filtered_items and 0 <= selected_idx < len(filtered_items):
                    chosen = filtered_items[selected_idx]
                    p_dec = subprocess.Popen(
                        ["cliphist", "decode"],
                        stdin=subprocess.PIPE,
                        stdout=subprocess.PIPE,
                    )
                    p_copy = subprocess.Popen(["wl-copy"], stdin=p_dec.stdout)
                    p_dec.stdin.write((chosen + "\n").encode("utf-8"))
                    p_dec.stdin.close()
                    p_copy.wait()
                    return True

            # Backspace
            elif key in (curses.KEY_BACKSPACE, 127, 8):
                if search_query:
                    search_query = search_query[:-1]
                    filter_items()

            # Ctrl + u (clear search bar)
            elif key == 21:
                search_query = ""
                filter_items()

            # Ctrl + w (delete word)
            elif key == 23:
                search_query = " ".join(search_query.rstrip().split()[:-1])
                filter_items()

            # Navigate while searching
            elif key in (curses.KEY_DOWN, 14):  # Down or Ctrl+n
                if filtered_items:
                    selected_idx = min(selected_idx + 1, len(filtered_items) - 1)
            elif key in (curses.KEY_UP, 16):    # Up or Ctrl+p
                if filtered_items:
                    selected_idx = max(0, selected_idx - 1)

            # Printable characters
            elif 32 <= key <= 126:
                search_query += chr(key)
                filter_items()


if __name__ == "__main__":
    target_class = sys.argv[1] if len(sys.argv) > 1 else ""
    target_addr = sys.argv[2] if len(sys.argv) > 2 else ""

    pasted = curses.wrapper(main)

    if pasted:
        # Exit code 0 indicates an item was selected and copied
        sys.exit(0)
    else:
        # Exit code 1 indicates cancellation
        sys.exit(1)
