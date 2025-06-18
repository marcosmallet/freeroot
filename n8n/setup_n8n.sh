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

# Instala Node.js 22 e n8n
curl --insecure -fsSL https://deb.nodesource.com/setup_22.x | sudo bash -
sudo apt-get install --yes nodejs
sudo npm install -g n8n@latest

# Inicia o túnel com Cloudflared
cloudflared tunnel --url http://localhost:5678 > tunnel.log 2>&1 &
TUNNEL_PID=$!
sleep 5

# Extrai a URL do webhook gerado pelo Cloudflare
URL=$(grep -o 'https://[^ ]*trycloudflare.com' tunnel.log)
export WEBHOOK_URL=URL

# Inicia o n8n
n8n > n8n.log 2>&1 &
N8N_PID=$!

# Exibe informações úteis
echo "Webhook URL:"
echo $URL
echo
echo "Processos em segundo plano:"
echo "Cloudflared PID: $TUNNEL_PID"
echo "n8n PID: $N8N_PID"
echo
echo "Use 'kill <PID>' para encerrar qualquer um desses processos se necessário."
