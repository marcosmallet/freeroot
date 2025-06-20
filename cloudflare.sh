#!/bin/bash
set -e

# Checagem do parâmetro da porta
if [ -z "$1" ]; then
  echo "Uso: $0 <porta>"
  exit 1
fi
PORT="$1"

LOGFILE="tunnel.log"

# Inicia o túnel (Quick Tunnel) com HTTP/2 e logs
cloudflared tunnel \
  --url http://localhost:$PORT \
  --protocol http2 \
  --logfile "$LOGFILE" \
  --loglevel info &
TUNNEL_PID=$!

echo "Aguardando o tunnel iniciar (10s)..."
sleep 10

# Extrai a URL pública gerada
URL=$(grep -Eo 'https://[a-zA-Z0-9-]+\.trycloudflare\.com' "$LOGFILE" | head -n 1)

# Resultado
if [ -n "$URL" ]; then
  echo
  echo "🌐 Tunnel pronto em: $URL"
else
  echo
  echo "⚠️ URL não encontrada nos logs ($LOGFILE). Verifique manualmente."
fi

echo
echo "🔌 Servidor local exposto em http://localhost:$PORT"
echo
echo "🧩 Info do processo:"
echo "  PID do cloudflared: $TUNNEL_PID"
echo
echo "🛠️ Use 'kill $TUNNEL_PID' para encerrar o túnel."
