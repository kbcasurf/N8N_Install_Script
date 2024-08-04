#!/bin/bash
# Variáveis cores de fontes
YL='\033[1;33m'      # Yellow
RED='\033[1;31m'         # Red
GR='\033[0;32m'        # Green

# Script para Automação da Instalação do N8N
# Prompt para variáveis de configuração
read -p "Digite o nome do domínio (ex: example.com): " DOMAIN_NAME
read -p "Digite o subdomínio (ex: n8n): " SUBDOMAIN
read -p "Digite o diretório HOME para armazenar os arquivos do N8N (ex: /home/user/n8n): " HOME_DIR
read -p "Digite o e-mail para certificados SSL (ex: user@example.com): " SSL_EMAIL
read -p "Digite o código UTC para fuso horário (ex: America/Sao_Paulo): " GENERIC_TIMEZONE
echo -e "${YL}Fuso horário padrão definido como: $GENERIC_TIMEZONE${GR}"


# Função para criar o arquivo .env
create_env_file() {
  echo -e "${YL}Criando arquivo .env...${GR}"
  cat <<EOL > .env

DOMAIN_NAME=${DOMAIN_NAME}

SUBDOMAIN=${SUBDOMAIN}

GENERIC_TIMEZONE=${GENERIC_TIMEZONE}

SSL_EMAIL=${SSL_EMAIL}

EOL
}


# Função para criar o arquivo docker-compose.yml
create_docker_compose_file() {
  echo -e "Criando docker-compose.yml..."
  cat <<EOL > docker-compose.yml
services:
  traefik:
    image: "traefik"
    restart: always
    command:
      - "--api=true"
      - "--api.insecure=true"
      - "--providers.docker=true"
      - "--providers.docker.exposedbydefault=false"
      - "--entrypoints.web.address=:80"
      - "--entrypoints.web.http.redirections.entryPoint.to=websecure"
      - "--entrypoints.web.http.redirections.entrypoint.scheme=https"
      - "--entrypoints.websecure.address=:443"
      - "--certificatesresolvers.mytlschallenge.acme.tlschallenge=true"
      - "--certificatesresolvers.mytlschallenge.acme.email=${SSL_EMAIL}"
      - "--certificatesresolvers.mytlschallenge.acme.storage=/letsencrypt/acme.json"
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - traefik_data:/letsencrypt
      - /var/run/docker.sock:/var/run/docker.sock:ro

  n8n:
    image: docker.n8n.io/n8nio/n8n
    restart: always
    ports:
      - "127.0.0.1:5678:5678"
    labels:
      - traefik.enable=true
      - traefik.http.routers.n8n.rule=Host("${SUBDOMAIN}.${DOMAIN_NAME}")
      - traefik.http.routers.n8n.tls=true
      - traefik.http.routers.n8n.entrypoints=web,websecure
      - traefik.http.routers.n8n.tls.certresolver=mytlschallenge
      - traefik.http.middlewares.n8n.headers.SSLRedirect=true
      - traefik.http.middlewares.n8n.headers.STSSeconds=315360000
      - traefik.http.middlewares.n8n.headers.browserXSSFilter=true
      - traefik.http.middlewares.n8n.headers.contentTypeNosniff=true
      - traefik.http.middlewares.n8n.headers.forceSTSHeader=true
      - traefik.http.middlewares.n8n.headers.SSLHost=${DOMAIN_NAME}
      - traefik.http.middlewares.n8n.headers.STSIncludeSubdomains=true
      - traefik.http.middlewares.n8n.headers.STSPreload=true
      - traefik.http.routers.n8n.middlewares=n8n@docker
    environment:
      - N8N_HOST=${SUBDOMAIN}.${DOMAIN_NAME}
      - N8N_PORT=5678
      - N8N_PROTOCOL=https
      - NODE_ENV=production
      - WEBHOOK_URL=https://${SUBDOMAIN}.${DOMAIN_NAME}/
      - GENERIC_TIMEZONE=${GENERIC_TIMEZONE}
    volumes:
      - ${HOME_DIR}:/files
      - n8n_data:/home/node/.n8n

volumes:
  traefik_data:
    external: true
  n8n_data:
    external: true
EOL
}


# Função para criar os volumes do Docker
create_docker_volumes() {
  echo -e "Criando volumes do Docker..."
  docker volume create n8n_data
  sleep 1
  docker volume create traefik_data
  sleep 1
}

# Função para iniciar o N8N
start_n8n() {
  echo -e "${YL}Iniciando N8N..."
  docker compose up -d
  sleep 10
}

# Funções de arquivo
create_env_file
sleep 1

create_docker_compose_file
sleep 1

# Criar volumes docker
create_docker_volumes

# Iniciar N8N
start_n8n

echo -e "${RED}A instalação do N8N foi concluída. Acesse em: https://${SUBDOMAIN}.${DOMAIN_NAME}"
