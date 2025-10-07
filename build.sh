#!/bin/bash
set -e

# Nettoyer les anciens builds
rm -f ../bashrc-script-custom_*.deb ../bashrc-script-custom_*.buildinfo ../bashrc-script-custom_*.changes

# Générer la version
VERSION="1.0.2"  # ou 1.0-$(date +%Y%m%d%H%M)

# Build le package
dpkg-deb --build debian/bashrc-script-custom ../bashrc-script-custom_${VERSION}_all.deb

echo "✓ Package créé : ../bashrc-script-custom_${VERSION}_all.deb"
