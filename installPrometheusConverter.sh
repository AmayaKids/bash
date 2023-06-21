#!/bin/bash

while getopts ":n:p:f:h" opt; do
  case $opt in
    n)
      SERVER_NAME="$OPTARG"
      ;;
    p)
      PASSWORD="$OPTARG"
      ;;
    f)
      FORCED="$OPTARG"
      ;;
    h)
      echo "Usage: $0 [-n SERVER_NAME] [-p PASSWORD] [-f FORCED]" >&2
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


# Создаем директорию
mkdir -p /go/PrometheusConverter

ENV_REWRITE=0

# Проверяем на наличие файла .env (если нет, то создаем)
if [ ! -f /go/PrometheusConverter/.env ]; then
    touch /go/PrometheusConverter/.env
    ENV_REWRITE=1
else
    if [ -z "$FORCED" ]; then
        echo ".env файл уже существует, желаете перезаписать? (y/n)"
        read answer
    
        if [ "$answer" == "y" ]; then
            ENV_REWRITE=1
        fi
    else
        ENV_REWRITE=1
    fi
fi

if [ $ENV_REWRITE == 1 ]; then
  # Спрашиваем название сервера
  if [ -z "$SERVER_NAME" ]; then
      echo "Введите название сервера:"
      read SERVER_NAME
  fi

  # Спрашиваем пароль
  if [ -z "$PASSWORD" ]; then
      echo "Введите пароль:"
      read PASSWORD
  fi

  PORT=9009

  env_entry="SERVER_NAME=$SERVER_NAME
PASSWORD=$PASSWORD
PORT=$PORT"

  echo "$env_entry" > /go/PrometheusConverter/.env
fi

# Скачиваем утилиту
# проверяем на наличие включенного сервиса PrometheusConverter, если включен, то выключаем
if [ -f /etc/systemd/system/PrometheusConverter.service ]; then
    systemctl stop PrometheusConverter
    systemctl disable PrometheusConverter
fi

# проверяем на наличие файла /go/PrometheusConverter/bin, если есть, удаляем
if [ -f /go/PrometheusConverter/bin ]; then
    rm -rf /go/PrometheusConverter/bin
fi

wget -O /go/PrometheusConverter/bin https://storage.yandexcloud.net/testcloudstore/PrometheusConverter/PrometheusConverter
chmod +x /go/PrometheusConverter/bin

service_entry="[Unit]
Description=Prometheus Converter
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
WorkingDirectory=/go/PrometheusConverter/
ExecStart=/go/PrometheusConverter/bin

[Install]
WantedBy=multi-user.target
"

# Проверяем на наличие сервиса PrometheusConverter (если нет, то создаем)
if [ ! -f /etc/systemd/system/PrometheusConverter.service ]; then
    touch /etc/systemd/system/PrometheusConverter.service

    # Заполняем файл сервиса
    echo "$service_entry" > /etc/systemd/system/PrometheusConverter.service

    # Enable and start the PrometheusConverter service
    systemctl enable PrometheusConverter
    systemctl start PrometheusConverter

else
    systemctl enable PrometheusConverter
    systemctl restart PrometheusConverter
fi

echo "----- PrometheusConverter is running -----"
echo "PrometheusConverter bin: /go/PrometheusConverter/bin"
echo "PrometheusConverter .env: /go/PrometheusConverter/.env"
echo "PrometheusConverter service: /etc/systemd/system/PrometheusConverter.service"
echo "PrometheusConverter status: systemctl status PrometheusConverter"
