#!/bin/bash

LOG_FILE="$1"

# Проверка наличия файла
if [ ! -f "$LOG_FILE" ]; then
    echo "Ошибка: Файл лога '$LOG_FILE' не найден" >&2
    exit 1
fi

# Анализ лога с помощью awk
awk '
function to_epoch(datetime,    parts, year, month, day, hour, min, sec) {
    split(datetime, parts, /[- :]/)
    year = parts[1]
    month = parts[2]
    day = parts[3]
    hour = parts[4]
    min = parts[5]
    sec = parts[6]
    return mktime(year " " month " " day " " hour " " min " " sec)
}

BEGIN {
    # Пороговые значения в секундах
    load_threshold = 120   # 2 минуты
    mem_threshold = 180    # 3 минуты
    disk_threshold = 300   # 5 минут

    # Флаги нарушения условий
    load_violation = 0
    mem_violation = 0
    disk_violation = 0
    
    # Максимальная временная метка (последняя запись)
    max_timestamp = 0
}

NR == 1 { next }  # Пропускаем заголовок

{
    # Парсим временную метку
    datetime = $1 " " $2
    timestamp = to_epoch(datetime)
    
    # Обновляем максимальную временную метку
    if (timestamp > max_timestamp) max_timestamp = timestamp
    
    # Сохраняем строку для последующего анализа
    lines[NR] = $0
    timestamps[NR] = timestamp
}

END {
    # Если нет валидных записей - выходим
    if (max_timestamp == 0) exit
    
    # Анализируем записи относительно максимальной временной метки
    for (i in lines) {
        $0 = lines[i]
        timestamp = timestamps[i]
        time_diff = max_timestamp - timestamp
        
        # Проверяем только записи в требуемых временных окнах
        if (time_diff <= load_threshold && $3 >= 1.0) {
            load_violation = 1
        }
        
        if (time_diff <= mem_threshold && $7 > 0) {
            ratio = $6 / $7
            if (ratio >= 0.6) mem_violation = 1
        }
        
        if (time_diff <= disk_threshold && $9 > 0) {
            ratio = $8 / $9
            if (ratio >= 0.6) disk_violation = 1
        }
    }
    
    # Выводим результаты проверки
    if (load_violation) print "Нарушение: loadavg1 >= 1 за последние 2 минуты"
    if (mem_violation) print "Нарушение: Свободная память >= 60% за последние 3 минуты"
    if (disk_violation) print "Нарушение: Свободное место на диске >= 60% за последние 5 минут"
    
    # Возвращаем код: 0 если все условия выполнены, иначе 1
    exit (load_violation || mem_violation || disk_violation)
}' "$LOG_FILE"

# Сохраняем код возврата awk
exit_code=$?

# Дополнительный вывод, если все условия выполнены
if [ $exit_code -eq 0 ]; then
    echo "Все условия выполнены"
else
    echo "Одно или несколько условий не выполнены"
fi

exit $exit_code
