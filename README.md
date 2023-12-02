# TrustVPN
Контейнер OpenVPN Docker для проекта TrustVPN.
Данный проект - небольшая обертка для ```kylemanna/openvpn```, не более.

## Конфигурация и инициализация

Профили пользователей определяются файлами в папке ```app/profiles```. Имена файлов должны соответствовать именам профилей, используемых openvpn-backend. При необходимости изменения или добавления профиля, необходимо перестроить контейнер или внести изменения 'внутри'.

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
