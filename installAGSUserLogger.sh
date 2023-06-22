#!/bin/bash

while getopts ":n:f:h" opt; do
  case $opt in
    n)
      SERVER_NAME="$OPTARG"
      ;;
    f)
      FORCED="$OPTARG"
      ;;
    h)
      echo "Usage: $0 [-n SERVER_NAME] [-f FORCED]" >&2
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
mkdir -p /go/AGSUserLogger

ENV_REWRITE=0

# Проверяем на наличие файла .env (если нет, то создаем)
if [ ! -f /go/AGSUserLogger/.env ]; then
    touch /go/AGSUserLogger/.env
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

  PORT=4444

  env_entry="SERVER_NAME=$SERVER_NAME
PORT=$PORT"

  echo "$env_entry" > /go/AGSUserLogger/.env
fi

# Скачиваем утилиту
# проверяем на наличие включенного сервиса AGSUserLogger, если включен, то выключаем
if [ -f /etc/systemd/system/AGSUserLogger.service ]; then
    systemctl stop AGSUserLogger
    systemctl disable AGSUserLogger
fi

# проверяем на наличие файла /go/AGSUserLogger/bin, если есть, удаляем
if [ -f /go/AGSUserLogger/bin ]; then
    rm -rf /go/AGSUserLogger/bin
fi

wget -O /go/AGSUserLogger/bin https://storage.yandexcloud.net/testcloudstore/AGSUserLogger/AGSUserLogger
chmod +x /go/AGSUserLogger/bin

service_entry="[Unit]
Description=AGS User Logger
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
WorkingDirectory=/go/AGSUserLogger/
ExecStart=/go/AGSUserLogger/bin

[Install]
WantedBy=multi-user.target
"

# Проверяем на наличие сервиса AGSUserLogger (если нет, то создаем)
if [ ! -f /etc/systemd/system/AGSUserLogger.service ]; then
    touch /etc/systemd/system/AGSUserLogger.service

    # Заполняем файл сервиса
    echo "$service_entry" > /etc/systemd/system/AGSUserLogger.service

    # Enable and start the AGSUserLogger service
    systemctl enable AGSUserLogger
    systemctl start AGSUserLogger

else
    systemctl enable AGSUserLogger
    systemctl restart AGSUserLogger
fi

echo "----- AGSUserLogger is running -----"
echo "AGSUserLogger bin: /go/AGSUserLogger/bin"
echo "AGSUserLogger .env: /go/AGSUserLogger/.env"
echo "AGSUserLogger service: /etc/systemd/system/AGSUserLogger.service"
echo "AGSUserLogger status: systemctl status AGSUserLogger"
