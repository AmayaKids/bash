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
Генерирует SSH-ключ для репозитория (чтобы в ставить в GitHub) и формирует для него хост в config'е ssh.
```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/AmayaKids/bash/main/makeRepoSSH.sh?t=2)"
```
