#!/bin/bash

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration - À MODIFIER selon votre serveur
SERVER_USER=${SERVER_USER:-"root"}
SERVER_HOST=${SERVER_HOST:-"your-server.com"}
SERVER_PATH=${SERVER_PATH:-"/var/www/culturegoat"}

echo "============================================"
echo "🚀 CultureGoat Frontend - Deploy Script"
echo "============================================"
echo ""

echo -e "${BLUE}📍 Serveur: $SERVER_USER@$SERVER_HOST${NC}"
echo -e "${BLUE}📍 Destination: $SERVER_PATH${NC}"
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

# Déploiement avec rsync
echo "📤 Déploiement sur le serveur..."
rsync -avz --delete dist/ $SERVER_USER@$SERVER_HOST:$SERVER_PATH

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Erreur lors du déploiement${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Déploiement réussi${NC}"
echo ""

# Test du site
echo "🔍 Test du site..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" https://$SERVER_HOST)

if [ "$HTTP_CODE" -eq 200 ]; then
    echo -e "${GREEN}✅ Site accessible (HTTP $HTTP_CODE)${NC}"
else
    echo -e "${YELLOW}⚠️  Site répond avec HTTP $HTTP_CODE${NC}"
fi

echo ""
echo "============================================"
echo -e "${GREEN}✅ Déploiement terminé !${NC}"
echo "============================================"
echo ""
echo "URL: https://$SERVER_HOST"
echo ""
