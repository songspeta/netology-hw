#!/bin/bash

# Проверяем доступность порта 80
if ! nc -z 127.0.0.1 80; then
    exit 1
fi

# Проверяем наличие index.html
if [ ! -f /var/www/html/index.html ]; then
    exit 1
fi

exit 0