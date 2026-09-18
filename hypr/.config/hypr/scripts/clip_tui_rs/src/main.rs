use std::{
    collections::HashMap,
    io::{self, Write},
    process::{Command, Stdio},
    time::{Duration, Instant},
};

use crossterm::{
    event::{self, Event, KeyCode, KeyEventKind, KeyModifiers},
    execute,
    terminal::{disable_raw_mode, enable_raw_mode, EnterAlternateScreen, LeaveAlternateScreen},
};
use ratatui::{
    backend::CrosstermBackend,
    layout::{Constraint, Direction, Layout},
    style::{Color, Modifier, Style},
    text::{Line, Span},
    widgets::{Block, BorderType, Borders, List, ListItem, ListState, Paragraph},
    Terminal,
};

#[derive(PartialEq, Eq)]
enum Mode {
    Normal,
    Insert,
    ConfirmWipe,
}

fn get_cliphist_items() -> Vec<String> {
    if let Ok(output) = Command::new("cliphist").arg("list").output() {
        if output.status.success() {
            let stdout = String::from_utf8_lossy(&output.stdout);
            return stdout
                .lines()
                .filter(|l| !l.trim().is_empty())
                .map(|l| l.to_string())
                .collect();
        }
    }
    Vec::new()
}

fn delete_cliphist_item(item: &str) -> bool {
    let mut child = match Command::new("cliphist")
        .arg("delete")
        .stdin(Stdio::piped())
        .spawn()
    {
        Ok(c) => c,
        Err(_) => return false,
    };

    if let Some(mut stdin) = child.stdin.take() {
        let _ = stdin.write_all(item.as_bytes());
        let _ = stdin.write_all(b"\n");
    }

    child.wait().map(|s| s.success()).unwrap_or(false)
}

fn wipe_cliphist() -> bool {
    let w_res = Command::new("cliphist").arg("wipe").status();
    let _ = Command::new("wl-copy").arg("--clear").status();
    w_res.map(|s| s.success()).unwrap_or(false)
}

fn select_item_for_paste(item: &str) -> bool {
    std::fs::write("/dev/shm/clip_selected", item.as_bytes()).is_ok()
}

fn decode_preview(item: &str) -> String {
    let mut decode_proc = match Command::new("cliphist")
        .arg("decode")
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .spawn()
    {
        Ok(p) => p,
        Err(_) => return String::from(""),
    };

    if let Some(mut stdin) = decode_proc.stdin.take() {
        let _ = stdin.write_all(item.as_bytes());
        let _ = stdin.write_all(b"\n");
    }

    let decode_out = match decode_proc.wait_with_output() {
        Ok(o) => o.stdout,
        Err(_) => return String::from(""),
    };

    let is_binary = decode_out.iter().take(400).any(|&b| b == 0)
        || decode_out.starts_with(b"\x89PNG")
        || decode_out.starts_with(b"\xFF\xD8");

    if is_binary {
        String::from("🖼️  [Datos binarios / Imagen - Lista para ser pegada]")
    } else {
        String::from_utf8_lossy(&decode_out).to_string()
    }
}

