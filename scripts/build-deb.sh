#!/bin/bash
set -e

# Script para construir el paquete DEB de Ventoy localmente
# Uso: ./scripts/build-deb.sh

echo "=== Ventoy DEB Package Builder ==="

# Verificar dependencias
command -v wget >/dev/null 2>&1 || { echo "Error: wget no está instalado"; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "Error: jq no está instalado"; exit 1; }
command -v dpkg-deb >/dev/null 2>&1 || { echo "Error: dpkg-deb no está instalado"; exit 1; }

# Obtener la última versión de Ventoy
echo "Obteniendo información de la última versión de Ventoy..."
LATEST_RELEASE=$(curl -s https://api.github.com/repos/ventoy/Ventoy/releases/latest)
VERSION=$(echo "$LATEST_RELEASE" | jq -r '.tag_name' | sed 's/^v//')
DOWNLOAD_URL=$(echo "$LATEST_RELEASE" | jq -r '.assets[] | select(.name | contains("linux.tar.gz")) | .browser_download_url')

echo "Versión encontrada: $VERSION"
echo "URL de descarga: $DOWNLOAD_URL"

# Descargar Ventoy
echo "Descargando Ventoy $VERSION..."
wget -O /tmp/ventoy.tar.gz "$DOWNLOAD_URL"

# Extraer archivo
echo "Extrayendo archivos..."
tar -xzf /tmp/ventoy.tar.gz -C /tmp/
VENTOY_DIR=$(tar -tzf /tmp/ventoy.tar.gz | head -1 | cut -f1 -d"/")

# Preparar estructura del paquete
echo "Preparando estructura del paquete..."
rm -rf data/opt/apps/ventoy/*
mkdir -p data/opt/apps/ventoy
cp -r /tmp/$VENTOY_DIR/* data/opt/apps/ventoy/

# Establecer permisos
echo "Estableciendo permisos..."
chmod +x data/opt/apps/ventoy/Ventoy2Disk.sh
chmod +x data/opt/apps/ventoy/VentoyWeb.sh
chmod +x data/opt/apps/ventoy/VentoyGUI.*
chmod +x data/opt/apps/ventoy/VentoyPlugson.sh
find data/opt/apps/ventoy -name "*.sh" -exec chmod +x {} \;

# Calcular tamaño instalado
echo "Calculando tamaño instalado..."
INSTALLED_SIZE=$(du -sk data | cut -f1)
echo "Tamaño instalado: $INSTALLED_SIZE KB"

# Actualizar archivo control
echo "Actualizando archivo control..."
sed -i.bak "s/^Version:.*/Version: $VERSION-1+deepines/" control/control
sed -i.bak "s/^Installed-Size:.*/Installed-Size: $INSTALLED_SIZE/" control/control
rm -f control/control.bak

# Generar checksums MD5
echo "Generando checksums MD5..."
cd data
find . -type f -exec md5sum {} \; > ../control/md5sums
cd ..

# Construir paquete DEB
echo "Construyendo paquete DEB..."
PACKAGE_NAME="ventoy_${VERSION}-1+deepines_amd64"
rm -rf "$PACKAGE_NAME"
mkdir -p "$PACKAGE_NAME/DEBIAN"
cp -r control/* "$PACKAGE_NAME/DEBIAN/"
cp -r data/* "$PACKAGE_NAME/"

dpkg-deb --build "$PACKAGE_NAME"

# Limpiar archivos temporales
echo "Limpiando archivos temporales..."
rm -rf /tmp/ventoy.tar.gz /tmp/$VENTOY_DIR
rm -rf "$PACKAGE_NAME"

echo ""
echo "=== ¡Construcción completada! ==="
echo "Paquete generado: ${PACKAGE_NAME}.deb"
echo ""
echo "Para instalar:"
echo "  sudo dpkg -i ${PACKAGE_NAME}.deb"
echo "  sudo apt-get install -f"
