# On part de la version officielle que tu utilisais
FROM ghcr.io/metatool-ai/metamcp:2.4

# On passe en root pour installer les paquets
USER root

# 1. Installation de Chromium et Xvfb (indispensable pour 'real-browser' en mode headless)
# On installe aussi les polices pour éviter les carrés bizarres sur les captures
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        gnupg \
        wget \
        xvfb \
        fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst fonts-freefont-ttf; \
    if apt-get install -y --no-install-recommends chromium; then \
        true; \
    elif apt-get install -y --no-install-recommends chromium-browser; then \
        true; \
    else \
        wget -qO- https://dl.google.com/linux/linux_signing_key.pub \
          | gpg --dearmor -o /usr/share/keyrings/google-linux.gpg; \
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/google-linux.gpg] http://dl.google.com/linux/chrome/deb/ stable main" \
          > /etc/apt/sources.list.d/google-chrome.list; \
        apt-get update; \
        apt-get install -y --no-install-recommends google-chrome-stable; \
        ln -s /usr/bin/google-chrome /usr/bin/chromium; \
    fi; \
    if [ ! -x /usr/bin/chromium ] && [ -x /usr/bin/chromium-browser ]; then \
        ln -s /usr/bin/chromium-browser /usr/bin/chromium; \
    fi; \
    rm -rf /var/lib/apt/lists/*

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
