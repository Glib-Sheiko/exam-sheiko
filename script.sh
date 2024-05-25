#!/bin/bash

# 5.1 Клонируем ветку main с репозитория
git clone --branch main https://gitlab.com/staskuznetsov/site.git site-main

# 5.2 Разворачиваем сайт на сервере nginx на виртуальной машине prod1 с помощью ansible
# Создадим временный плейбук ansible для prod1
cat <<EOL > deploy_main.yml
- name: Configure WebServers
  hosts: prod1
  become: True
  tasks:
    - name: Install Nginx
      apt:
        name: nginx
        state: present
    - name: Copy config file Nginx
      copy:
        src: ./nginx.conf
        dest: /etc/nginx/nginx.conf
    - name: Copy site index.html
      copy:
        src: site-main/index.html
        dest: /var/www/html/index.html
    - name: Restart Nginx
      service:
        name: nginx
        state: restarted
EOL

# Выполняем плейбук для prod1
ansible-playbook deploy_main.yml

# 5.3 Клонируем ветку dev с репозитория
git clone --branch dev https://gitlab.com/staskuznetsov/site.git site-dev

# 5.4 Разворачиваем сайт на сервере nginx на виртуальной машине prod2 с помощью ansible
# Создадим временный плейбук ansible для prod2
cat <<EOL > deploy_dev.yml
- name: Configure WebServers
  hosts: prod2
  become: True
  tasks:
    - name: Install Nginx
      apt:
        name: nginx
        state: present
    - name: Copy config file Nginx
      copy:
        src: ./nginx.conf
        dest: /etc/nginx/nginx.conf
    - name: Copy site index.html
      copy:
        src: site-dev/index.html
        dest: /var/www/html/index.html
    - name: Restart Nginx
      service:
        name: nginx
        state: restarted
EOL

# Выполняем плейбук для prod2
ansible-playbook deploy_dev.yml

# Очистка временных файлов и клонированных репозиториев
rm deploy_main.yml deploy_dev.yml
rm -rf site-main site-dev

