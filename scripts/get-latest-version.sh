#!/bin/bash
set -e

# Script para obtener la última versión de Ventoy
# Uso: ./scripts/get-latest-version.sh

command -v jq >/dev/null 2>&1 || { echo "Error: jq no está instalado"; exit 1; }

LATEST_RELEASE=$(curl -s https://api.github.com/repos/ventoy/Ventoy/releases/latest)
VERSION=$(echo "$LATEST_RELEASE" | jq -r '.tag_name' | sed 's/^v//')
DOWNLOAD_URL=$(echo "$LATEST_RELEASE" | jq -r '.assets[] | select(.name | contains("linux.tar.gz")) | .browser_download_url')

echo "VERSION=$VERSION"
echo "DOWNLOAD_URL=$DOWNLOAD_URL"
