#!/bin/bash

# Проверки перед запуском
if ! command -v prometheus >/dev/null; then
  echo "Prometheus не найден, проверьте его наличие. Выход."
  exit 1
fi

# Устанавливаем node_exporter
if command -v node_exporter >/dev/null; then
  echo "- node_exporter запускается: уже установлен."
else
  echo "- Скачивание и установка node_exporter"
  # Скачиваем node_exporter
  wget https://github.com/prometheus/node_exporter/releases/download/v1.6.0/node_exporter-1.6.0.linux-amd64.tar.gz
  # Распаковываем архив
  tar xvfz node_exporter-1.6.0.linux-amd64.tar.gz
  cd node_exporter-1.6.0.linux-amd64/

  # Копируем исполняемый файл и устанавливаем права
  sudo cp ./node_exporter /usr/local/bin
  sudo chown root:root /usr/local/bin/node_exporter
  sudo chmod 755 /usr/local/bin/node_exporter
fi


# Создаем и настраиваем файл службы systemd
echo '[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=root
Group=root
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target' | sudo tee /etc/systemd/system/node_exporter.service

# Перезагружаем systemd, включаем и запускаем службу node_exporter
echo "— Перезагружаем systemd, включаем и запускаем службу node_exporter"
sudo systemctl daemon-reload
sudo systemctl enable node_exporter
sudo systemctl start node_exporter

# Протестировать работоспособность
echo "— Тест экспортера"
curl http://localhost:9100/metrics

# Настраиваем firewall
if ! sudo iptables -L | grep --quiet --line-regexp "DROP.*tcp dpt:9100"; then
  iptables -A INPUT -p tcp -s localhost --dport 9100 -j ACCEPT
  iptables -A INPUT -p tcp --dport 9100 -j DROP
  echo "— Правило firewall установлено."
fi


# Добавляем конфигурацию для prometheus
if cat /etc/prometheus/prometheus.yml | grep --quiet "job_name: node_exporter"; then
  echo "— Конфигурация node_exporter для Prometheus уже присутствует."
else
  echo "— Добавляем конфигурацию для prometheus"
  echo '  - job_name: node_exporter
      scrape_interval: 10s
      static_configs:
        - targets:
            - localhost:9100' | sudo tee -a /etc/prometheus/prometheus.yml
fi


# Перезапускаем службу prometheus
echo "— Перезапуск prometheus"
systemctl restart prometheus
systemctl status prometheus
echo "— Готово!"
