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
У скрипта есть аргументы:  
- -n REPO_NAME (оригинальное название репозитория в GitHub)

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
У скрипта есть аргументы:  
- -n SERVER_NAME (server_instance параметр в ответе)
- -p PASSWORD (пароль для запросов к прослойке)  

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
У скрипта есть аргументы:  
- -a API_KEY (Ключ для CloudFlare)
- -z ZONE_ID (ID зоны в CloudFlare)
- -s SUBDOMAIN (например, myserver)
- -f FORCED (да, при любом значении)

## installRedisner.sh
Устанавливает утилиту, которая удаляет старые сессии из Redis (по флагу activeAt).  
```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/AmayaKids/bash/main/installRedisner.sh?t=1)"
```

## installAGSUserLogger.sh
Устанавливает утилиту, которая собирает в пачки логи запросов пользователей (с body запроса и ответа) и отправляет в центральный Loki.
```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/AmayaKids/bash/main/installAGSUserLogger.sh?t=1)"
```
У скрипта есть аргументы:  
- -n SERVER_NAME (например, mx-prod)
- -f FORCED (да, при любом значении)
