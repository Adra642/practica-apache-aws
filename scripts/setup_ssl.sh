#!/bin/bash

# Carga de variables desde el archivo .env
if [ -f .env ]; then
  set -a
  source <(sed 's/\r$//' .env)
  set +a
else
  echo "Error: El archivo .env no existe."
  exit 1
fi

echo "=== Instalando Certbot y generando certificado HTTPS ==="
sudo apt update -y
sudo apt install -y certbot python3-certbot-apache

# Solicitud desatendida del certificado e integracion con redireccion automatica a HTTPS
sudo certbot --apache \
  -d "${DOMAIN}" \
  --non-interactive \
  --agree-tos \
  -m "${EMAIL}" \
  --redirect

echo "=== Certificado SSL instalado y configurado correctamente ==="
