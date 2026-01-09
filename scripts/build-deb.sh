#!/bin/bash
set -e

# Script para construir el paquete DEB de Ventoy localmente
# Uso: ./scripts/build-deb.sh

echo "=== Ventoy DEB Package Builder ==="

# Verificar dependencias
command -v curl >/dev/null 2>&1 || { echo "Error: curl no está instalado"; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "Error: jq no está instalado"; exit 1; }
command -v dpkg-deb >/dev/null 2>&1 || { echo "Error: dpkg-deb no está instalado. Instala con: brew install dpkg"; exit 1; }

# Obtener la última versión de Ventoy
echo "Obteniendo información de la última versión de Ventoy..."
LATEST_RELEASE=$(curl -s https://api.github.com/repos/ventoy/Ventoy/releases/latest)
VERSION=$(echo "$LATEST_RELEASE" | jq -r '.tag_name' | sed 's/^v//')
DOWNLOAD_URL=$(echo "$LATEST_RELEASE" | jq -r '.assets[] | select(.name | contains("linux.tar.gz")) | .browser_download_url')

echo "Versión encontrada: $VERSION"
echo "URL de descarga: $DOWNLOAD_URL"

# Descargar Ventoy
echo "Descargando Ventoy $VERSION..."
curl -L -o /tmp/ventoy.tar.gz "$DOWNLOAD_URL" --progress-bar

# Extraer archivo
echo "Extrayendo archivos..."
tar -xzf /tmp/ventoy.tar.gz -C /tmp/
VENTOY_DIR=$(tar -tzf /tmp/ventoy.tar.gz | head -1 | cut -f1 -d"/")

# Preparar estructura del paquete usando directorio temporal
echo "Preparando estructura del paquete..."
BUILD_DIR="build_temp"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR/opt/apps/ventoy"

# Copiar archivos de Ventoy
cp -r /tmp/$VENTOY_DIR/* "$BUILD_DIR/opt/apps/ventoy/"

# Copiar estructura de datos existente (iconos, desktop, etc)
cp -r data/usr "$BUILD_DIR/"

# Establecer permisos
echo "Estableciendo permisos..."
find "$BUILD_DIR/opt/apps/ventoy" -name "*.sh" -exec chmod +x {} \;
chmod +x "$BUILD_DIR/opt/apps/ventoy/VentoyGUI."* 2>/dev/null || true

# Calcular tamaño instalado
echo "Calculando tamaño instalado..."
INSTALLED_SIZE=$(du -sk "$BUILD_DIR" | cut -f1)
echo "Tamaño instalado: $INSTALLED_SIZE KB"

# Actualizar archivo control
echo "Actualizando archivo control..."
sed -i.bak "s/^Version:.*/Version: $VERSION-1+deepines/" control/control
sed -i.bak "s/^Installed-Size:.*/Installed-Size: $INSTALLED_SIZE/" control/control
rm -f control/control.bak

# Generar checksums MD5
echo "Generando checksums MD5..."
cd "$BUILD_DIR"
find . -type f -exec md5sum {} \; > ../control/md5sums
cd ..

# Construir paquete DEB
echo "Construyendo paquete DEB..."
PACKAGE_NAME="ventoy_${VERSION}-1+deepines_amd64"
rm -rf "$PACKAGE_NAME"
mkdir -p "$PACKAGE_NAME/DEBIAN"
cp -r control/* "$PACKAGE_NAME/DEBIAN/"
cp -r "$BUILD_DIR"/* "$PACKAGE_NAME/"

dpkg-deb --build --root-owner-group "$PACKAGE_NAME"

# Verificar el paquete
echo ""
echo "=== Información del Paquete ==="
dpkg-deb --info "${PACKAGE_NAME}.deb"
echo ""
echo "=== Tamaño del Paquete ==="
ls -lh "${PACKAGE_NAME}.deb"

# Limpiar archivos temporales
echo ""
echo "Limpiando archivos temporales..."
rm -rf /tmp/ventoy.tar.gz /tmp/$VENTOY_DIR
rm -rf "$BUILD_DIR" "$PACKAGE_NAME"

echo ""
echo "=== ¡Construcción completada! ==="
echo "Paquete generado: ${PACKAGE_NAME}.deb"
echo ""
echo "Para instalar:"
echo "  sudo dpkg -i ${PACKAGE_NAME}.deb"
echo "  sudo apt-get install -f"
