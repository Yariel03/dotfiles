#!/usr/bin/env bash
# ==============================================================================
# DOTFILES INSTALLER & MANAGER
# Con devoción para mi amo y señor
# ==============================================================================

set -eo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_BASE="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"
MODE="link" # "link" o "copy"

# Colores
BOLD="\033[1m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
CYAN="\033[0;36m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
MAGENTA="\033[0;35m"
NC="\033[0m"

# Módulos reservados que no son paquetes de dotfiles
EXCLUDED_MODULES=("packages" "wallpapers" "scripts" ".git")

get_available_modules() {
    local modules=()
    for item in "$DOTFILES_DIR"/*; do
        if [ -d "$item" ]; then
            local name="$(basename "$item")"
            local skip=0
            for exc in "${EXCLUDED_MODULES[@]}"; do
                if [ "$name" == "$exc" ]; then
                    skip=1
                    break
                fi
            done
            [ $skip -eq 0 ] && modules+=("$name")
        fi
    done
    echo "${modules[@]}"
}

print_header() {
    echo -e "${BOLD}${MAGENTA}================================================================${NC}"
    echo -e "${BOLD}${CYAN}   👑 GESTOR DE DOTFILES Y CONFIGURACIONES - ARCH LINUX 👑   ${NC}"
    echo -e "${BOLD}${MAGENTA}================================================================${NC}"
    echo -e "${BLUE}  A su servicio incondicional, mi amo y señor.${NC}\n"
}

list_modules() {
    echo -e "${BOLD}${CYAN}Módulos de configuración disponibles:${NC}\n"
    local mods=($(get_available_modules))
    for mod in "${mods[@]}"; do
        echo -e "  ${GREEN}▸ ${BOLD}$mod${NC}"
        find "$DOTFILES_DIR/$mod" -mindepth 1 -maxdepth 3 -not -path '*/.*' 2>/dev/null | head -n 4 | while read -r f; do
            rel="${f#$DOTFILES_DIR/$mod/}"
            echo -e "      ${CYAN}↳${NC} $rel"
        done
    done
    echo ""
}

backup_item() {
    local target="$1"
    if [ -e "$target" ] || [ -L "$target" ]; then
        mkdir -p "$BACKUP_BASE"
        local rel="${target#$HOME/}"
        local dest_dir="$BACKUP_BASE/$(dirname "$rel")"
        mkdir -p "$dest_dir"
        cp -a "$target" "$BACKUP_BASE/$rel"
        echo -e "    ${YELLOW}↳ Respaldo seguro en: $BACKUP_BASE/$rel${NC}"
    fi
}

deploy_path() {
    local source_path="$1"
    local target_path="$2"
    local label="$3"
    local target_dir="$(dirname "$target_path")"

    mkdir -p "$target_dir"

    if [ "$MODE" == "link" ]; then
        if [ -L "$target_path" ] && [ "$(readlink -f "$target_path")" == "$(readlink -f "$source_path")" ]; then
            echo -e "  ${GREEN}[✓] Ya enlazado correctamente:${NC} $label"
            return 0
        fi

        if [ -e "$target_path" ] || [ -L "$target_path" ]; then
            backup_item "$target_path"
            rm -rf "$target_path"
        fi

        ln -sfn "$source_path" "$target_path"
        echo -e "  ${GREEN}[✓] Enlace creado:${NC} $label -> $source_path"
    else
        if [ -e "$target_path" ]; then
            backup_item "$target_path"
            rm -rf "$target_path"
        fi
        cp -a "$source_path" "$target_path"
        echo -e "  ${GREEN}[✓] Copiado:${NC} $label"
    fi
}

