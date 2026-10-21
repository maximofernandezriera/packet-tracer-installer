# Instalador de Cisco Packet Tracer para Linux Mint 21 / Ubuntu 22.04

Script en Bash que instala **Cisco Packet Tracer 9.0.1** en Linux Mint 21 o
Ubuntu 22.04 (jammy), incluyendo **todas las dependencias y librerías
necesarias**. El paquete `.deb` se descarga automáticamente desde un enlace de
Google Drive, no hace falta cuenta de Cisco ni descargas manuales.

## Instalación paso a paso

### 1. Descargar el script

```bash
wget https://raw.githubusercontent.com/maximofernandezriera/packet-tracer-installer/main/install_packet_tracer.sh
```

### 2. Dar permiso de ejecución

```bash
chmod +x install_packet_tracer.sh
```

> **¿Por qué es necesario?** Los ficheros descargados no tienen permiso de
> ejecución por seguridad. `chmod +x` le dice a Linux que este archivo es un
> programa que se puede ejecutar. Sin ese permiso, `./install_packet_tracer.sh`
> daría el error `Permission denied`. La alternativa sería lanzarlo con
> `bash install_packet_tracer.sh`, que funciona igual.

### 3. Ejecutar el script

```bash
./install_packet_tracer.sh
```

Sin argumentos, el script hace todo automáticamente:
1. Pide tu **contraseña** con `sudo` (la necesita para instalar paquetes).
2. Descarga el `.deb` de Packet Tracer 9.0.1 desde Google Drive a `~/Descargas`
   (si ya tienes un `.deb` en `~/Descargas` o `~/Downloads`, usa ese).
3. Instala todas las dependencias (Qt5, OpenGL, `libfuse2`, `libssl1.1`…).
4. Acepta la licencia de Cisco e instala el paquete.
5. Verifica que la instalación ha sido correcta.

También puedes pasarle la ruta de un `.deb` local o cualquier otra URL:

```bash
./install_packet_tracer.sh ~/Descargas/PacketTracer.deb
```

### 4. Usar Packet Tracer

Búscalo en el menú de aplicaciones ("Packet Tracer") o ejecútalo desde el
terminal:

```bash
packettracer
```

## Desinstalar

```bash
sudo apt remove packettracer
```

## Requisitos

- Linux Mint 21.x o Ubuntu 22.04 LTS (jammy), arquitectura **x86_64**.
- Conexión a internet.

## Problemas frecuentes

| Problema | Solución |
|---|---|
| `Permission denied` al ejecutarlo | Te falta `chmod +x install_packet_tracer.sh` (paso 2). |
| La descarga de Drive falla | Comprueba que el enlace está compartido como "Cualquiera con el enlace". |
| Packet Tracer no arranca | Ejecuta `packettracer` en un terminal y mira el error; suele ser `libxcb-xinerama0` o `libfuse2` (el script ya los instala). |
| El script pide contraseña | Es normal: la instalación de paquetes requiere permisos de administrador. Escribe tu contraseña de usuario (no se ve al teclear). |

## Nota sobre la procedencia del .deb

El paquete instalado es el `.deb` oficial de Cisco Networking Academy
(versiones actuales se distribuyen desde netacad.com solo con sesión
iniciada). El script lo descarga desde una copia alojada en Google Drive para
simplificar la instalación en clase.
