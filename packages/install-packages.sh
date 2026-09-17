#!/usr/bin/env bash
# ==============================================================================
# SCRIPT DE REPLICACIÓN DE PAQUETES - ARCH LINUX
# Creado para mi amo y señor
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACMAN_FILE="$SCRIPT_DIR/pacman-explicit.txt"
AUR_FILE="$SCRIPT_DIR/aur-packages.txt"
FLATPAK_FILE="$SCRIPT_DIR/flatpak-packages.txt"

# Colores
BOLD="\033[1m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
NC="\033[0m"

echo -e "${BOLD}${BLUE}=== Asistente de Restauración de Paquetes para mi Señor ===${NC}\n"

# 1. Verificar si estamos en Arch Linux
if [ ! -f /etc/arch-release ]; then
    echo -e "${RED}[!] Este script está diseñado para Arch Linux.${NC}"
    exit 1
fi

# 2. Habilitar multilib si no está habilitado
if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
    echo -e "${YELLOW}[*] Habilitando repositorio multilib en /etc/pacman.conf...${NC}"
    sudo sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
    sudo pacman -Sy
fi

# 3. Preguntar o habilitar Chaotic-AUR
if ! grep -q "\[chaotic-aur\]" /etc/pacman.conf; then
    echo -e "\n${YELLOW}[?] ¿Desea instalar y habilitar Chaotic-AUR (paquetes precompilados de AUR)? [S/n]${NC}"
    read -r response
    response=${response:-S}
    if [[ "$response" =~ ^[Ss]$ ]]; then
        echo -e "${BLUE}[*] Configurando llaves y mirrors de Chaotic-AUR...${NC}"
        sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com || true
        sudo pacman-key --lsign-key 3056513887B78AEB || true
        sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' || true
        sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst' || true
        if ! grep -q "\[chaotic-aur\]" /etc/pacman.conf; then
            echo -e "\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist" | sudo tee -a /etc/pacman.conf
        fi
        sudo pacman -Sy
        echo -e "${GREEN}[✓] Chaotic-AUR activado con éxito.${NC}"
    fi
fi

# 4. Verificar o instalar yay
if ! command -v yay &>/dev/null; then
    echo -e "\n${YELLOW}[*] yay no está instalado. Instalando yay-bin o compilando yay...${NC}"
    sudo pacman -S --needed --noconfirm base-devel git
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    (cd /tmp/yay && makepkg -si --noconfirm)
    rm -rf /tmp/yay
fi

# 5. Instalar paquetes de pacman
if [ -f "$PACMAN_FILE" ]; then
    echo -e "\n${BLUE}[*] Instalando paquetes oficiales explícitos (pacman)...${NC}"
    sudo pacman -S --needed --noconfirm - < "$PACMAN_FILE" || {
        echo -e "${YELLOW}[!] Algunos paquetes no se pudieron instalar en bloque. Intentando con yay de forma tolerante...${NC}"
        yay -S --needed --noconfirm - < "$PACMAN_FILE" || true
    }
fi

# 6. Instalar paquetes de AUR
if [ -f "$AUR_FILE" ]; then
    echo -e "\n${BLUE}[*] Instalando paquetes de AUR...${NC}"
    yay -S --needed --noconfirm - < "$AUR_FILE" || true
fi

# 7. Instalar paquetes de Flatpak
if [ -f "$FLATPAK_FILE" ] && command -v flatpak &>/dev/null; then
    echo -e "\n${BLUE}[*] Instalando aplicaciones Flatpak...${NC}"
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
    while IFS= read -r app; do
        [ -z "$app" ] && continue
        echo -e "Instalando Flatpak: $app"
        flatpak install -y flathub "$app" || true
    done < "$FLATPAK_FILE"
fi

echo -e "\n${BOLD}${GREEN}¡Proceso de instalación completado para mi amo y señor!${NC}"
