# проверяем на наличие включенного сервиса cronmanager, если включен, то выключаем
if [ -f /etc/systemd/system/CronManager.service ]; then
    systemctl stop cronmanager
    systemctl disable cronmanager
fi

# проверяем на наличие файла /usr/local/bin/cronmanager, если есть, удаляем
if [ -f /usr/local/bin/cronmanager ]; then
    rm -rf /usr/local/bin/cronmanager
fi

# скачиваем утилиту
wget -O /usr/local/bin/cronmanager https://storage.yandexcloud.net/testcloudstore/cronmanager/cronmanager
chmod +x /usr/local/bin/cronmanager

service_entry="[Unit]
Description=Cron Manager
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
WorkingDirectory=/usr/local/bin
ExecStart=/usr/local/bin/cronmanager

[Install]
WantedBy=multi-user.target
"

# Проверяем на наличие сервиса CronManager (если нет, то создаем)
if [ ! -f /etc/systemd/system/CronManager.service ]; then
    touch /etc/systemd/system/CronManager.service

    # Заполняем файл сервиса
    echo "$service_entry" > /etc/systemd/system/CronManager.service

    # Enable and start the CronManager service
    systemctl enable CronManager
    systemctl start CronManager

else
    systemctl enable CronManager
    systemctl restart CronManager
fi

if ! sudo iptables -L | grep --quiet --line-regexp "DROP.*tcp dpt:9691"; then
  iptables -A INPUT -p tcp -s localhost --dport 9691 -j ACCEPT
  iptables -A INPUT -p tcp --dport 9691 -j DROP
  echo "— Правило firewall установлено."
fi

# Добавляем конфигурацию для prometheus
if cat /etc/prometheus/prometheus.yml | grep --quiet "job_name: cronmanager_exporter"; then
  echo "— Конфигурация cronmanager_exporter для Prometheus уже присутствует."
else
  echo "— Добавляем конфигурацию для prometheus"
  echo '  - job_name: cronmanager_exporter
    scrape_interval: 10s
    static_configs:
      - targets:
          - localhost:9691' | sudo tee -a /etc/prometheus/prometheus.yml
  systemctl restart prometheus
fi

echo "----- CronManager is running -----"
echo "CronManager bin: /usr/local/bin/cronmanager"
echo "CronManager config: /etc/cronmanager/config.json"
echo "CronManager service: /etc/systemd/system/CronManager.service"
echo "CronManager status: systemctl status CronManager"
echo "Usage:"
echo "  cronmanager -n \"NAME\" -c \"COMMAND\""
echo "  ! Do not forget to update your crontab: crontab -e"
