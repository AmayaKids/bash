#!/bin/bash

while getopts ":n:h" opt; do
  case $opt in
    n)
      repo_name="$OPTARG"
      ;;
    h)
      echo "Usage: $0 [-n repo_name]" >&2
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

# Запросить имя репозитория
if [ -z "$repo_name" ]; then
  echo "Введите имя репозитория (например, MyService):"
  read repo_name
fi

if [ -f ~/.ssh/"$repo_name" ]; then
  echo "Ошибка: ключ SSH с таким именем уже существует. Выход."
  exit 1
fi

if grep -q "Host $repo_name" ~/.ssh/config; then
  echo "Ошибка: хост с таким именем уже существует. Выход."
  exit 1
fi

# Генерация ключа SSH с именем репозитория
ssh-keygen -t rsa -b 2048 -f ~/.ssh/"$repo_name" -N ""

# Добавление записи в .ssh/config
config_entry="# $repo_name repo
Host $repo_name
HostName github.com
PreferredAuthentications publickey
IdentityFile ~/.ssh/$repo_name"

echo "$config_entry" >> ~/.ssh/config

# Вывод публичного ключа
echo "Публичный ключ:"
cat ~/.ssh/"$repo_name".pub

# Вывод команды для клонирования репозитория
echo "Команда для клонирования репозитория:"
echo "git clone git@$repo_name:AmayaKids/$repo_name.git"
