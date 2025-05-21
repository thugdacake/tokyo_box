#!/bin/bash

# Verifica se o pnpm está instalado
if ! command -v pnpm &> /dev/null; then
    echo "Instalando pnpm..."
    npm install -g pnpm
fi

# Verifica se o Node.js está instalado
if ! command -v node &> /dev/null; then
    echo "Node.js não encontrado. Por favor, instale o Node.js 18 ou superior."
    echo "Download: https://nodejs.org/"
    exit 1
fi

# Verifica a versão do Node.js
NODE_VERSION=$(node -v | cut -d'v' -f2)
REQUIRED_VERSION="18.0.0"

if [ "$(printf '%s\n' "$REQUIRED_VERSION" "$NODE_VERSION" | sort -V | head -n1)" != "$REQUIRED_VERSION" ]; then
    echo "Node.js versão $NODE_VERSION encontrada. Versão $REQUIRED_VERSION ou superior é necessária."
    echo "Por favor, atualize o Node.js: https://nodejs.org/"
    exit 1
fi

echo "Instalando dependências..."
pnpm install

echo "Construindo o projeto..."
pnpm build

echo "Iniciando o servidor..."
pnpm start 