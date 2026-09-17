# 🏛️ Repositorios del Sistema - Arch Linux

Este documento recopila la configuración exacta de los repositorios de paquetes y orígenes de software configurados en el sistema de mi señor.

---

## 1. Repositorios Oficiales de Arch Linux (`/etc/pacman.conf`)

En el archivo `/etc/pacman.conf` están activos los siguientes repositorios:

* **`[core]`**: Paquetes esenciales y vitales para el funcionamiento del sistema base.
  * *Mirrorlist:* `/etc/pacman.d/mirrorlist`
* **`[extra]`**: Repositorio extendido que contiene entornos de escritorio, aplicaciones, navegadores y librerías adicionales.
  * *Mirrorlist:* `/etc/pacman.d/mirrorlist`
* **`[multilib]`**: Paquetes y librerías de 32 bits (imprescindibles para Steam, Wine, emuladores y drivers propietarios).
  * *Mirrorlist:* `/etc/pacman.d/mirrorlist`
* **`[core-testing]`**: Repositorio de pruebas preliminares antes de pasar a la rama principal de core.
  * *Mirrorlist:* `/etc/pacman.d/mirrorlist`

---

## 2. Repositorio de Terceros: Chaotic-AUR

El sistema cuenta con **Chaotic-AUR** habilitado, lo que permite descargar paquetes populares de AUR ya precompilados como binarios oficiales con máxima velocidad:

* **Nombre del repo:** `[chaotic-aur]`
* **Archivo de mirrors:** `/etc/pacman.d/chaotic-mirrorlist`
* **Claves instaladas:** `chaotic-keyring`

### 🔧 Cómo activar Chaotic-AUR en un nuevo sistema Arch:
```bash
sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key 3056513887B78AEB
sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'

# Luego agregar al final de /etc/pacman.conf:
# [chaotic-aur]
# Include = /etc/pacman.d/chaotic-mirrorlist
```

---

## 3. AUR (Arch User Repository) & Helper

* **AUR Helper instalado:** `yay` (`/usr/bin/yay`)
* Permite compilar e instalar cualquier paquete de la comunidad que no se encuentre en repositorios oficiales o precompilados.

---

## 4. Repositorios Flatpak

* **Remotos activos:** `flathub` (System-wide)
* Comando de verificación:
  ```bash
  flatpak remotes
  ```

---

## 5. Repositorios de Código Git detectados en el sistema

Como referencia de los proyectos locales presentes en el almacenamiento:
* `~/yay` (Código fuente compilado de yay)
* `~/qmk_firmware` (Firmware de teclado QMK con submódulos)
* `~/Descargas/crkbd` (Repositorio de teclado Corne / crkbd)
* `~/Documentos/2026/yariel-dev` (Proyecto web / dev personal)
* `~/Documentos/2026/agentic-app-template` (Plantilla de aplicación)
* `~/Documentos/2026/crkbd` (Configuraciones de teclado)
* `~/.oh-my-zsh` (Framework Zsh)
* `~/.zsh/zsh-autosuggestions` (Plugin de Zsh)
* `~/.config/nvim` (Configuración base LazyVim)
