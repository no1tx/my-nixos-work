# NixOS Configuration

## Структура

- `configuration.nix` — основной файл, импортирует модули и host-специфику
- `modules/` — общие модули (system, users, boot, networking, desktop, virtualization, services, maintenance, packages)
- `hosts/` — специфичные для железа настройки (hostname, драйверы, hardware-configuration.nix)

## Как использовать

1. В `configuration.nix` выберите нужный host (desktop, laptop и т.д.)
2. Для новой машины создайте новый файл в `hosts/` и hardware-configuration.nix
3. Все общие настройки редактируйте в `modules/`
