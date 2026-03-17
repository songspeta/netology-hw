# Домашнее задание к занятию  «Защита сети» - Спетницкий Д.И.




## Задание 1


Проведите разведку системы и определите, какие сетевые службы запущены на защищаемой системе:

**sudo nmap -sA < ip-адрес >**

**sudo nmap -sT < ip-адрес >**

**sudo nmap -sS < ip-адрес >**

**sudo nmap -sV < ip-адрес >**

По желанию можете поэкспериментировать с опциями:  [https://nmap.org/man/ru/man-briefoptions.html](https://nmap.org/man/ru/man-briefoptions.html).

_В качестве ответа пришлите события, которые попали в логи Suricata и Fail2Ban, прокомментируйте результат._



---


## Решение 1

### 1. Параметры стенда
| Компонент | Значение |
|-----------|----------|
| Защищаемая система | Ubuntu VM, IP: 192.168.233.129 |
| Атакующая система | Kali Linux, IP: 192.168.233.136 |
| Сетевой режим | VMware, одна подсеть |
| IDS | Suricata 7.0.10 |
| IPS | Fail2Ban |
| Сканер | Nmap |

### 2. Выполненные сканы
| Команда | Тип сканирования | Цель |
|---------|-----------------|------|
| `sudo nmap -sA 192.168.233.129` | ACK scan | Определение правил фаервола |
| `sudo nmap -sT 192.168.233.129` | TCP Connect | Полное TCP-соединение |
| `sudo nmap -sS 192.168.233.129` | SYN stealth | Скрытное сканирование |
| `sudo nmap -sV 192.168.233.129` | Version detection | Определение версий сервисов |

### 3. События в Suricata (fast.log)
spet@ubuntu-vm:~$ sudo cat /var/log/suricata/fast.log
```
03/17/2026-15:29:23.590308  [**] [1:2010937:3] ET SCAN Suspicious inbound to mySQL port 3306 [**] [Classification: Potentially Bad Traffic] [Priority: 2] {TCP} 192.168.233.136:32832 -> 192.168.233.129:3306
03/17/2026-15:29:23.607107  [**] [1:2010939:3] ET SCAN Suspicious inbound to PostgreSQL port 5432 [**] [Classification: Potentially Bad Traffic] [Priority: 2] {TCP} 192.168.233.136:53432 -> 192.168.233.129:5432
03/17/2026-15:29:23.608272  [**] [1:2010935:3] ET SCAN Suspicious inbound to MSSQL port 1433 [**] [Classification: Potentially Bad Traffic] [Priority: 2] {TCP} 192.168.233.136:49096 -> 192.168.233.129:1433
03/17/2026-15:29:23.619772  [**] [1:2002910:6] ET SCAN Potential VNC Scan 5800-5820 [**] [Classification: Attempted Information Leak] [Priority: 2] {TCP} 192.168.233.136:51482 -> 192.168.233.129:5815
03/17/2026-15:29:23.623541  [**] [1:2010936:3] ET SCAN Suspicious inbound to Oracle SQL port 1521 [**] [Classification: Potentially Bad Traffic] [Priority: 2] {TCP} 192.168.233.136:51144 -> 192.168.233.129:1521
03/17/2026-15:29:46.845463  [**] [1:2010937:3] ET SCAN Suspicious inbound to mySQL port 3306 [**] [Classification: Potentially Bad Traffic] [Priority: 2] {TCP} 192.168.233.136:49905 -> 192.168.233.129:3306
03/17/2026-15:29:46.852514  [**] [1:2010936:3] ET SCAN Suspicious inbound to Oracle SQL port 1521 [**] [Classification: Potentially Bad Traffic] [Priority: 2] {TCP} 192.168.233.136:49905 -> 192.168.233.129:1521
03/17/2026-15:29:46.853163  [**] [1:2010935:3] ET SCAN Suspicious inbound to MSSQL port 1433 [**] [Classification: Potentially Bad Traffic] [Priority: 2] {TCP} 192.168.233.136:49905 -> 192.168.233.129:1433
03/17/2026-15:29:46.875992  [**] [1:2010939:3] ET SCAN Suspicious inbound to PostgreSQL port 5432 [**] [Classification: Potentially Bad Traffic] [Priority: 2] {TCP} 192.168.233.136:49905 -> 192.168.233.129:5432
03/17/2026-15:29:54.688222  [**] [1:2010937:3] ET SCAN Suspicious inbound to mySQL port 3306 [**] [Classification: Potentially Bad Traffic] [Priority: 2] {TCP} 192.168.233.136:42941 -> 192.168.233.129:3306
03/17/2026-15:29:54.693199  [**] [1:2010936:3] ET SCAN Suspicious inbound to Oracle SQL port 1521 [**] [Classification: Potentially Bad Traffic] [Priority: 2] {TCP} 192.168.233.136:42941 -> 192.168.233.129:1521
03/17/2026-15:29:54.696716  [**] [1:2010939:3] ET SCAN Suspicious inbound to PostgreSQL port 5432 [**] [Classification: Potentially Bad Traffic] [Priority: 2] {TCP} 192.168.233.136:42941 -> 192.168.233.129:5432
03/17/2026-15:29:54.705263  [**] [1:2010935:3] ET SCAN Suspicious inbound to MSSQL port 1433 [**] [Classification: Potentially Bad Traffic] [Priority: 2] {TCP} 192.168.233.136:42941 -> 192.168.233.129:1433
```

**Детектировано атак:** 5+ событий сканирования портов СУБД и сервисов

### 4. Статус Fail2Ban
```
spet@ubuntu-vm:~$ sudo fail2ban-client status
Status
|- Number of jail:	1
`- Jail list:	sshd
spet@ubuntu-vm:~$ sudo fail2ban-client status sshd
Status for the jail: sshd
|- Filter
|  |- Currently failed:	0
|  |- Total failed:	0
|  `- Journal matches:	_SYSTEMD_UNIT=ssh.service + _COMM=sshd
`- Actions
   |- Currently banned:	0
   |- Total banned:	0
   `- Banned IP list:	
spet@ubuntu-vm:~$ sudo grep "Ban\|Unban" /var/log/fail2ban.log | tail -10
```


### 5. Комментарий к результатам

#### Suricata:
✅ **Сработала корректно** — зафиксировала все попытки сканирования портов.  
✅ **Логирование настроено** — события записываются в `/var/log/suricata/fast.log`.

#### Fail2Ban:
✅ **Сервис активен** — джейл `sshd` включён и готов к работе.  
⚠️ **Блокировок нет** — это ожидаемое поведение, так как:
   - Проводилось только сканирование портов (nmap)
   - Не было попыток аутентификации (brute-force SSH)
   - Fail2Ban по умолчанию мониторит `/var/log/auth.log`, а не логи Suricata


### 6. Вывод
Система защиты успешно детектирует разведывательную активность. Suricata фиксирует сканирование портов, Fail2Ban готов к блокировке при попытках несанкционированного доступа. 

--- 

## Задание 2
Проведите атаку на подбор пароля для службы SSH:

**hydra -L users.txt -P pass.txt < ip-адрес > ssh**

1. Настройка **hydra**: 
 
 - создайте два файла: **users.txt** и **pass.txt**;
 - в каждой строчке первого файла должны быть имена пользователей, второго — пароли. В нашем случае это могут быть случайные строки, но ради эксперимента можете добавить имя и пароль существующего пользователя.

Дополнительная информация по **hydra**: https://kali.tools/?p=1847.

2. Включение защиты SSH для Fail2Ban:

-  открыть файл /etc/fail2ban/jail.conf,
-  найти секцию **ssh**,
-  установить **enabled**  в **true**.

Дополнительная информация по **Fail2Ban**:https://putty.org.ru/articles/fail2ban-ssh.html.

---

## Решение 2


| Компонент | Значение |
|-----------|----------|
| Защищаемая система | Ubuntu VM, IP: 192.168.233.129 |
| Атакующая система | Kali Linux, IP: 192.168.233.136 |
| Сетевой режим | VMware, одна подсеть |
| IDS | Suricata 7.0.10 |
| IPS | Fail2Ban |
| Brute-force инструмент | Hydra |


####  Параметры атаки
```
hydra -L users.txt -P pass.txt -v 192.168.233.129 ssh -t 2 -W 1
```

#### Реакция защиты (лог Fail2Ban):
```
2026-03-17 15:59:55,668 fail2ban.jail           [46643]: INFO    Jail 'sshd' started
2026-03-17 16:01:12,087 fail2ban.filter         [46643]: INFO    [sshd] Found 192.168.233.136 - 2026-03-17 16:01:11
2026-03-17 16:01:12,088 fail2ban.filter         [46643]: INFO    [sshd] Found 192.168.233.136 - 2026-03-17 16:01:11
2026-03-17 16:01:16,078 fail2ban.filter         [46643]: INFO    [sshd] Found 192.168.233.136 - 2026-03-17 16:01:15
2026-03-17 16:01:16,079 fail2ban.filter         [46643]: INFO    [sshd] Found 192.168.233.136 - 2026-03-17 16:01:15
2026-03-17 16:01:16,352 fail2ban.actions        [46643]: NOTICE  [sshd] Ban 192.168.233.136  
```
#### Статус джейла после атаки:

```
$ sudo fail2ban-client status sshd

Status for the jail: sshd
|- Filter
|  |- Currently failed: 0
|  |- Total failed: 4
|  `- Journal matches: _SYSTEMD_UNIT=ssh.service + _COMM=sshd
`- Actions
   |- Currently banned: 1
   |- Total banned: 1
   `- Banned IP list: 192.168.233.136
```

**Fail2Ban** эффективно защищает SSH от brute-force атак: после 4 неудачных попыток атакующий IP автоматически блокируется

---

