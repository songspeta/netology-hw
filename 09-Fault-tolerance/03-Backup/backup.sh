#!/bin/bash

# Путь к источнику и назначению
SOURCE="$HOME/"
DEST="/tmp/backup/"

# Логирование
LOGFILE="$HOME/backup.log"

rsync -a --delete --exclude='.*' --checksum "$SOURCE" "$DEST" >/dev/null 2>&1

# Проверка кода возврата
if [ $? -eq 0 ]; then
    echo "$(date): Резервное копирование успешно завершено." >> "$LOGFILE"
else
    echo "$(date): ОШИБКА при выполнении резервного копирования!" >> "$LOGFILE"
fi