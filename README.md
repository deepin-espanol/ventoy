# Ventoy DEB Package Builder

Sistema automatizado para construir paquetes `.deb` de Ventoy usando GitHub Actions. Este proyecto descarga automáticamente la última versión de Ventoy desde el repositorio oficial y crea un paquete Debian listo para instalar.

## Características

- ✅ Descarga automática de la última versión de Ventoy
- ✅ Construcción automatizada con GitHub Actions
- ✅ Versionamiento dinámico basado en la versión oficial
- ✅ Generación de checksums MD5
- ✅ Scripts de post-instalación para configuración automática
- ✅ Publicación automática de releases en GitHub

## Uso

### Instalación desde Release

1. Ve a la [página de Releases](../../releases)
2. Descarga el archivo `.deb` más reciente
3. Instala el paquete:

```bash
sudo dpkg -i ventoy_*_amd64.deb
sudo apt-get install -f  # Si hay dependencias faltantes
```

### Construcción Manual

Si prefieres construir el paquete localmente:

```bash
# Instalar dependencias
sudo apt-get install wget curl jq dpkg-dev

# Ejecutar script de construcción
chmod +x scripts/build-deb.sh
./scripts/build-deb.sh

# Instalar el paquete generado
sudo dpkg -i ventoy_*_amd64.deb
```

## GitHub Actions Workflow

El workflow se ejecuta automáticamente:

- **Semanalmente**: Todos los domingos a medianoche (UTC)
- **Manualmente**: Desde la pestaña "Actions" en GitHub

### Ejecución Manual

1. Ve a la pestaña **Actions** en GitHub
2. Selecciona el workflow "Build Ventoy DEB Package"
3. Haz clic en "Run workflow"
4. Espera a que se complete la construcción
5. Descarga el artifact o ve a Releases

## Estructura del Proyecto

```
ventoy/
├── .github/
│   └── workflows/
│       └── build-deb.yml          # Workflow de GitHub Actions
├── control/
│   ├── control                     # Metadatos del paquete
│   ├── md5sums                     # Checksums (generado automáticamente)
│   ├── postinst                    # Script post-instalación
│   └── prerm                       # Script pre-eliminación
├── data/
│   ├── opt/apps/ventoy/           # Archivos de Ventoy (descargados)
│   └── usr/share/
│       ├── applications/
│       │   └── Ventoy.desktop     # Entrada del menú de aplicaciones
│       ├── icons/                  # Iconos de la aplicación
│       └── doc/ventoy/
│           └── copyright           # Información de copyright
└── scripts/
    ├── build-deb.sh               # Script de construcción local
    └── get-latest-version.sh      # Obtener última versión de Ventoy
```

## Dependencias

El paquete requiere:

- `dpkg` (>= 1.5)
- `sed` (>= 4.5)
- `grep` (>= 3.1)
- `coreutils` (>= 8.20)

## Ejecutar Ventoy

Después de la instalación, puedes ejecutar Ventoy de varias formas:

1. **Desde el menú de aplicaciones**: Busca "Ventoy" en tu menú de aplicaciones
2. **Desde la terminal**:
   ```bash
   /opt/apps/ventoy/VentoyGUI.x86_64
   ```

## Desinstalación

```bash
sudo apt-get remove ventoy
```

## Licencia

Este proyecto de empaquetado está bajo licencia MIT. Ventoy en sí está bajo su propia licencia (GPL v3+).

## Créditos

- **Ventoy**: [https://github.com/ventoy/Ventoy](https://github.com/ventoy/Ventoy)
- **Mantenedor del paquete**: Alvaro Samudio <alvarosamudio@protonmail.com>

## Soporte

Para problemas con Ventoy en sí, visita el [repositorio oficial](https://github.com/ventoy/Ventoy/issues).

Para problemas con este paquete DEB, abre un issue en este repositorio.
