
# Hyprland Setup Configuration

*Скрипт сделан с помощью нейросетей для личного пользования, извините если вам непонравится)*

### Простестировано на чистой CachyOS с окружением GNOME

Этот репозиторий содержит установочный скрипт для настройки системы Arch Linux с окружением Hyprland. **Конфигурация основана на [dot-файле](https://github.com/end-4/dots-hyprland)**,

## Особенности
- Автоматическая настройка окружения Hyprland
- Установка базовых пакетов и AUR-помощника `yay`
- Оптимизация питания через `tlp` и `powertop`
- Конфигурация мультимедиа (mpv с fuzzy-поиском субтитров и аудио)
- Установка русской раскладки клавиатуры
- Удаление ненужных пакетов
- Автозапуск настройки конфигурации Illogical-Impulse после перезагрузки

## Установка
1. Убедитесь, что используете Arch Linux или производный дистрибутив
2. Запустите скрипт:

\```
bash <(curl -s "https://finikys.github.io/SetupFile/setup.sh")
\```

## Что делает скрипт
### 1. Инициализация
- Устанавливает базовые зависимости если их нет: `git`, `curl`, `perl`, `gcc`, `clang`
- Запускает [dot-файл](https://end-4.github.io/dots-hyprland-wiki/setup.sh)

### 2. Установка пакетов
| Тип | Пакеты |
|-----|--------|
| Основные | `git mpv telegram-desktop discord steam btop qbittorrent obsidian code` |
| AUR | `google-chrome` |
| Утилиты | `tlp powertop jq` |

## Удаляемые пакеты
Скрипт удаляет следующие пакеты при их наличии:
`mplayer`, `totem`, `alacritty`, `gnome-maps`, `gnome-software`,
`gnome-terminal`, `htop`, `firefox-i18n-ru`, `firefox`, `dolphin`

### 3. Оптимизация системы
- Активация сервисов:
  
\```
  sudo systemctl enable --now tlp
  sudo systemctl mask power-profiles-daemon
  sudo systemctl enable powertop.service
\```

- Автоматическая настройка powertop:
  
\```
  sudo powertop --auto-tune
\```

### 4. Настройка приложений
**MPV**:
- Fuzzy-поиск аудио и субтитров
- Кастомные хоткеи:
  - <kdb>Ctrl</kdb> + <kdb>← / <kdb>→</kdb> : переключение глав
  - <kdb>Shift</kdb> + <kdb>←</kdb> / <kdb>→</kdb> : перемотка на 85 сек
  - <kdb>↑</kdb> / <kdb>↓</kdb> : навигация по плейлисту

**Раскладка клавиатуры**:
- Переключение рус/англ: Alt+Shift

### 5. Автозапуск
Создает сервис для выполнения конфигурации Illogical-Impulse после перезагрузки:
bash
sudo systemctl enable illogical-impulse-autostart.service

## После установки
**Перезагрузите систему** для применения всех изменений

> **Warning**  
> Скрипт запрашивает подтверждение перед запуском.  
> Рекомендуется запускать на чистой системе.