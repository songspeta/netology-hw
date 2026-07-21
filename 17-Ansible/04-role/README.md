
# Домашнее задание к занятию «Работа с roles» - Спетницкий Д.И.

### Главный Playbook (site.yml)


Основной файл оркестрации, который разворачивает полный стек мониторинга на целевых серверах в правильной последовательности.

### Архитектура развертывания


```

  1. ClickHouse (База данных)
     ↓ передаёт: ch_host_ip, ch_http_port
  2. Vector (Сборщик логов)
     ↓ передаёт: ch_host_ip, ch_http_port
  3. Lighthouse (Веб-интерфейс)
```

###  Передача переменных между ролями

| Роль | Получаемые переменные | Значение | Назначение |
|------|----------------------|----------|------------|
| **ClickHouse** | `clickhouse_listen_host` | `0.0.0.0` | Слушать все интерфейсы |
| | `clickhouse_http_port` | `8123` | HTTP-порт для API |
| | `clickhouse_tcp_port` | `9000` | TCP-порт для клиентов |
| **Vector** | `vector_sink_host` | `{{ ch_host_ip }}` | Куда отправлять логи |
| | `vector_sink_port` | `{{ ch_http_port }}` | Порт ClickHouse |
| **Lighthouse** | `lighthouse_ch_host` | `{{ ch_host_ip }}` | Хост БД для подключения |
| | `lighthouse_ch_port` | `{{ ch_http_port }}` | Порт БД для подключения |

### Ключевые особенности

✅ **Последовательное выполнение** — сначала поднимается БД, затем сборщик, потом UI

✅ **Связность компонентов** — переменные передаются централизованно через `vars`

✅ **Гибкость** — достаточно изменить `ch_host_ip` в одном месте, и все роли подхватят новый адрес

✅ **Теги** — можно запускать отдельные компоненты:

   ```bash
   ansible-playbook site.yml --tags 'db'        # Только ClickHouse
   ansible-playbook site.yml --tags 'collector' # Только Vector
   ansible-playbook site.yml --tags 'ui'        # Только Lighthouse
   ```

### Пример использования

```bash
# Развернуть весь стек
ansible-playbook -i inventory site.yml

# Развернуть только БД и сборщик
ansible-playbook -i inventory site.yml --tags 'db,collector'

# Проверка синтаксиса
ansible-playbook -i inventory site.yml --check
```

