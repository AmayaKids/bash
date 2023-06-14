#!/bin/bash

# Создаем директорию
mkdir -p /go/PrometheusConverter

# Спрашиваем название сервера
echo "Введите название сервера:"
read SERVER_NAME

# Спрашиваем пароль
echo "Введите пароль:"
read PASSWORD

PORT=9009

env_entry="SERVER_NAME=$SERVER_NAME
PASSWORD=$PASSWORD
PORT=$PORT
"

# Проверяем на наличие файла .env (если нет, то создаем)
if [ ! -f /go/PrometheusConverter/.env ]; then
    touch /go/PrometheusConverter/.env
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
echo "PrometheusConverter port: $PORT"
echo "PrometheusConverter server name: $SERVER_NAME"
echo "PrometheusConverter status: systemctl status PrometheusConverter"