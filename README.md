# Deque (on Tarantool)

Проект состоит из 2х частей:

- tarantool/deque -- с кодом тарантульного приложения deque (да, такова структура чтобы с пакаджингом не было проблем)
- deque/ -- с частью питоновских биндингов к АПИ.

## Preinstall

Чтобы запустить локальное окружение на Linux: нужно:

1) Поставить тарантул из [Tarantool Download](https://www.tarantool.io/en/download/os-installation/ubuntu/)
2) Вызвать `apt install tarantool tarantool-dev tt` (Версия тарантула 3.2.1, версия tt 2.5.2)

Для macos `brew install tt` и `brew install tarantool`

3) Установить зависимости к приложению: `cd tarantool/deque && tt build`.

## Build

Собирать лучше на тачке с Убунту (хотя 18.04 и выше).
На тачку поставить тарантул и tt [Tarantool Download](https://www.tarantool.io/en/download/os-installation/ubuntu/). Вызвать `apt install tarantool tarantool-dev tt` (Версия тарантула 3.2.1, версия tt 2.5.2)

Поставить зависимости `cd tarantool/deque && tt build` и запустить сборку `make pack`. На выходе работы, создастся `deque_0.1.0.0-1_x86_64.deb`. Его можно инсталлировать на целевые сервера.

## Install (on-prod)

```bash
$ apt install ./deque_0.1.0.0-1_x86_64.deb
...
```

Само приложение инсталлируется в `/usr/share/tarantool/deque` где `/usr/share/tarantool/deque/bin/tarantool` является бинарем тарантула, которым будет запускаться само приложение. в `/usr/lib/systemd/system/deque@.service` кладется системд-юнит файл, для приложения.

Общая конфигурация приложения в `/etc/tarantool/deque/`

```bash
root@private:~# ls -la /etc/tarantool/deque/
drwxr-xr-x 2 tarantool tarantool 4096 Nov 10 14:47 .
drwxr-xr-x 4 root      root      4096 Nov 10 14:47 ..
-rw-r--r-- 1 root      root       530 Nov 10 14:47 config.yml
-rw-r--r-- 1 root      root        11 Nov 10 14:47 instances.yml
-rw-r--r-- 1 root      root       505 Nov 10 14:47 tt.yaml
```

Здесь 3 файла конфигурации (все важны):

- config.yml - Конфигурация всего кластера, в котором задаются адреса, роли, гранты, и требуемые ресурсы.
  Общая документация находится здесь: [Configuration Reference](https://www.tarantool.io/en/doc/latest/reference/configuration/configuration_reference/#configuration-reference). Файл config.yaml НА ВСЕХ серверах **должен быть идентичным**.

- instances.yml - Простой yml файл, в котором перечислены имена инстансов, которые будут запущены на этом сервере. На мастер-сервере оставляем строчку с `deque_001`, на реплика-сервере строчку с `deque_002`.

- tt.yaml - Конфигурация утилиты tt, для обслуживания этого приложения. Для его использования пишем: `tt -c /etc/tarantool/deque/tt.yaml status` и тп, чтобы работать с приложением `deque` на сервере.

Для `production` рекомендую привести config.yml к следующему состоянию:

```yaml
# yaml-language-server: $schema=https://gist.githubusercontent.com/ochaton/24957db1617df119b30b5e7cec05e3cf/raw/cf498e23928eefad2cf31748a369a8fa124166f2/config.schema-3.3.0.json
credentials:
  users:
    python:
      password: python
      privileges:
        - universe: true
          permissions: ["read", "write", "execute"]
    replica:
      password: replica
      roles:
        - replication

app:
  module: 'storage'

replication:
  failover: manual
  bootstrap_strategy: config

iproto:
  advertise:
    peer:
      login: replica

groups:
  storages:
    replicasets:
      deque001:
        bootstrap_leader: deque_001
        leader: deque_001
        instances:
          deque_001:
            iproto:
              listen:
              - uri: '<master-public-addr>:3301'
          deque_002:
            iproto:
              listen:
              - uri: '<replica-public-addr>:3302'
```

ВСЕ `password` даны для примера, можно задать их самостоятельно.

Сначала устанавливаем и редактируем конфиг на сервере с мастером, и запускаем приложение:

```bash
systemctl start deque@deque_001
```

Затем повторяем процесс на реплика-сервере

Сначала устанавливаем и редактируем конфиг на сервере с мастером, и запускаем приложение:

```bash
systemctl start deque@deque_002
```

Команда ниже поможет отслеживать состояние запуска кластера.

```bash
cd /etc/tarantool/deque;
tt status
```
