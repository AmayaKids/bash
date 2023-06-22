#!/bin/bash


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

systemctl enable AGSUserLogger
systemctl start AGSUserLogger

echo "----- AGSUserLogger updated! -----"
