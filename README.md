# 👑 Dotfiles & Configuración del Sistema de mi Amo y Señor

Repositorio maestro de configuraciones y paquetes de Arch Linux para mi amo y señor **Yariel**. Diseñado para permitir la replicación completa o modular en cualquier máquina o entorno de manera inmediata, segura y sin fricción.

---

## 📂 Estructura del Repositorio

El repositorio sigue el estándar modular compatible tanto con el instalador nativo integrado (`install.sh`) como con **GNU Stow**:

```text
dotfiles/
├── install.sh                  # Gestor e instalador inteligente (Symlink, Copia, Sincronización)
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

## 📍 Ubicación del Repositorio y Portabilidad Absoluta

> [!IMPORTANT]
> **¿Debe estar el repositorio en su máquina local?**  
> **Sí.** El sistema operativo (Hyprland, Kitty, Zsh, etc.) necesita leer los archivos en tiempo real desde el almacenamiento local. La nube (GitHub/GitLab) es su copia de seguridad remota, pero la máquina siempre opera sobre la copia local clonada.

### 🧭 Funciona sin importar dónde lo clone o a dónde lo mueva
El instalador [**`install.sh`**](file:///home/yariel/dotfiles/install.sh) cuenta con **autodetección dinámica de ruta**. No tiene rutas fijas quemadas en el código:
* Puede clonarlo en `~/dotfiles` (visible).
* Puede clonarlo en `~/.dotfiles` (carpeta oculta para mantener `$HOME` despejado).
* Puede ubicarlo en `~/Proyectos/dotfiles` o en cualquier otra ruta.

### 🚚 ¿Qué pasa si mueve la carpeta del repositorio?
Si en el futuro decide mover el repositorio (por ejemplo de `~/dotfiles` a `~/.dotfiles`):
1. Mueva la carpeta libremente:
   ```bash
   mv ~/dotfiles ~/.dotfiles
   ```
2. Ingrese a la nueva ubicación y vuelva a ejecutar:
   ```bash
   cd ~/.dotfiles
   ./install.sh all
   ```
3. **¡Listo!** En medio segundo, todos los enlaces simbólicos de su sistema se desvinculan de la ruta vieja y se reconectan a la nueva ruta sin perder ninguna configuración. *(Si usa el alias `dotsync` en su `.zshrc`, solo ajuste la ruta allí si la cambió).*

---

## 🚀 Guía de Replicación desde Cero (Paso a Paso)

Si va a configurar una computadora nueva o una instalación limpia de Arch Linux, siga este ritual:

### Paso 0: Requisitos previos mínimos en el nuevo Arch
Asegúrese de contar con Git e internet:
```bash
sudo pacman -Syu --needed git base-devel
```

### Paso 1: Clonar el repositorio
Clone el repositorio en la ubicación que prefiera (visible u oculta):

* **Opción visible:**
  ```bash
  git clone <URL-DE-SU-REPOSITORIO> ~/dotfiles
  cd ~/dotfiles
  ```

* **Opción oculta (Recomendada para un HOME limpio):**
  ```bash
  git clone <URL-DE-SU-REPOSITORIO> ~/.dotfiles
  cd ~/.dotfiles
  ```

### Paso 2: Reinstalar paquetes y configurar repositorios
Ejecute el asistente automático:
```bash
./install.sh --packages
# o directamente:
./packages/install-packages.sh
```

Este script automatiza:
1. Habilitación del repositorio `[multilib]` en `/etc/pacman.conf`.
2. Instalación de llaves y configuración de **Chaotic-AUR** (binarios rápidos precompilados de AUR).
3. Instalación de `yay` si no estuviese presente.
4. Instalación masiva tolerante de los 153 paquetes oficiales de [pacman-explicit.txt](file:///home/yariel/dotfiles/packages/pacman-explicit.txt).
5. Instalación de paquetes comunitarios de [aur-packages.txt](file:///home/yariel/dotfiles/packages/aur-packages.txt).
6. Configuración de Flathub e instalación de aplicaciones Flatpak ([flatpak-packages.txt](file:///home/yariel/dotfiles/packages/flatpak-packages.txt)).

### Paso 3: Desplegar las configuraciones

#### Modo Interactivo (Menú visual):
```bash
./install.sh
```

#### Modo Directo por comandos:
* **Replicar TODO el sistema:**
  ```bash
  ./install.sh all
  ```

* **Replicar módulos INDIVIDUALES:**
  ```bash
  ./install.sh hypr kitty zsh
  ```

* **Copiar archivos en lugar de enlaces simbólicos (`--copy`):**
  ```bash
  ./install.sh --copy all
  ```

* **Listar módulos disponibles:**
  ```bash
  ./install.sh --list
  ```

> [!NOTE]
> **Seguridad garantizada**: Si en el equipo de destino ya existen archivos de configuración previos en `$HOME`, el instalador **no los borra a ciegas**: crea automáticamente un respaldo fechado en `~/.dotfiles_backup/YYYYMMDD_HHMMSS/` antes de reemplazarlos.

### Paso 4: Establecer Zsh como shell por defecto (si es necesario)
```bash
chsh -s $(which zsh)
```
Cierre sesión y vuelva a iniciar para disfrutar de su entorno completo.

---

## 🔄 Flujo de Trabajo Diario: Cómo Editar y Sincronizar

### ✏️ Edición cotidiana
**No tiene que cambiar sus hábitos ni entrar a la carpeta del repositorio para editar.**  
Gracias a los enlaces simbólicos (*symlinks*), editar `~/.config/hypr/hyprland.lua` o `~/.zshrc` modifica directamente el archivo real del repositorio en tiempo real.

### 💾 Guardar y sincronizar con Git en un solo paso
Cuando haya realizado cambios en sus configuraciones o instalado nuevos paquetes que desee asegurar:

```bash
dotsync "Descripción de los cambios"
```
*(O ejecutando `./install.sh sync "Descripción"` desde la carpeta del repo).*

#### ¿Qué hace el comando `dotsync` por mi señor?
1. Actualiza automáticamente las listas de software de Pacman, AUR y Flatpak.
2. Detecta todas las modificaciones en cualquiera de sus módulos.
3. Realiza `git add` y `git commit` con su mensaje descriptivo.
4. Si tiene configurado su repositorio remoto en GitHub/GitLab, ejecuta `git push` automáticamente.

---

## ❓ Preguntas Frecuentes

### ¿Por qué las carpetas de módulos parecen vacías a simple vista?
En Linux, los nombres que comienzan con un punto (`.`) están ocultos.  
* En **Dolphin**: Presione **`Ctrl + H`** para revelarlos.
* En la **terminal**: Use **`ls -la`**.
* En **Yazi**: Presione la tecla **`.`** (punto).

### ¿Se suben enlaces simbólicos rotos a GitHub?
**No.** El repositorio contiene los **archivos físicos reales de texto y código** (modo `100644 blob` en Git). Cuando hace `git push`, todo el código sube íntegro y legible a la nube. Los enlaces simbólicos solo van desde su `$HOME` apuntando hacia el repositorio local.
