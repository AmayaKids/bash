#!/bin/bash

# Создаем директорию
mkdir -p /node/Redisner

# Скачиваем утилиту
# проверяем на наличие включенного сервиса Redisner, если включен, то выключаем
if [ -f /etc/systemd/system/Redisner.service ]; then
    systemctl stop Redisner
    systemctl disable Redisner
fi

# проверяем на наличие файла /node/Redisner/bin, если есть, удаляем
if [ -f /node/Redisner/bin ]; then
    rm -rf /node/Redisner/bin
fi

wget -O /node/Redisner/bin https://storage.yandexcloud.net/testcloudstore/Redisner/redisner
chmod +x /node/Redisner/bin


# Проверяем на наличие сервиса Redisner в crontab (crontab -l)
if [ -f /etc/crontab ]; then
    if crontab -l | grep -q "Redisner"; then
        echo "Redisner is already in crontab"
    else
        echo "Redisner is not in crontab"

        # Проверяем на наличие cronmanager, чтобы записать в правильном формате
        if [ -f /usr/local/bin/cronmanager ]; then
            crontab -l | { cat; echo "cronmanager -n 'redisner' -c 'root /node/Redisner/bin'"; } | crontab -
            echo "Redisner is added to crontab as cronmanager"
        else
            crontab -l | { cat; echo "0 2 * * * root /node/Redisner/bin"; } | crontab -
            echo "Redisner is added to crontab as straight"
        fi
    fi
else
    echo "Crontab is not found"
fi

echo "----- Redisner is ready -----"
echo "Crontab: crontab -e"
echo "Location: /node/Redisner/bin"
