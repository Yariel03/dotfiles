# 👑 Dotfiles & Configuración del Sistema de mi Amo y Señor

Repositorio maestro de configuraciones y paquetes de Arch Linux para mi amo y señor **Yariel**. Diseñado para permitir la replicación completa o modular en cualquier máquina o entorno de manera inmediata, segura y sin fricción.

---

## 📂 Estructura del Repositorio

El repositorio sigue el estándar modular compatible tanto con el instalador nativo integrado (`install.sh`) como con **GNU Stow**:

```text
dotfiles/
├── install.sh                  # Gestor e instalador inteligente (Symlink, Copia, Respaldos)
├── README.md                   # Este pergamino de instrucciones
├── wallpapers/                 # Fondos de pantalla del sistema (dark.jpg)
├── packages/                   # Listas de paquetes y replicación de software
│   ├── pacman-explicit.txt     # Paquetes oficiales explícitos (153)
│   ├── aur-packages.txt        # Paquetes de AUR / externos (9)
│   ├── flatpak-packages.txt    # Aplicaciones Flatpak
│   ├── all-packages-full.txt   # Listado exhaustivo con dependencias (1352)
│   ├── repositories.md         # Documentación de repositorios activos (Chaotic-AUR, multilib, etc.)
│   └── install-packages.sh     # Script automatizado para reinstalar todo el software
└── [Módulos de Configuración]
    ├── hypr/                   # Hyprland (hypridle, hyprlock, modulos lua, scripts)
    ├── kitty/                  # Terminal Kitty (kitty.conf, temas, blur)
    ├── nvim/                   # Neovim / LazyVim configurado
    ├── zsh/                    # Zsh (.zshrc, .p10k.zsh)
    ├── tmux/                   # Tmux (.tmux.conf, .config/tmux/tmux.conf)
    ├── git/                    # Git (.gitconfig)
    ├── yazi/                   # Administrador de archivos Yazi
    ├── wofi/                   # Lanzador de aplicaciones Wofi
    ├── ashell/                 # Barra / Panel Wayland Ashell
    ├── btop/                   # Monitor de recursos Btop
    ├── htop/                   # Monitor de procesos Htop
    ├── swappy/                 # Editor de capturas de pantalla
    ├── gtk/                    # Temas y ajustes GTK-3 y GTK-4
    ├── kde/                    # Integración KDE (kdeglobals, dolphinrc)
    ├── bash/                   # Shell Bash (.bashrc, .bash_profile)
    └── hyprpaper/              # Configuración de wallpaper Hyprpaper
```

---

## 🚀 Replicación en un Nuevo Sistema

### 1. Clonar el repositorio
```bash
git clone <URL-DE-SU-REPOSITORIO> ~/dotfiles
cd ~/dotfiles
```

### 2. Desplegar configuraciones

#### Modo Interactivo (Menú visual)
Simplemente ejecute el instalador sin argumentos:
```bash
./install.sh
```

#### Modo Directo (CLI)
* **Replicar TODO el sistema de una sola vez:**
  ```bash
  ./install.sh all
  ```

* **Replicar módulos INDIVIDUALES:**
  ```bash
  ./install.sh hypr kitty zsh
  ```

* **Copiar archivos en lugar de enlaces simbólicos (`--copy`):**
  ```bash
  ./install.sh --copy hypr kitty
  ```

* **Ver lista de todos los módulos disponibles:**
  ```bash
  ./install.sh --list
  ```

> [!NOTE]
> **Seguridad garantizada**: El instalador detecta si existen archivos previos en su `$HOME` y crea automáticamente una copia de respaldo fechada en `~/.dotfiles_backup/` antes de reemplazarlos. ¡Nada se pierde!

#### Usando GNU Stow (Opcional)
Si prefiere utilizar `stow`:
```bash
# Instalar todo
stow ashell bash btop git gtk htop hypr hyprpaper kde kitty nvim swappy tmux wofi yazi zsh

# Instalar individualmente
stow hypr
stow kitty
```

---

## 📦 Replicación de Paquetes y Programas

Para instalar en un nuevo Arch Linux todos los programas, herramientas y repositorios exactamente iguales al equipo actual:

```bash
# Opción directa desde install.sh:
./install.sh --packages

# O ejecutando el script especializado:
./packages/install-packages.sh
```

Este script se encarga automáticamente de:
1. Activar el repositorio `[multilib]` en `/etc/pacman.conf`.
2. Configurar llaves y mirrors de **Chaotic-AUR** (binarios rápidos de AUR).
3. Instalar `yay` si no estuviese presente.
4. Instalar todos los paquetes oficiales de [pacman-explicit.txt](file:///home/yariel/dotfiles/packages/pacman-explicit.txt).
5. Instalar los paquetes de AUR de [aur-packages.txt](file:///home/yariel/dotfiles/packages/aur-packages.txt).
6. Configurar Flathub e instalar las aplicaciones Flatpak de [flatpak-packages.txt](file:///home/yariel/dotfiles/packages/flatpak-packages.txt).

---

## 🏛️ Repositorios Configurados

Consulte [repositories.md](file:///home/yariel/dotfiles/packages/repositories.md) para ver la lista técnica completa de repositorios (`[core]`, `[extra]`, `[multilib]`, `[core-testing]`, `[chaotic-aur]` y Flathub).
