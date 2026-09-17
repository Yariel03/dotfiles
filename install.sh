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
        # Mostrar qué archivos contiene el módulo
        find "$DOTFILES_DIR/$mod" -mindepth 1 -maxdepth 3 -not -path '*/.*' | head -n 4 | while read -r f; do
            rel="${f#$DOTFILES_DIR/$mod/}"
            echo -e "      ${CYAN}↳${NC} $rel"
        done
    done
    echo ""
}

backup_file() {
    local target="$1"
    if [ -e "$target" ] || [ -L "$target" ]; then
        mkdir -p "$BACKUP_BASE"
        local rel="${target#$HOME/}"
        local dest_dir="$BACKUP_BASE/$(dirname "$rel")"
        mkdir -p "$dest_dir"
        cp -a "$target" "$BACKUP_BASE/$rel"
        echo -e "    ${YELLOW}↳ Respaldo creado en: $BACKUP_BASE/$rel${NC}"
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

    # Encontrar todos los archivos relativos dentro del módulo
    cd "$mod_dir"
    find . -mindepth 1 -type f -o -type l | while IFS= read -r item; do
        item="${item#./}"
        target_path="$HOME/$item"
        source_path="$mod_dir/$item"
        target_dir="$(dirname "$target_path")"

        mkdir -p "$target_dir"

        if [ "$MODE" == "link" ]; then
            if [ -L "$target_path" ] && [ "$(readlink "$target_path")" == "$source_path" ]; then
                echo -e "  ${GREEN}[✓] Ya enlazado:${NC} $item"
                continue
            fi

            # Si ya existe un archivo o enlace diferente, respaldar
            if [ -e "$target_path" ] || [ -L "$target_path" ]; then
                backup_file "$target_path"
                rm -rf "$target_path"
            fi

            ln -sf "$source_path" "$target_path"
            echo -e "  ${GREEN}[✓] Enlazado:${NC} ~/$item -> $source_path"
        else
            # Modo copia
            if [ -e "$target_path" ]; then
                backup_file "$target_path"
                rm -rf "$target_path"
            fi
            cp -a "$source_path" "$target_path"
            echo -e "  ${GREEN}[✓] Copiado:${NC} ~/$item"
        fi
    done
    cd "$DOTFILES_DIR"

    # Caso especial para fondos de pantalla si el módulo es hypr o hyprpaper
    if [[ "$mod" == "hypr" || "$mod" == "hyprpaper" ]]; then
        if [ -f "$DOTFILES_DIR/wallpapers/dark.jpg" ] && [ ! -f "$HOME/Descargas/dark.jpg" ]; then
            mkdir -p "$HOME/Descargas"
            cp "$DOTFILES_DIR/wallpapers/dark.jpg" "$HOME/Descargas/dark.jpg"
            echo -e "  ${GREEN}[✓] Fondo de pantalla desplegado en ~/Descargas/dark.jpg${NC}"
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

interactive_menu() {
    print_header
    echo -e "Seleccione una orden para que su siervo la ejecute:\n"
    echo -e "  ${BOLD}1)${NC} Desplegar TODAS las configuraciones (Symlinks - Recomendado)"
    echo -e "  ${BOLD}2)${NC} Desplegar módulos INDIVIDUALES a su elección"
    echo -e "  ${BOLD}3)${NC} Copiar archivos en lugar de enlaces simbólicos (--copy)"
    echo -e "  ${BOLD}4)${NC} Instalar / Replicar paquetes y programas del sistema operativo"
    echo -e "  ${BOLD}5)${NC} Listar módulos y configuraciones disponibles"
    echo -e "  ${BOLD}6)${NC} Salir\n"

    read -rp "Ingrese una opción [1-6]: " opt
    case "$opt" in
        1)
            MODE="link"
            install_all
            ;;
        2)
            list_modules
            echo -e "${BOLD}Escriba los nombres de los módulos que desea instalar separados por espacio:${NC}"
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
            bash "$DOTFILES_DIR/packages/install-packages.sh"
            ;;
        5)
            list_modules
            ;;
        6)
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
            echo "  all                  Instala todos los módulos disponibles"
            echo "  <modulo...>          Instala uno o varios módulos específicos (ej: hypr kitty zsh)"
            echo ""
            echo "Opciones:"
            echo "  -l, --list           Muestra todos los módulos disponibles"
            echo "  -c, --copy           Copia los archivos en vez de crear enlaces simbólicos (symlinks)"
            echo "  -p, --packages       Ejecuta el instalador de paquetes del sistema (pacman/aur/flatpak)"
            echo "  -h, --help           Muestra esta ayuda"
            exit 0
            ;;
        -l|--list)
            list_modules
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
