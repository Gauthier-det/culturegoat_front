#!/bin/bash

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo "============================================"
echo "🎨 CultureGoat Frontend - Build Production"
echo "============================================"
echo ""

# Vérifier que .env.production existe
if [ ! -f .env.production ]; then
    echo -e "${RED}❌ Fichier .env.production manquant${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Fichier .env.production détecté${NC}"
echo ""

# Installer les dépendances
echo "📦 Installation des dépendances..."
npm install

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Erreur lors de l'installation${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Dépendances installées${NC}"
echo ""

# Build de production
echo "🔨 Build de production..."
npm run build

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Erreur lors du build${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Build réussi${NC}"
echo ""

# Analyser la taille du build
echo "📊 Analyse de la taille du build :"
du -sh dist
echo ""
echo "Fichiers générés :"
ls -lh dist/assets/ | head -n 10

echo ""
echo "============================================"
echo -e "${GREEN}✅ Build terminé !${NC}"
echo "============================================"
echo ""
echo "Le dossier 'dist' contient l'application prête pour la production"
echo "Vous pouvez le déployer sur un serveur statique (Nginx, Vercel, Netlify...)"
echo ""
