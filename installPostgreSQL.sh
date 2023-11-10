#!/bin/bash

while getopts ":n:f:h" opt; do
  case $opt in
    p)
      PGPASSWORD="$OPTARG"
      ;;
    h)
      echo "Usage: $0 [-p PGPASSWORD]" >&2
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

# Проверка уже установленного PG
if [ -f /etc/postgresql/15/main/postgresql.conf ]
then
    echo "PostgreSQL уже установлен"
    exit 1
fi

# Установка PG
echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list
apt-get --yes install wget ca-certificates
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
apt-get update
apt install postgresql postgresql-contrib openssl
systemctl start postgresql.service

# Открытие портов
ufw allow 5432/tcp
ufw allow 5432/udp

# Установка пароля пользователю postgres в БД
if [ -z "$PGPASSWORD" ]
then
      echo "Введите пароль для пользователя postgres:"
      read PGPASSWORD
fi

sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD '$PGPASSWORD';"

# Рестарт PG
systemctl restart postgresql.service

# Вывод логов
tail /var/log/postgresql/postgresql-15-main.log

# Вывод
echo "Пароль пользователя postgres: $PGPASSWORD"
echo "Порт: 5432"
echo "Сервис: systemctl status postgresql.service"
