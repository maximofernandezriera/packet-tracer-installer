# Instalador de Cisco Packet Tracer para Linux Mint 21 / Ubuntu 22.04

Script en Bash que instala **Cisco Packet Tracer** (paquete `.deb` oficial de
Cisco Networking Academy) en Linux Mint 21 o Ubuntu 22.04 (jammy), incluyendo
**todas las dependencias y librerías necesarias**.

Probado con **Packet Tracer 9.0.1**.

## Qué hace el script

- Pide la contraseña con `sudo` si no se ejecuta como administrador.
- Instala todas las dependencias: Qt5, OpenGL, `libxcb-xinerama0`, `libfuse2`
  (Packet Tracer 9 lleva un AppImage interno), `libssl1.1` si hace falta, etc.
- Pre-acepta el acuerdo de licencia de Cisco (instalación sin ventanas extra).
- Instala el `.deb` y repara dependencias automáticamente si algo falla.
- Verifica al final que Packet Tracer quedó correctamente instalado.

## Paso 1: descargar Packet Tracer

Cisco solo distribuye el `.deb` desde su web y exige iniciar sesión:

1. Entra en [https://www.netacad.com](https://www.netacad.com) con tu cuenta.
2. Ve a **Packet Tracer → Download** y descarga la versión
   **Ubuntu Desktop 64-bit** (fichero `Packet_Tracer*_amd64.deb`).
3. Déjalo en la carpeta **Descargas**.

## Paso 2: descargar y ejecutar el script

```bash
wget https://raw.githubusercontent.com/maximofernandezriera/packet-tracer-installer/main/install_packet_tracer.sh
chmod +x install_packet_tracer.sh
./install_packet_tracer.sh
```

El script busca el `.deb` automáticamente en `~/Descargas` y `~/Downloads`.

También puedes pasarle la ruta del fichero o una URL directa (por ejemplo,
un enlace compartido de Google Drive):

```bash
./install_packet_tracer.sh ~/Descargas/Packet_Tracer822_amd64_signed.deb
./install_packet_tracer.sh "https://drive.google.com/file/d/TU_ID/view"
```

## Paso 3: usar Packet Tracer

Al terminar, ejecútalo desde el menú de aplicaciones (busca "Packet Tracer")
o desde el terminal:

```bash
packettracer
```

## Desinstalar

```bash
sudo apt remove packettracer
```

## Requisitos

- Linux Mint 21.x o Ubuntu 22.04 LTS (jammy), arquitectura **x86_64**.
- Conexión a internet (para descargar las dependencias).
- El `.deb` oficial de Cisco descargado de netacad.com (o una URL válida).

## Problemas frecuentes

| Problema | Solución |
|---|---|
| `No se encontró el .deb` | Pasa la ruta completa al script o mueve el fichero a `~/Descargas`. |
| Packet Tracer no arranca | Ejecuta `packettracer` en un terminal y revisa el error; suele ser `libxcb-xinerama0` o `libfuse2` (el script ya los instala). |
| Error de licencia/EULA | El script ya acepta la licencia; si aparece el diálogo, selecciona "Aceptar". |
| El archivo de Drive no descarga | Comprueba que el enlace está compartido como "Cualquiera con el enlace". |
