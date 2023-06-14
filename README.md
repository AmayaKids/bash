# bash
Bash скрипты

## createGithubActionUser.sh
Создаёт пользователя со случайным паролем для Github Actions
```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/AmayaKids/bash/main/createGithubActionUser.sh?t=1)"
```

## installNodeExporter.sh
Устанавливает node_exporter в систему и применяет конфигурацию к Prometheus
```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/AmayaKids/bash/main/installNodeExporter.sh?t=3)"
```

## makeRepoSSH.sh
Генерирует SSH-ключ для репозитория (чтобы вставить его в GitHub) и формирует для него хост в config'е ssh.
```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/AmayaKids/bash/main/makeRepoSSH.sh?t=4)"
```

## installPrometheus.sh
Устанавливает и делает первичную настройку prometheus.
```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/AmayaKids/bash/main/installPrometheus.sh?t=1)"
```

## installPrometheusConverter.sh
Скачивает последнюю версию утилиты по проектированию и изменению данных Prometheus federate и устанавливает её в качестве systemd-сервиса.  
Получает запрос, сравнивает Auth Bearer, запрашивает Prometheus federate, добавляет название сервера и возвращает статистику.  
Нужна для организации системы Grafana-prometheus на всех серверах.
```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/AmayaKids/bash/main/installPrometheusConverter.sh?t=5)"
```
Скрипт обновление утилиты:
```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/AmayaKids/bash/main/installPrometheusConverter-upd.sh?t=5)"
```

## installPrometheusSecure.sh
Закрывает Prometeus на сервере от внешнего мира, создаёт домен в Cloudflare и выпускает Let's Encrypt сертификат.  
Так же за доменом записывает прокси на порт :9009 — утилита PrometheusConverter.
```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/AmayaKids/bash/main/installPrometheusSecure.sh?t=1)"
```
