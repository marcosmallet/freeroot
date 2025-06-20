#!/bin/bash

set -e  # Encerra o script se algum comando falhar

# Atualiza os pacotes e instala dependências básicas
apt update
apt install --yes sudo curl

# Atualiza o arquivo /etc/hosts
sudo sh -c 'echo "127.0.0.1\tlocalhost\n::1\tlocalhost" >> /etc/hosts'

# Adiciona a chave GPG da Cloudflare
sudo mkdir -p --mode=0755 /usr/share/keyrings
curl --insecure -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | sudo tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null

# Adiciona o repositório do Cloudflared
echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared focal main' | sudo tee /etc/apt/sources.list.d/cloudflared.list

# Instala o Cloudflared
sudo apt-get update
sudo apt-get install --yes cloudflared
