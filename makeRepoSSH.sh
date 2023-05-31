#!/bin/bash

# Запросить имя репозитория
echo "Введите имя репозитория (например, MyService):"
read repo_name

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
