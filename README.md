[![build-and-push](https://github.com/maxirmx/trustvpn-container/actions/workflows/build-and-push.yml/badge.svg)](https://github.com/maxirmx/trustvpn-container/actions/workflows/build-and-push.yml)
[![lint](https://github.com/maxirmx/trustvpn-container/actions/workflows/lint.yml/badge.svg)](https://github.com/maxirmx/trustvpn-container/actions/workflows/lint.yml)

# O!Service
Контейнер OpenVPN Docker для проекта O!Service.
Данный проект - небольшая обертка для ```kylemanna/openvpn```, не более.

## Конфигурация и инициализация

Профили пользователей определяются файлами в папке ```app/profiles```. Имена файлов должны соответствовать именам профилей, используемых openvpn-backend. При необходимости изменения или добавления профиля, может быть необходимо реализовать дополнительную маркировку профиля и ограничение пропускной способности как указано ниже в разделе traffic shaping.

Название профиля ```blocked``` зарезервировано для блокировки пользователей. Профиль с таким именем создавать нельзя. Это не проверяется, но сломает логику блокировки

Контейнер должен быть инициализирован следующей командой:
```
docker run -rm -v <Path to OpenVPN configuration folder>:/etc/openvpn trustvpn-container bash -c "trustvpn-container-config -u <host name>"
```

## API

Все вызовы API на самом деле являются bash-скриптами, которые выполняются внутри контейнера после его инициализации
```
docker run -rm -v <Path to OpenVPN configuration folder>:/etc/openvpn trustvpn-container bash -c "<API call with parameters>"
```
Примеры можно посмотреть в ```tests\api-tests.sh```.

```
trustvpn-client-create <user name> <profile name>
```
Создает настройки и конфигурирует доступ  для ```<user name>```, связывает личную конфигурацию с ```<profile name>```.

```
trustvpn-client-get <user name>
```
Выводит в ```stdout``` личный файл конфигурации OpenVPN для ```<user name>```.

```
trustvpn-client-modify <user name> <profile name>
```
Связывает личную конфигурацию ```<user name>``` с ```<profile name>```.

```
trustvpn-client-block <user name>
```
Блокирует профиль для ```<user name>```, т.е. удаляет личную конфигурацию из папки ```ccd```, но не отзывает ключ.

```
trustvpn-client-remove <имя пользователя>
```
Удаляет профиль для ```<имени пользователя>```, т.е. отзывает ключ, удаляет личную конфигурацию.

## Traffic shaping

Контейнер реализует возможность ограничения максимально траффика средствами утилиты tc

Логига ограничений наcтраивается при старте контейнера в скрипте ```trustvpn-container-if-start.sh```

```
INTERFACE=tun0  # VPN interface

# Setup the root qdisc and two classes (one for each profile)
#  limited profile:
#   - 1 Mbps
#   - classid 1:10
#  'unlimited' profile:
#   - 100 Mbps
#   - classid 1:20
#  default profile (just in case):
#   - no limits
#   - classid 1:30

tc qdisc add dev $INTERFACE root handle 1: htb default 30

tc class add dev $INTERFACE parent 1: classid 1:10 htb rate 1mbit
tc class add dev $INTERFACE parent 1: classid 1:20 htb rate 100mbit

tc filter add dev $INTERFACE protocol ip parent 1:0 prio 1 handle 10 fw flowid 1:10  # Limited
tc filter add dev $INTERFACE protocol ip parent 1:0 prio 1 handle 20 fw flowid 1:20  # Unlimited

```

В конфигурации OpenVPN реализован вызов пользовательского скрипта ```trustvpn-client-connect.sh```, который настраивает маркировку траффика пользователя.
Для определения класса маркировки скрипт разбирает комментарий вида ```# PROFILE=<профиль>``` в CCD для клиента.
