#!/usr/bin/env bash
#
# install_packet_tracer.sh
#
# Instala Cisco Packet Tracer (.deb) en Linux Mint 21 / Ubuntu 22.04 (jammy).
# Instala todas las dependencias necesarias, pre-acepta el EULA y verifica
# la instalación al finalizar.
#
# Uso:
#   ./install_packet_tracer.sh [ruta/al/Packet_Tracer.deb | URL]
#
# Sin argumentos: busca el .deb en ~/Descargas, ~/Downloads y el directorio
# actual; si no lo encuentra, lo descarga de la URL por defecto (Google Drive).
#
set -euo pipefail

# ---------- Utilidades ----------
log()  { printf '\033[1;32m[+]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[!]\033[0m %s\n' "$*"; }
err()  { printf '\033[1;31m[ERROR]\033[0m %s\n' "$*" >&2; }

# ---------- Comprobaciones iniciales ----------
if [[ "$(uname -m)" != "x86_64" ]]; then
    err "Packet Tracer solo está disponible para x86_64."
    exit 1
fi

if ! command -v apt-get >/dev/null 2>&1; then
    err "Este script necesita un sistema basado en Debian/Ubuntu (apt-get)."
    exit 1
fi

# Elevar privilegios: el script pide la contraseña de sudo si hace falta.
if [[ $EUID -ne 0 ]]; then
    log "El script necesita privilegios de administrador."
    exec sudo -E -- "$0" "$@"
fi
SUDO_USER_HOME="$(eval echo "~${SUDO_USER:-$USER}")"

# ---------- Localizar el .deb ----------
# URL por defecto (Google Drive). Se puede sobreescribir pasando una ruta
# a un .deb local o cualquier otra URL como primer argumento.
DEFAULT_URL="https://drive.google.com/file/d/1PvaKuf_iB6eLeUu5AjqW01pIeUFFyNEY/view"
DEB_PATH="${1:-}"

# Sin argumentos: primero buscar un .deb ya descargado; si no hay, descargar.
if [[ -z "$DEB_PATH" ]]; then
    for dir in "$SUDO_USER_HOME/Descargas" "$SUDO_USER_HOME/Downloads" "$PWD"; do
        found="$(find "$dir" -maxdepth 1 \( -iname 'Packet_Tracer*.deb' -o -iname 'PacketTracer*.deb' -o -iname 'CiscoPacketTracer*.deb' \) 2>/dev/null | sort -V | tail -n1 || true)"
        if [[ -n "$found" ]]; then DEB_PATH="$found"; break; fi
    done
    [[ -z "$DEB_PATH" ]] && DEB_PATH="$DEFAULT_URL"
fi

