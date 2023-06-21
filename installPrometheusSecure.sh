#!/bin/bash

# Инструмент для создания домена для Prometheus с SSL сертификатом

while getopts ":a:z:s:f:h" opt; do
  case $opt in
    a)
      API_KEY="$OPTARG"
      ;;
    z)
      ZONE_ID="$OPTARG"
      ;;
    s)
      SUBDOMAIN="$OPTARG"
      ;;
    f)
      FORCED="$OPTARG"
      ;;
    h)
      echo "Usage: $0 [-a API_KEY] [-z ZONE_ID] [-s SUBDOMAIN] [-f FORCED]" >&2
      exit 1
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

# Проверка на root
if [ "$(id -u)" != "0" ]; then
  echo "Этот сценарий должен выполняться от имени root" 1>&2
  exit 1
fi

# Проверяем наличие nginx
if ! [ -x "$(command -v nginx)" ]; then
  echo 'Ошибка: nginx не установлен.' >&2
  exit 1
fi

# Проверяем наличие certbot
if ! [ -x "$(command -v certbot)" ]; then
  echo 'Ошибка: certbot не установлен.' >&2
  exit 1
fi

# Проверяем наличие prometheus по /etc/prometheus/prometheus.yml
if ! [ -f "/etc/prometheus/prometheus.yml" ]; then
  echo 'Ошибка: prometheus не установлен.' >&2
  exit 1
fi

# Проверяем, что порт 9090 открыт для localhost и закрываем его для всех кроме localhost
echo "Обновляем правила для порта 9090: закрываем от мира, открываем для localhost"
iptables-save | grep -v "\-A INPUT.*tcp.*9090" | iptables-restore
iptables -A INPUT -p tcp -s localhost --dport 9090 -j ACCEPT
iptables -A INPUT -p tcp --dport 9090 -j DROP

# Очищаем web-config prometheus, если он есть
if [ -f "/etc/prometheus/web.yml" ]; then
  echo "- Очищаем web-config prometheus"
  echo "" > /etc/prometheus/web.yml
fi

# Перезапускаем prometheus
echo "- Перезапускаем prometheus"
systemctl restart prometheus

# Получаем Bearer Token для Cloudflare
if [ -z "$API_KEY" ]; then
  echo "Введите Bearer Token для Cloudflare:"
  read -r API_KEY
fi

# Получаем ZONE ID для Cloudflare
if [ -z "$ZONE_ID" ]; then
  echo "Введите ZONE ID для Cloudflare:"
  read -r ZONE_ID
fi

# Получаем название поддомена для *.prometheus.amayakids.com
if [ -z "$SUBDOMAIN" ]; then
  echo "Введите название поддомена для *.prometheus.amayakids.com:"
  read -r SUBDOMAIN
fi

# Получаем IP адрес сервера (hostname -I первый IP)
IP=$(hostname -I | cut -d' ' -f1)
echo "- IP адрес сервера: $IP"

# Проверяем, что домен ещё не зарегистрирован в Cloudflare через CURL (без jq)
echo "Проверяем, что домен ещё не зарегистрирован в Cloudflare"
AUTH_HEADER="Authorization: Bearer $API_KEY"
EXISTING_DOMAIN_CHECK=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?type=A&name=$SUBDOMAIN.prometheus.amayakids.com" \
  -H "Content-Type: application/json" \
  -H "$AUTH_HEADER")

DOMAIN_EXISTS_ON_CLOUDFLARE=false

echo "$EXISTING_DOMAIN_CHECK"

if [[ $EXISTING_DOMAIN_CHECK == *"created_on"* ]]; then
  echo "Ошибка: домен $SUBDOMAIN.prometheus.amayakids.com уже зарегистрирован в Cloudflare." >&2
  DOMAIN_EXISTS_ON_CLOUDFLARE=true
  
  # Хотите продолжить?
  if [ -z "$FORCED" ]; then
    echo "Хотите продолжить? (y/n)"
    read -r CONTINUE
  
    # Если не продолжаем, то выходим
    if [[ $CONTINUE != "y" ]]; then
      echo "Выход..."
      exit 1
    fi
  fi
fi

# Создаём домен в Cloudflare через CURL (без jq)
echo "Создаём домен $SUBDOMAIN.prometheus.amayakids.com в Cloudflare"
if [[ $DOMAIN_EXISTS_ON_CLOUDFLARE == false ]]; then
  NEW_DOMAIN=$(curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" \
    -H "Content-Type: application/json" \
    -H "$AUTH_HEADER" \
    --data "{\"type\":\"A\",\"name\":\"$SUBDOMAIN.prometheus.amayakids.com\",\"content\":\"$IP\",\"ttl\":120,\"proxied\":false}")
fi


# Делаем SSL сертификат через certbot
echo "Делаем SSL сертификат через certbot"
certbot certonly --nginx -d $SUBDOMAIN.prometheus.amayakids.com --agree-tos --email admin@amayakids.com --non-interactive


# Создаем/перезаписываем конфигурацию Nginx
echo "Создаем/перезаписываем конфигурацию Nginx"
cat > "/etc/nginx/conf.d/$SUBDOMAIN.prometheus.amayakids.com.conf" <<-EOL
server {
  listen 443 ssl;
  server_name $SUBDOMAIN.prometheus.amayakids.com;

  ssl_certificate /etc/letsencrypt/live/$SUBDOMAIN.prometheus.amayakids.com/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/$SUBDOMAIN.prometheus.amayakids.com/privkey.pem;

  location / {
    proxy_pass http://localhost:9009;
    proxy_http_version 1.1;
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
  }
}
EOL


# Тестируем конфигурацию Nginx, и если всё хорошо, перезапускаем Nginx
echo "Тестируем конфигурацию Nginx, и если всё хорошо, перезапускаем Nginx"
if nginx -t; then
  echo "- Перезапускаем Nginx"
  systemctl restart nginx
fi

echo "------- ГОТОВО ----------"

echo "Домен: $SUBDOMAIN.prometheus.amayakids.com"
echo "IP адрес сервера: $IP"
echo "SSL сертификат: /etc/letsencrypt/live/$SUBDOMAIN.prometheus.amayakids.com/fullchain.pem"
echo "NGINX конфигурация: /etc/nginx/conf.d/$SUBDOMAIN.prometheus.amayakids.com.conf"
echo "! Не забудь добавить этот сервер в центральный Prometheus"
