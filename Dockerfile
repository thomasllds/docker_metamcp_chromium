# On part de la version officielle que tu utilisais
FROM ghcr.io/metatool-ai/metamcp:2.4

# On passe en root pour installer les paquets
USER root

# 1. Installation de Chromium et Xvfb (indispensable pour 'real-browser' en mode headless)
# On installe aussi les polices pour éviter les carrés bizarres sur les captures
RUN apt-get update && apt-get install -y \
    chromium \
    chromium-sandbox \
    xvfb \
    fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst fonts-freefont-ttf \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# 2. Définition des variables d'environnement pour Puppeteer
# Cela dit à ton MCP server où trouver le chrome qu'on vient d'installer
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium
ENV CHROME_PATH=/usr/bin/chromium

# (Optionnel) Si 'real-browser' a besoin d'un display virtuel actif par défaut
ENV DISPLAY=:99

# On repasse sur l'utilisateur par défaut (souvent node ou nextjs dans ces images)
# Si l'image de base utilise un user spécifique, on essaie de rester root pour le lancement 
# ou on s'assure que l'utilisateur a les droits. 
# Pour MetaMCP, restons safe :
USER root

# Commande de démarrage (on garde celle de l'image de base, ou on lance via xvfb-run si besoin)
# Pour l'instant, on laisse l'entrypoint par défaut de MetaMCP.