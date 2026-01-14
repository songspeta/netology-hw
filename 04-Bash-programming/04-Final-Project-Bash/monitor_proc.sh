#!/bin/bash

# Проверка аргумента
if [ -z "$1" ]; then
    echo "Использование: $0 <группа>"
    echo "Доступные группы: main, resources, files, system"
    exit 1
fi

GROUP="$1"
LOG_FILE="/tmp/proc_monitor_${GROUP}.log"
PREVIOUS_PIDS_FILE="/tmp/proc_previous_pids_${GROUP}.txt"
CURRENT_PIDS_FILE="/tmp/proc_current_pids_${GROUP}.txt"
TEMP_LOG="/tmp/proc_monitor_${GROUP}_temp.log"

# Получаем текущее время
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Очищаем текущий список PID
> "$CURRENT_PIDS_FILE"

# Собираем текущие PID
for item in /proc/*; do
    basename_item=$(basename "$item")
    if [[ "$basename_item" =~ ^[0-9]+$ ]]; then
        echo "$basename_item" >> "$CURRENT_PIDS_FILE"
    fi
done

# Определяем новые PID
if [ -f "$PREVIOUS_PIDS_FILE" ]; then
    # Находим новые PID (есть в текущем, но нет в предыдущем)
    NEW_PIDS=$(comm -13 <(sort "$PREVIOUS_PIDS_FILE") <(sort "$CURRENT_PIDS_FILE"))
else
    # Если предыдущего файла нет - все процессы новые
    NEW_PIDS=$(cat "$CURRENT_PIDS_FILE")
fi

# Сохраняем текущие PID как предыдущие для следующего запуска
cp "$CURRENT_PIDS_FILE" "$PREVIOUS_PIDS_FILE"

# Создаем новый блок во временном файле
{
    echo "=== ЗАПУСК ==="
    echo "Время выполнения: $TIMESTAMP"
    echo "Новые процессы: $(echo "$NEW_PIDS" | wc -l)"
    echo ""

    # Выводим заголовок таблицы
    case "$GROUP" in
        main)
            printf "%-8s %-15s %-30s %-25s %-30s %-50s\n" "PID" "Name" "Command Line" "Status" "CWD" "Environment"
            ;;
        resources)
            printf "%-8s %-15s %-30s %-30s %-30s %-20s\n" "PID" "Name" "Status" "Limits" "Mounts" "FD Count"
            ;;
        files)
            printf "%-8s %-15s %-30s %-30s %-30s %-30s\n" "PID" "Name" "Command Line" "Environment" "Root" "FD Info"
            ;;
        system)
            printf "%-8s %-15s %-25s %-30s %-30s %-30s\n" "PID" "Name" "Process Name" "Working Dir" "Root Dir" "Open FDs"
            ;;
        *)
            echo "Ошибка: неизвестная группа '$GROUP'"
            exit 1
            ;;
    esac

    # Выводим только новые процессы
    if [ -n "$NEW_PIDS" ]; then
        for PID in $NEW_PIDS; do
            if [ -d "/proc/$PID" ]; then
                # Функция для обработки одного процесса
                COMM=$(cat "/proc/$PID/comm" 2>/dev/null || echo "N/A")
                case "$GROUP" in
                    main)
                        CMDLINE=$(cat "/proc/$PID/cmdline" 2>/dev/null | tr '\0' ' ' | cut -c1-30 || echo "N/A")
                        STATUS=$(grep -E '^(State|Uid|VmRSS)' "/proc/$PID/status" 2>/dev/null | tr '\n' ';' | cut -c1-25 || echo "N/A")
                        CWD=$(readlink "/proc/$PID/cwd" 2>/dev/null | cut -c1-30 || echo "N/A")
                        ENVIRON=$(cat "/proc/$PID/environ" 2>/dev/null | tr '\0' ' ' | cut -c1-50 || echo "N/A")
                        printf "%-8s %-15s %-30s %-25s %-30s %-50s\n" "$PID" "$COMM" "$CMDLINE" "$STATUS" "$CWD" "$ENVIRON"
                        ;;
                    resources)
                        STATUS=$(grep -E '^(Threads|VmSize|VmRSS)' "/proc/$PID/status" 2>/dev/null | tr '\n' ';' | cut -c1-30 || echo "N/A")
                        LIMITS=$(grep 'Max open files\|Max processes' "/proc/$PID/limits" 2>/dev/null | tr '\n' ';' | cut -c1-30 || echo "N/A")
                        MOUNTS=$(head -n 1 "/proc/$PID/mounts" 2>/dev/null | cut -c1-30 || echo "N/A")
                        FD_COUNT=$(ls "/proc/$PID/fd" 2>/dev/null | wc -l 2>/dev/null || echo "N/A")
                        printf "%-8s %-15s %-30s %-30s %-30s %-20s\n" "$PID" "$COMM" "$STATUS" "$LIMITS" "$MOUNTS" "$FD_COUNT"
                        ;;
                    files)
                        CMDLINE=$(cat "/proc/$PID/cmdline" 2>/dev/null | tr '\0' ' ' | cut -c1-30 || echo "N/A")
                        ENVIRON=$(cat "/proc/$PID/environ" 2>/dev/null | tr '\0' ' ' | cut -c1-30 || echo "N/A")
                        ROOT=$(readlink "/proc/$PID/root" 2>/dev/null | cut -c1-30 || echo "N/A")
                        FDINFO=$(head -n 1 "/proc/$PID/fdinfo"/* 2>/dev/null 2>/dev/null | cut -c1-30 || echo "N/A")
                        printf "%-8s %-15s %-30s %-30s %-30s %-30s\n" "$PID" "$COMM" "$CMDLINE" "$ENVIRON" "$ROOT" "$FDINFO"
                        ;;
                    system)
                        NAME=$(grep 'Name' "/proc/$PID/status" 2>/dev/null | cut -d: -f2 | xargs || echo "N/A")
                        CWD=$(readlink "/proc/$PID/cwd" 2>/dev/null | cut -c1-30 || echo "N/A")
                        ROOT=$(readlink "/proc/$PID/root" 2>/dev/null | cut -c1-30 || echo "N/A")
                        FD_LIST=$(ls "/proc/$PID/fd" 2>/dev/null | head -n 3 | tr '\n' ' ' | cut -c1-30 || echo "N/A")
                        printf "%-8s %-15s %-25s %-30s %-30s %-30s\n" "$PID" "$COMM" "$NAME" "$CWD" "$ROOT" "$FD_LIST"
                        ;;
                esac
            fi
        done
    else
        echo "Нет новых процессов"
    fi

    echo ""

    # Добавляем старое содержимое лога (если есть)
    if [ -f "$LOG_FILE" ]; then
        cat "$LOG_FILE"
    fi
} > "$TEMP_LOG"

# Перемещаем временный файл на место оригинала
mv "$TEMP_LOG" "$LOG_FILE"

echo "Новые процессы добавлены в начало $LOG_FILE"
