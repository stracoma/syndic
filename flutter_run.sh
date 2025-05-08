#!/bin/bash
echo "Nettoyage du projet..."
flutter clean

echo "Récupération des dépendances..."
flutter pub get

echo "Lancement de l'application..."
flutter run

