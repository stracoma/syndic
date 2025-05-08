#!/bin/bash

# Dossier de sauvegarde
DEST_DIR="$HOME/SauvegardesFlutter"
DATE=$(date +%Y-%m-%d)
BACKUP_DIR="$DEST_DIR/$DATE"

# Créer le dossier de destination s'il n'existe pas
mkdir -p "$BACKUP_DIR"

# Copier tous les fichiers .dart de lib/ (avec structure de dossiers)
find lib/ -type f -name "*.dart" -exec cp --parents {} "$BACKUP_DIR" \;

echo "✅ Sauvegarde terminée dans : $BACKUP_DIR"
