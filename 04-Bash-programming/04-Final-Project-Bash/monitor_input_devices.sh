#!/bin/bash

# Файлы для хранения данных
TEMP_FILE="/tmp/current_devices.txt"
PREV_FILE="/tmp/previous_devices.txt"
LOG_FILE="/tmp/input_devices_monitor.log"
TEMP_LOG="/tmp/input_devices_monitor_temp.log"

# Получаем текущее время
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Функция для извлечения устройств
extract_devices() {
    local output_file=$1
    > "$output_file" # очищаем файл

    # Читаем блоки устройств
    while IFS= read -r line; do
        if [[ $line == N:* ]]; then
            # Извлекаем имя устройства
            name=$(echo "$line" | sed -n 's/N: Name="\([^"]*\)"/\1/p')
        elif [[ $line == H:* ]]; then
            # Извлекаем handlers
            handlers=$(echo "$line" | sed -n 's/H: Handlers=\(.*\)/\1/p')
            # Записываем в файл (имя|handlers)
            echo "$name|$handlers" >> "$output_file"
        fi
    done < /proc/bus/input/devices
}

# Извлекаем текущие устройства
extract_devices "$TEMP_FILE"

# Находим новые устройства
NEW_DEVICES=""
if [ -f "$PREV_FILE" ]; then
    # Сравниваем текущие и предыдущие устройства
    NEW_DEVICES=$(comm -13 <(sort "$PREV_FILE") <(sort "$TEMP_FILE") | sed '/^$/d')
else
    # Если предыдущего файла нет - все устройства новые
    NEW_DEVICES=$(cat "$TEMP_FILE")
fi

# Убираем лишние пробелы и пустые строки
NEW_DEVICES=$(echo "$NEW_DEVICES" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | grep -v '^$')

# Сохраняем текущие устройства как предыдущие для следующего запуска
cp "$TEMP_FILE" "$PREV_FILE"

# Создаем временный файл с новым блоком
{
    echo "=== Мониторинг устройств ввода ==="
    echo "Время выполнения: $TIMESTAMP"

    if [ -n "$NEW_DEVICES" ]; then
        echo "Новые устройства: $(echo "$NEW_DEVICES" | wc -l)"

        printf "%-40s %s\n" "Имя устройства" "Обработчики"
        echo "---------------------------------------- -------------------"
        echo "$NEW_DEVICES" | while IFS='|' read -r name handlers; do
            printf "%-40s %s\n" "$name" "$handlers"
        done
    else
        echo "Новые устройства: 0"
        echo "Нет новых устройств"
    fi

    echo ""
} > "$TEMP_LOG"

# Добавляем старый лог в конец временного файла
if [ -f "$LOG_FILE" ]; then
    cat "$LOG_FILE" >> "$TEMP_LOG"
fi

# Перемещаем временный файл на место оригинала
mv "$TEMP_LOG" "$LOG_FILE"

echo "Мониторинг завершен. Новые устройства записаны в $LOG_FILE"