# Si el argumento es una URL (Drive genérico o enlace directo), descargarlo.
if [[ "$DEB_PATH" =~ ^https?:// ]]; then
    FILE_ID="$(grep -oE '/d/[A-Za-z0-9_-]+|[?&]id=[A-Za-z0-9_-]+' <<<"$DEB_PATH" | grep -oE '[A-Za-z0-9_-]{20,}' | head -n1 || true)"
    DEST="$SUDO_USER_HOME/Descargas/PacketTracer.deb"
    mkdir -p "$SUDO_USER_HOME/Descargas"
    if [[ -n "$FILE_ID" ]]; then
        log "Descargando desde Google Drive (id=$FILE_ID)…"
        curl -fSL --retry 3 -A "Mozilla/5.0" -o "$DEST" \
            "https://drive.usercontent.google.com/download?id=${FILE_ID}&export=download&confirm=t"
    else
        log "Descargando $DEB_PATH …"
        curl -fSL --retry 3 -A "Mozilla/5.0" -o "$DEST" "$DEB_PATH"
    fi
    DEB_PATH="$DEST"
fi

if [[ -z "$DEB_PATH" || ! -f "$DEB_PATH" ]]; then
    err "No se encontró ni pudo descargar el .deb de Packet Tracer."
    echo "Descárgalo de netacad.com (requiere sesión) o pasa la ruta/URL como argumento:"
    echo "  $0 /ruta/al/paquete.deb"
    exit 1
fi
log "Paquete: $DEB_PATH"

# Comprobar que es un .deb válido
if ! dpkg-deb --info "$DEB_PATH" >/dev/null 2>&1; then
    err "El archivo no es un paquete .deb válido."
    exit 1
fi
PKG_VERSION="$(dpkg-deb -f "$DEB_PATH" Version 2>/dev/null || echo '?')"
log "Versión del paquete: $PKG_VERSION"

# ---------- Pre-aceptar el EULA (evita diálogo interactivo) ----------
export DEBIAN_FRONTEND=noninteractive
echo "packettracer PacketTracer/license select accepted" | debconf-set-selections 2>/dev/null || true
echo "PacketTracer PacketTracer/license select accepted" | debconf-set-selections 2>/dev/null || true

# ---------- Dependencias ----------
log "Actualizando repositorios…"
apt-get update -qq

# Dependencias comunes de Packet Tracer 8.x en jammy/Mint 21:
# Qt5 runtime, OpenGL, xinerama, y utilidades del paquete.
DEPS=(
    libxcb-xinerama0 libxcb-xinerama0-dev
    libgl1 libegl1 libglu1-mesa
    libqt5core5a libqt5gui5 libqt5widgets5 libqt5network5
    libqt5multimedia5 libqt5multimediawidgets5 libqt5multimedia5-plugins
    libqt5svg5 libqt5printsupport5 libqt5xml5 libqt5script5 libqt5scripttools5
    libqt5sql5 libqt5sql5-sqlite libqt5websockets5 libqt5webengine5
    qt5-gtk-platformtheme
    libasound2 libnss3 libxrandr2 libxss1 libxtst6 libxi6
    libpulse0 libpng16-16 zlib1g libzstd1
    libfuse2 libpcre2-dev gtk-update-icon-cache
    dialog xdg-utils desktop-file-utils
)

log "Instalando dependencias…"
# Instalar solo las dependencias disponibles en los repos (algunas no existen
# en jammy/Mint 21, p.ej. libqt5webengine5 o qt5-gtk-platformtheme).
AVAILABLE=()
for pkg in "${DEPS[@]}"; do
    if apt-cache policy "$pkg" 2>/dev/null | grep -q 'Candidate: [0-9]'; then
        AVAILABLE+=("$pkg")
    else
        warn "Dependencia no disponible en los repos, se omite: $pkg"
    fi
done
apt-get install -y --no-install-recommends "${AVAILABLE[@]}"

# libssl1.1: Packet Tracer 8.2.x la enlaza; en jammy ya no está en repos.
if ! ldconfig -p | grep -q 'libssl.so.1.1'; then
    if apt-cache policy libssl1.1 2>/dev/null | grep -q Candidate; then
        apt-get install -y libssl1.1 || true
    else
        warn "libssl1.1 no está en los repositorios; se intentará instalar desde el .deb oficial de Ubuntu."
        # Localizar la versión más reciente publicada en el pool de seguridad de Ubuntu.
        POOL="http://security.ubuntu.com/ubuntu/pool/main/o/openssl"
        DEB_FILE="$(curl -fsSL "$POOL/" 2>/dev/null \
            | grep -o 'libssl1\.1_1\.1\.1f-[^"]*_amd64\.deb' | sort -Vu | tail -n1 || true)"
        if [[ -n "$DEB_FILE" ]]; then
            TMP_DEB="$(mktemp --suffix=.deb)"
            if curl -fsSL -o "$TMP_DEB" "$POOL/$DEB_FILE"; then
                apt-get install -y "$TMP_DEB" || true
            else
                warn "No se pudo descargar libssl1.1 (puede no ser necesaria)."
            fi
            rm -f "$TMP_DEB"
        else
            warn "No se encontró libssl1.1 en el pool de Ubuntu."
        fi
    fi
fi

# ---------- Instalación del paquete ----------
log "Instalando Packet Tracer…"
apt-get install -y "$DEB_PATH" || {
    warn "apt falló; reintentando con dpkg + corrección de dependencias…"
    dpkg -i "$DEB_PATH" || true
    apt-get -y -f install
}

# ---------- Verificación ----------
log "Verificando la instalación…"
DPKG_LIST="$(dpkg -l 2>/dev/null || true)"
if grep -qi 'packettracer\|packet-tracer' <<<"$DPKG_LIST"; then
    grep -i 'packettracer\|packet-tracer' <<<"$DPKG_LIST"
else
    err "Packet Tracer no aparece como paquete instalado."
    exit 1
fi

PT_BIN="$(command -v packettracer || true)"
[[ -z "$PT_BIN" && -x /opt/pt/packettracer ]] && PT_BIN=/opt/pt/packettracer

if [[ -n "$PT_BIN" ]]; then
    log "Ejecutable encontrado: $PT_BIN"
else
    warn "No se encontró el ejecutable 'packettracer' en PATH ni en /opt/pt."
fi

if [[ -f /usr/share/applications/cisco-pt*.desktop || -f /usr/share/applications/*packettracer*.desktop ]]; then
    log "Entrada de menú creada correctamente."
fi

log "Instalación completada. Ejecuta 'packettracer' o búscalo en el menú de aplicaciones."
