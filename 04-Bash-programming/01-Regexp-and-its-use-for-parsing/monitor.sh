#!/bin/bash

# Устанавливаем английскую локаль (стоит русская локаль из-за этого free выводит заголовки на русском)
export LANG=C
export LC_ALL=C

LOG_FILE="system_monitor.log"
TOTAL_RECORDS=120  # 10 минут * 12 записей в минуту (каждые 5 секунд)

# Создаем заголовок файла с выравниванием
printf "%-20s %-10s %-10s %-10s %-15s %-15s %-15s %-15s\n" \
       "timestamp" "loadavg1" "loadavg5" "loadavg15" "memfree" "memtotal" "diskfree" "disktotal" > $LOG_FILE

echo "Начинаем сбор данных... Всего будет собрано $TOTAL_RECORDS записей (10 минут)"
echo "Нажмите Ctrl+C для остановки досрочно"
echo ""

# Собираем данные в течение 10 минут
for i in $(seq 1 $TOTAL_RECORDS); do
    # Получаем timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    
    # Получаем loadavg
    read loadavg1 loadavg5 loadavg15 rest < /proc/loadavg
    
    # Получаем информацию о памяти (в байтах)
    mem_info=$(free -b | grep Mem)
    memtotal=$(echo $mem_info | awk '{print $2}')  # total
    memfree=$(echo $mem_info | awk '{print $4}')   # free
    
    # Получаем информацию о диске (в байтах) — правильно парсим 1K-blocks
    df_line=$(df -P / | tail -1)
    disktotal_kb=$(echo $df_line | awk '{print $2}')  # 1K-blocks
    diskfree_kb=$(echo $df_line | awk '{print $4}')   # 1K-blocks
    
    # Переводим в байты (умножаем на 1024)
    disktotal=$((disktotal_kb * 1024))
    diskfree=$((diskfree_kb * 1024))
    
    # Записываем данные в лог с форматированием
    printf "%-20s %-10s %-10s %-10s %-15d %-15d %-15d %-15d\n" \
           "$timestamp" "$loadavg1" "$loadavg5" "$loadavg15" "$memfree" "$memtotal" "$diskfree" "$disktotal" >> $LOG_FILE
    
    # Показываем прогресс
    progress=$((i * 100 / TOTAL_RECORDS))
    bar_length=50
    filled_length=$((i * bar_length / TOTAL_RECORDS))
    empty_length=$((bar_length - filled_length))
    
    bar=""
    for ((j=0; j<filled_length; j++)); do
        bar="$bar█"
    done
    for ((j=0; j<empty_length; j++)); do
        bar="$bar░"
    done
    
    elapsed_seconds=$((i * 5))
    remaining_seconds=$(((TOTAL_RECORDS - i) * 5))
    
    elapsed_min=$((elapsed_seconds / 60))
    elapsed_sec=$((elapsed_seconds % 60))
    remaining_min=$((remaining_seconds / 60))
    remaining_sec=$((remaining_seconds % 60))
    
    printf "\r\033[K[%s] %d%% (%d/%d) | Прошло: %02d:%02d | Осталось: %02d:%02d" \
           "$bar" "$progress" "$i" "$TOTAL_RECORDS" \
           "$elapsed_min" "$elapsed_sec" "$remaining_min" "$remaining_sec"
    
    if [ $i -lt $TOTAL_RECORDS ]; then
        sleep 5
    fi
done

echo ""
echo "Сбор данных завершен! Данные сохранены в $LOG_FILE"