fn main() -> io::Result<()> {
    // 1. Setup terminal in raw mode
    enable_raw_mode()?;
    let mut stdout = io::stdout();
    execute!(stdout, EnterAlternateScreen)?;
    let backend = CrosstermBackend::new(stdout);
    let mut terminal = Terminal::new(backend)?;

    // Tokyo Night palette
    let c_purple = Color::Rgb(187, 154, 247); // #bb9af7
    let c_blue = Color::Rgb(122, 162, 247);   // #7aa2f7
    let c_green = Color::Rgb(158, 206, 106);  // #9ece6a
    let c_yellow = Color::Rgb(224, 175, 104); // #e0af68
    let c_red = Color::Rgb(247, 118, 142);    // #f7768e
    let c_dim = Color::Rgb(86, 95, 137);      // #565f89
    let c_sel_bg = Color::Rgb(51, 70, 124);   // #33467c

    let mut mode = Mode::Normal;
    let mut all_items = get_cliphist_items();
    let mut search_query = String::new();
    let mut filtered_items = all_items.clone();
    let mut selected_idx = 0usize;
    let mut list_state = ListState::default();
    list_state.select(Some(0));

    let mut preview_cache: HashMap<String, String> = HashMap::new();
    let mut status_msg = String::new();
    let mut status_msg_time = Instant::now() - Duration::from_secs(10);
    let mut chosen_to_paste = false;

    let filter = |query: &str, items: &[String]| -> Vec<String> {
        if query.trim().is_empty() {
            return items.to_vec();
        }
        let q_lower = query.to_lowercase();
        let tokens: Vec<&str> = q_lower.split_whitespace().collect();
        items
            .iter()
            .filter(|it| {
                let it_lower = it.to_lowercase();
                tokens.iter().all(|tok| it_lower.contains(tok))
            })
            .cloned()
            .collect()
    };

    loop {
        // Draw TUI
        terminal.draw(|f| {
            let chunks = Layout::default()
                .direction(Direction::Vertical)
                .constraints([
                    Constraint::Length(3), // Header & Search Box
                    Constraint::Min(6),    // History List
                    Constraint::Length(6), // Preview Box
                    Constraint::Length(1), // Status Line
                ])
                .split(f.area());

            // 1. Search Box & Header
            let count_info = if filtered_items.is_empty() {
                "[0/0]".to_string()
            } else {
                format!("[{}/{}]", selected_idx + 1, filtered_items.len())
            };

            let search_title = match mode {
                Mode::Normal => format!(" ⚡ PORTAPAPELES (NEOVIM - RUST)  {} ", count_info),
                Mode::Insert => format!(" ⚡ BÚSQUEDA (INSERT)  {} ", count_info),
                Mode::ConfirmWipe => format!(" ⚠️ CONFIRMACIÓN  {} ", count_info),
            };

            let search_border_color = match mode {
                Mode::Normal => c_purple,
                Mode::Insert => c_yellow,
                Mode::ConfirmWipe => c_red,
            };

            let search_text = if mode == Mode::Insert {
                format!(" 🔍 / {}█", search_query)
            } else if !search_query.is_empty() {
                format!("    / {}", search_query)
            } else {
                "    / [presiona 'i' para buscar...]".to_string()
            };

            let search_widget = Paragraph::new(search_text)
                .style(Style::default().fg(match mode {
                    Mode::Insert => Color::White,
                    _ => c_blue,
                }))
                .block(
                    Block::default()
                        .borders(Borders::ALL)
                        .border_type(BorderType::Rounded)
                        .border_style(Style::default().fg(search_border_color))
                        .title(Span::styled(
                            search_title,
                            Style::default().fg(c_purple).add_modifier(Modifier::BOLD),
                        )),
                );
            f.render_widget(search_widget, chunks[0]);

            // 2. Items List
            let items: Vec<ListItem> = filtered_items
                .iter()
                .enumerate()
                .map(|(i, raw_item)| {
                    let mut parts = raw_item.splitn(2, '\t');
                    let id = parts.next().unwrap_or("").trim();
                    let content = parts.next().unwrap_or("").trim();

                    let is_sel = i == selected_idx;
                    let prefix = if is_sel { " ▸ " } else { "   " };
                    let line_text = format!("{}[{:>3}]  {}", prefix, id, content);

                    let item_style = if is_sel {
                        Style::default()
                            .fg(Color::White)
                            .bg(c_sel_bg)
                            .add_modifier(Modifier::BOLD)
                    } else {
                        Style::default().fg(Color::Rgb(169, 177, 214))
                    };

                    ListItem::new(Line::from(line_text)).style(item_style)
                })
                .collect();

            let list_block = Block::default()
                .borders(Borders::ALL)
                .border_type(BorderType::Rounded)
                .border_style(Style::default().fg(c_purple))
                .title(Span::styled(
                    " Historial de Comandos y Copias ",
                    Style::default().fg(c_purple).add_modifier(Modifier::BOLD),
                ));

            let list_widget = List::new(items)
                .block(list_block)
                .highlight_style(Style::default().bg(c_sel_bg));

            f.render_stateful_widget(list_widget, chunks[1], &mut list_state);

            // 3. Preview Box
            let preview_content = if !filtered_items.is_empty() && selected_idx < filtered_items.len() {
                let curr_item = &filtered_items[selected_idx];
                let id = curr_item.split('\t').next().unwrap_or("").trim();
                preview_cache
                    .entry(id.to_string())
                    .or_insert_with(|| decode_preview(curr_item))
                    .as_str()
            } else {
                "Sin selección"
            };

            let preview_widget = Paragraph::new(preview_content)
                .style(Style::default().fg(Color::Rgb(192, 202, 245)))
                .block(
                    Block::default()
                        .borders(Borders::ALL)
                        .border_type(BorderType::Rounded)
                        .border_style(Style::default().fg(c_purple))
                        .title(Span::styled(
                            " Vista Previa Decodificada ",
                            Style::default().fg(c_blue).add_modifier(Modifier::BOLD),
                        )),
                );
            f.render_widget(preview_widget, chunks[2]);

            // 4. Status Bar
            let is_showing_msg = status_msg_time.elapsed() < Duration::from_secs(3);
            let status_line = if is_showing_msg {
                Line::from(vec![
                    Span::styled(" 💡 ", Style::default().fg(c_yellow)),
                    Span::styled(
                        &status_msg,
                        Style::default().fg(Color::White).add_modifier(Modifier::BOLD),
                    ),
                ])
            } else {
                match mode {
                    Mode::Normal => Line::from(vec![
                        Span::styled(
                            " NORMAL ",
                            Style::default()
                                .fg(Color::Black)
                                .bg(c_green)
                                .add_modifier(Modifier::BOLD),
                        ),
                        Span::styled(
                            "  i: buscar | j/k: mover | b: borrar | B: borrar todo | Enter: pegar | Esc: salir",
                            Style::default().fg(c_dim),
                        ),
                    ]),
                    Mode::Insert => Line::from(vec![
                        Span::styled(
                            " INSERT ",
                            Style::default()
                                .fg(Color::Black)
                                .bg(c_yellow)
                                .add_modifier(Modifier::BOLD),
                        ),
                        Span::styled(
                            "  Esc: modo normal | Enter: pegar | ↓/↑: mover selección | Ctrl+u: limpiar",
                            Style::default().fg(c_dim),
                        ),
                    ]),
                    Mode::ConfirmWipe => Line::from(vec![
                        Span::styled(
                            " PELIGRO ",
                            Style::default()
                                .fg(Color::White)
                                .bg(c_red)
                                .add_modifier(Modifier::BOLD),
                        ),
                        Span::styled(
                            "  ¿Deseáis vaciar TODO el historial? (s: sí / otra tecla: cancelar)",
                            Style::default().fg(c_red).add_modifier(Modifier::BOLD),
                        ),
                    ]),
                }
            };
            f.render_widget(Paragraph::new(status_line), chunks[3]);
        })?;

        // Handle Events
        if let Event::Key(key) = event::read()? {
            if key.kind != KeyEventKind::Press {
                continue;
            }

            match mode {
                Mode::ConfirmWipe => {
                    if key.code == KeyCode::Char('s') || key.code == KeyCode::Char('S') {
                        wipe_cliphist();
                        all_items.clear();
                        filtered_items.clear();
                        selected_idx = 0;
                        list_state.select(Some(0));
                        preview_cache.clear();
                        status_msg = "Historial vaciado por completo".to_string();
                        status_msg_time = Instant::now();
                    } else {
                        status_msg = "Operación de borrado cancelada".to_string();
                        status_msg_time = Instant::now();
                    }
                    mode = Mode::Normal;
                }

                Mode::Normal => match key.code {
                    KeyCode::Char('i') | KeyCode::Char('/') => {
                        mode = Mode::Insert;
                    }
                    KeyCode::Char('j') | KeyCode::Down => {
                        if !filtered_items.is_empty() {
                            selected_idx = (selected_idx + 1).min(filtered_items.len() - 1);
                            list_state.select(Some(selected_idx));
                        }
                    }
                    KeyCode::Char('k') | KeyCode::Up => {
                        if !filtered_items.is_empty() {
                            selected_idx = selected_idx.saturating_sub(1);
                            list_state.select(Some(selected_idx));
                        }
                    }
                    KeyCode::Char('g') | KeyCode::Home => {
                        selected_idx = 0;
                        list_state.select(Some(0));
                    }
                    KeyCode::Char('G') | KeyCode::End => {
                        if !filtered_items.is_empty() {
                            selected_idx = filtered_items.len() - 1;
                            list_state.select(Some(selected_idx));
                        }
                    }
                    KeyCode::Char('d') if key.modifiers.contains(KeyModifiers::CONTROL) => {
                        if !filtered_items.is_empty() {
                            selected_idx = (selected_idx + 8).min(filtered_items.len() - 1);
                            list_state.select(Some(selected_idx));
                        }
                    }
                    KeyCode::Char('u') if key.modifiers.contains(KeyModifiers::CONTROL) => {
                        if !filtered_items.is_empty() {
                            selected_idx = selected_idx.saturating_sub(8);
                            list_state.select(Some(selected_idx));
                        }
                    }
                    // Delete item with 'b' (or 'x')
                    KeyCode::Char('b') | KeyCode::Char('x') => {
                        if !filtered_items.is_empty() && selected_idx < filtered_items.len() {
                            let item_to_del = filtered_items[selected_idx].clone();
                            if delete_cliphist_item(&item_to_del) {
                                all_items.retain(|it| it != &item_to_del);
                                filtered_items = filter(&search_query, &all_items);
                                if selected_idx >= filtered_items.len() && !filtered_items.is_empty() {
                                    selected_idx = filtered_items.len() - 1;
                                }
                                list_state.select(Some(selected_idx));
                                status_msg = "Elemento eliminado del historial".to_string();
                                status_msg_time = Instant::now();
                            }
                        }
                    }
                    // Wipe all history with 'B' (or 'D')
                    KeyCode::Char('B') | KeyCode::Char('D') => {
                        mode = Mode::ConfirmWipe;
                    }
                    // Select item and Paste with Enter
                    KeyCode::Enter => {
                        if !filtered_items.is_empty() && selected_idx < filtered_items.len() {
                            select_item_for_paste(&filtered_items[selected_idx]);
                            chosen_to_paste = true;
                            break;
                        }
                    }
                    // Exit without action
                    KeyCode::Esc | KeyCode::Char('q') => {
                        chosen_to_paste = false;
                        break;
                    }
                    _ => {}
                },

                Mode::Insert => match key.code {
                    // Esc returns to Normal mode
                    KeyCode::Esc => {
                        mode = Mode::Normal;
                    }
                    // Enter pastes top / selected match
                    KeyCode::Enter => {
                        if !filtered_items.is_empty() && selected_idx < filtered_items.len() {
                            select_item_for_paste(&filtered_items[selected_idx]);
                            chosen_to_paste = true;
                            break;
                        }
                    }
                    KeyCode::Backspace => {
                        search_query.pop();
                        filtered_items = filter(&search_query, &all_items);
                        selected_idx = 0;
                        list_state.select(Some(0));
                    }
                    KeyCode::Char('u') if key.modifiers.contains(KeyModifiers::CONTROL) => {
                        search_query.clear();
                        filtered_items = filter(&search_query, &all_items);
                        selected_idx = 0;
                        list_state.select(Some(0));
                    }
                    KeyCode::Char('w') if key.modifiers.contains(KeyModifiers::CONTROL) => {
                        if let Some(idx) = search_query.rfind(' ') {
                            search_query.truncate(idx);
                        } else {
                            search_query.clear();
                        }
                        filtered_items = filter(&search_query, &all_items);
                        selected_idx = 0;
                        list_state.select(Some(0));
                    }
                    KeyCode::Down
                    | KeyCode::Char('n') if key.modifiers.contains(KeyModifiers::CONTROL) => {
                        if !filtered_items.is_empty() {
                            selected_idx = (selected_idx + 1).min(filtered_items.len() - 1);
                            list_state.select(Some(selected_idx));
                        }
                    }
                    KeyCode::Up
                    | KeyCode::Char('p') if key.modifiers.contains(KeyModifiers::CONTROL) => {
                        if !filtered_items.is_empty() {
                            selected_idx = selected_idx.saturating_sub(1);
                            list_state.select(Some(selected_idx));
                        }
                    }
                    KeyCode::Char(c) => {
                        search_query.push(c);
                        filtered_items = filter(&search_query, &all_items);
                        selected_idx = 0;
                        list_state.select(Some(0));
                    }
                    _ => {}
                },
            }
        }
    }

    // Proper terminal cleanup
    let _ = disable_raw_mode();
    let mut stdout = io::stdout();
    let _ = execute!(stdout, LeaveAlternateScreen, crossterm::cursor::Show);
    let _ = stdout.flush();

    if chosen_to_paste {
        std::process::exit(0);
    } else {
        std::process::exit(1);
    }
}
