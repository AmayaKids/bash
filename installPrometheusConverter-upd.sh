#!/bin/bash


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

systemctl enable PrometheusConverter
systemctl start PrometheusConverter

echo "----- PrometheusConverter updated! -----"
