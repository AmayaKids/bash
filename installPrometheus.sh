#!/bin/bash

# Проверка наличия пользователя prometheus
if ! id -u prometheus >/dev/null 2>&1; then
    sudo adduser --no-create-home --disabled-login --shell /bin/false --gecos "Prometheus Monitoring User" prometheus
fi

# Проверка наличия директорий
sudo mkdir -p /etc/prometheus /var/lib/prometheus

# Создание файлов конфигурации
sudo touch /etc/prometheus/prometheus.yml
sudo touch /etc/prometheus/prometheus.rules.yml

# Устанавливаем права на файлы и папки
sudo chown -R prometheus:prometheus /etc/prometheus
sudo chown prometheus:prometheus /var/lib/prometheus

# Скачиваем последнюю версию Prometheus, если он еще не установлен
if ! command -v prometheus &>/dev/null; then
    VERSION=$(curl https://raw.githubusercontent.com/prometheus/prometheus/master/VERSION)
    wget https://github.com/prometheus/prometheus/releases/download/v${VERSION}/prometheus-${VERSION}.linux-amd64.tar.gz
    tar xvzf prometheus-${VERSION}.linux-amd64.tar.gz
    sudo cp prometheus-${VERSION}.linux-amd64/prometheus /usr/local/bin/
    sudo cp prometheus-${VERSION}.linux-amd64/promtool /usr/local/bin/
    sudo cp -r prometheus-${VERSION}.linux-amd64/consoles /etc/prometheus
    sudo cp -r prometheus-${VERSION}.linux-amd64/console_libraries /etc/prometheus
    sudo chown -R prometheus:prometheus /etc/prometheus/consoles
    sudo chown -R prometheus:prometheus /etc/prometheus/console_libraries
    sudo chown prometheus:prometheus /usr/local/bin/prometheus
    sudo chown prometheus:prometheus /usr/local/bin/promtool
fi

# Клонируем репозиторий с файлами конфигурации (если еще не производили клонирование)
if [ ! -d ./prometheus-install ]; then
    git clone https://github.com/petarnikolovski/prometheus-install.git
fi

# Копируем файлы конфигурации prometheus
cd prometheus-install/
cat ./prometheus/prometheus.yml | sudo tee /etc/prometheus/prometheus.yml
cat ./prometheus/prometheus.rules.yml | sudo tee /etc/prometheus/prometheus.rules.yml
cat ./prometheus/prometheus.service | sudo tee /etc/systemd/system/prometheus.service

# Включаем и стартуем prometheus, если он ещё не работает
if ! systemctl is-active --quiet prometheus; then
    sudo systemctl enable prometheus
    sudo systemctl start prometheus
fi

# Применение новой конфигурации systemd к prometheus
cat << EOF | sudo tee /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
EOF

# Очищаем правила (тестовые алерты)
echo -n "" > /etc/prometheus/prometheus.rules.yml

# Устанавливаем конфигурацию на все прометеусы
config_entry="global:
  scrape_interval: 15s
rule_files:
  - 'prometheus.rules.yml'
scrape_configs:
  - job_name: 'prometheus'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9090']
  - job_name: 'api'
    scrape_interval: 5s
    metrics_path: /metrics
    static_configs:
      - targets: ['localhost:9292']
  - job_name: 'redis_exporter'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9121']
  - job_name: pm2-metrics
    scrape_interval: 10s
    scrape_timeout: 10s
    metrics_path: /metrics
    scheme: http
    static_configs:
      - targets:
          - localhost:9209
  - job_name: node_exporter
    scrape_interval: 10s
    static_configs:
      - targets:
          - localhost:9100
  - job_name: 'postgresql_exporter'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9187']
"
echo "$config_entry" > /etc/prometheus/prometheus.yml

# Релоад systemctl
sudo systemctl daemon-reload

# Закрываем внешние порты
iptables -A INPUT -p tcp -s localhost --dport 9090 -j ACCEPT
iptables -A INPUT -p tcp --dport 9090 -j DROP

# Запуск prometheus
sudo systemctl start prometheus

echo "Prometheus:"
echo "nano /etc/prometheus/prometheus.yml"
echo "systemctl status prometheus"
echo "systemctl restart prometheus"
echo "systemctl start prometheus"
echo "systemctl stop prometheus"
echo "! Сейчас установите PrometheusConverter"