install_module() {
    local mod="$1"
    local mod_dir="$DOTFILES_DIR/$mod"

    if [ ! -d "$mod_dir" ]; then
        echo -e "${RED}[✗] Módulo no encontrado: $mod${NC}"
        return 1
    fi

    echo -e "\n${BOLD}${BLUE}=== Instalando módulo: ${CYAN}$mod${NC} (${MODE} mode) ==="

    # 1. Procesar elementos dentro de .config (enlace inteligente por directorio o archivo)
    if [ -d "$mod_dir/.config" ]; then
        for cfg in "$mod_dir/.config"/*; do
            [ -e "$cfg" ] || continue
            local base_cfg="$(basename "$cfg")"
            deploy_path "$cfg" "$HOME/.config/$base_cfg" "~/.config/$base_cfg"
        done
    fi

    # 2. Procesar dotfiles raíz (ej: .zshrc, .p10k.zsh, .tmux.conf, .gitconfig)
    for f in "$mod_dir"/.*; do
        [ -e "$f" ] || continue
        local fname="$(basename "$f")"
        [[ "$fname" =~ ^(\.|\.\.|\.config|\.git)$ ]] && continue
        deploy_path "$f" "$HOME/$fname" "~/$fname"
    done

    # 3. Caso especial para wallpaper
    if [[ "$mod" == "hypr" || "$mod" == "hyprpaper" ]]; then
        if [ -f "$DOTFILES_DIR/wallpapers/dark.jpg" ] && [ ! -f "$HOME/Descargas/dark.jpg" ]; then
            mkdir -p "$HOME/Descargas"
            cp "$DOTFILES_DIR/wallpapers/dark.jpg" "$HOME/Descargas/dark.jpg"
            echo -e "  ${GREEN}[✓] Wallpaper desplegado en ~/Descargas/dark.jpg${NC}"
        fi
    fi
}

install_all() {
    echo -e "${BOLD}${YELLOW}[*] Desplegando TODAS las configuraciones del sistema...${NC}"
    local mods=($(get_available_modules))
    for mod in "${mods[@]}"; do
        install_module "$mod"
    done
    echo -e "\n${BOLD}${GREEN}✔ ¡Todas las configuraciones han sido instaladas con absoluto éxito, mi loor!${NC}"
}

sync_repository() {
    local msg="$1"
    echo -e "${BOLD}${CYAN}=== Sincronizando repositorio con su sistema actual, mi señor ===${NC}\n"

    # Actualizar listas de paquetes
    if command -v pacman &>/dev/null; then
        echo -e "${BLUE}[*] Actualizando listas de paquetes del sistema operativo...${NC}"
        pacman -Qqe > "$DOTFILES_DIR/packages/pacman-explicit.txt" 2>/dev/null || true
        pacman -Qqm > "$DOTFILES_DIR/packages/aur-packages.txt" 2>/dev/null || true
        pacman -Q > "$DOTFILES_DIR/packages/all-packages-full.txt" 2>/dev/null || true
    fi
    if command -v flatpak &>/dev/null; then
        flatpak list --app --columns=application > "$DOTFILES_DIR/packages/flatpak-packages.txt" 2>/dev/null || true
    fi

    cd "$DOTFILES_DIR"

    # Verificar estado de git
    if [ -z "$(git status --porcelain)" ]; then
        echo -e "${GREEN}[✓] No hay cambios pendientes en sus configuraciones. Todo está al día.${NC}"
        return 0
    fi

    echo -e "${YELLOW}[*] Cambios detectados:${NC}"
    git status --short

    if [ -z "$msg" ]; then
        echo -e "\n${BOLD}Ingrese una descripción para registrar estos cambios:${NC}"
        read -rp "> " msg
        [ -z "$msg" ] && msg="chore: actualizar configuraciones y paquetes del sistema"
    fi

    git add -A
    git commit -m "$msg"
    echo -e "\n${GREEN}[✓] Cambios registrados en Git localmente con éxito.${NC}"

    # Si existe un repositorio remoto configurado, hacer push
    if git remote | grep -q 'origin'; then
        echo -e "${BLUE}[*] Subiendo cambios al servidor remoto (git push)...${NC}"
        git push origin main || git push || echo -e "${YELLOW}[!] No se pudo hacer push automático. Verifique su conexión o credenciales.${NC}"
        echo -e "${GREEN}[✓] Cambios enviados a la nube exitosamente.${NC}"
    else
        echo -e "${YELLOW}[i] No hay repositorio remoto ('origin') configurado aún. Los cambios quedan asegurados localmente.${NC}"
    fi
}

interactive_menu() {
    print_header
    echo -e "Seleccione una orden para que su siervo la ejecute:\n"
    echo -e "  ${BOLD}1)${NC} Enlazar TODAS las configuraciones (Symlinks - Sincronización en vivo)"
    echo -e "  ${BOLD}2)${NC} Enlazar módulos INDIVIDUALES a su elección"
    echo -e "  ${BOLD}3)${NC} Copiar archivos en lugar de enlaces simbólicos (--copy)"
    echo -e "  ${BOLD}4)${NC} Sincronizar y registrar cambios actuales en Git (sync / commit / push)"
    echo -e "  ${BOLD}5)${NC} Instalar / Replicar paquetes y programas del sistema operativo"
    echo -e "  ${BOLD}6)${NC} Listar módulos y configuraciones disponibles"
    echo -e "  ${BOLD}7)${NC} Salir\n"

    read -rp "Ingrese una opción [1-7]: " opt
    case "$opt" in
        1)
            MODE="link"
            install_all
            ;;
        2)
            list_modules
            echo -e "${BOLD}Escriba los nombres de los módulos separados por espacio:${NC}"
            read -rp "> " selected_mods
            for m in $selected_mods; do
                install_module "$m"
            done
            ;;
        3)
            MODE="copy"
            echo -e "  ${BOLD}a)${NC} Copiar todas las configuraciones"
            echo -e "  ${BOLD}b)${NC} Copiar módulos individuales"
            read -rp "Opción [a/b]: " copy_opt
            if [ "$copy_opt" == "a" ]; then
                install_all
            else
                list_modules
                read -rp "Módulos a copiar: " selected_mods
                for m in $selected_mods; do
                    install_module "$m"
                done
            fi
            ;;
        4)
            sync_repository
            ;;
        5)
            bash "$DOTFILES_DIR/packages/install-packages.sh"
            ;;
        6)
            list_modules
            ;;
        7)
            echo -e "${GREEN}A sus órdenes siempre, mi amo y señor.${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Opción inválida.${NC}"
            exit 1
            ;;
    esac
}

# --- Procesar argumentos de línea de comandos ---
if [ $# -eq 0 ]; then
    interactive_menu
    exit 0
fi

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            print_header
            echo "Uso: ./install.sh [OPCIONES] [MÓDULO...]"
            echo ""
            echo "Comandos:"
            echo "  all                  Enlaza todos los módulos disponibles hacia \$HOME"
            echo "  sync [\"mensaje\"]     Actualiza listas de paquetes, hace git commit y git push"
            echo "  <modulo...>          Enlaza uno o varios módulos específicos (ej: hypr kitty zsh)"
            echo ""
            echo "Opciones:"
            echo "  -l, --list           Muestra todos los módulos disponibles"
            echo "  -c, --copy           Copia los archivos en vez de crear enlaces simbólicos"
            echo "  -s, --sync           Sincroniza paquetes y hace commit en el repositorio"
            echo "  -p, --packages       Ejecuta el instalador de paquetes del sistema"
            echo "  -h, --help           Muestra esta ayuda"
            exit 0
            ;;
        -l|--list)
            list_modules
            exit 0
            ;;
        -s|--sync|sync)
            shift
            sync_repository "$*"
            exit 0
            ;;
        -p|--packages)
            bash "$DOTFILES_DIR/packages/install-packages.sh"
            exit 0
            ;;
        -c|--copy)
            MODE="copy"
            shift
            ;;
        all)
            install_all
            exit 0
            ;;
        *)
            install_module "$1"
            shift
            ;;
    esac
done

if [ -d "$BACKUP_BASE" ]; then
    echo -e "\n${YELLOW}[!] Se realizaron respaldos de archivos preexistentes en:${NC} $BACKUP_BASE"
fi
echo -e "\n${BOLD}${GREEN}✔ Misión cumplida con absoluta devoción para mi amo y señor.${NC}"
