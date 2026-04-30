# Домашнее задание к занятию  «Инструменты Git» - Спетницкий Д.И.


## Задание

В клонированном репозитории:

1. Найдите полный хеш и комментарий коммита, хеш которого начинается на `aefea`.
2. Ответьте на вопросы.

* Какому тегу соответствует коммит `85024d3`?
* Сколько родителей у коммита `b8d720`? Напишите их хеши.
* Перечислите хеши и комментарии всех коммитов, которые были сделаны между тегами  v0.12.23 и v0.12.24.
* Найдите коммит, в котором была создана функция `func providerSource`, её определение в коде выглядит так: `func providerSource(...)` (вместо троеточия перечислены аргументы).
* Найдите все коммиты, в которых была изменена функция `globalPluginDirs`.
* Кто автор функции `synchronizedWriters`? 

*В качестве решения ответьте на вопросы и опишите, как были получены эти ответы.*

---

## Решение

Полный хеш и комментарий
```
git show aefea --no-patch --format="%H%n%s"

Полный хеш: aefead2207ef7e2aa5dc81a34aedf0cad4c32545
Комментарий: Update CHANGELOG.md
```

Тег 

```
git describe --exact-match 85024d3

v0.12.23
```
Ишем Родителя
```
git show -s --format="%P" b8d720

56cd7859e05c36c06b56d013b55a252d0bb7e158 9ea88f22fc6269854151c571162c5bcf958bee2b

2 родителя получается
```

Ищем хеши в диапазоне 

```
git log v0.12.23..v0.12.24 --oneline

33ff1c03bb (tag: v0.12.24) v0.12.24
b14b74c493 [Website] vmc provider links
3f235065b9 Update CHANGELOG.md
6ae64e247b registry: Fix panic when server is unreachable
5c619ca1ba website: Remove links to the getting started guide's old location
06275647e2 Update CHANGELOG.md
d5f9411f51 command: Fix bug when using terraform login on Windows
4b6d06cc5d Update CHANGELOG.md
dd01a35078 Update CHANGELOG.md
225466bc3e Cleanup after v0.12.23 release
```

Ищем коммит где создана функция

```
git log -S "func providerSource" --oneline --all --reverse | head -1

8c928e8358 main: Consult local directories as potential mirrors of providers
```

Ищем все изменения функции

```
git log -S "globalPluginDirs" --oneline --all

7c4aeac5f3 stacks: load credentials from config file on startup (#35952)
de49677ecd Run tf exec e2e tests
65c4ba7363 Remove terraform binary
aa3a155106 Remove accidentally-committed binary
e8a9debd2b Remove accidentally-committed binary
125eb51dc4 Remove accidentally-committed binary
e8eec68de3 backport of commit 1ee5d23894a0c9448d6787e0385dbba356db8096 (#30989)
b872613d25 Backport of Bump compatibility version to 1.3.0 for terraform core release into v1.2 (#30990)
22c121df86 Bump compatibility version to 1.3.0 for terraform core release (#30988)
fcdb5d2e55 (origin/f-plugin-finder) WIP centralized plugin finder
7c7e5d8f0a Don't show data while input if sensitive
35a058fb3d main: configure credentials from the CLI config file
c0b1761096 prevent log output during init
8364383c35 Push plugin discovery down into command package
```

Ищем автора
```
git log -S "synchronizedWriters" --format="%an <%ae>" --all --reverse | head -1

Martin Atkins <mart@degeneration.co.uk>
```

