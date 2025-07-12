
# Hyprland Setup Configuration

*Скрипт сделан с помощью нейросетей для личного пользования, извините если вам непонравится)*

### Простестировано на чистой CachyOS с окружением GNOME

#### 1. Установите **[dot-файл](https://github.com/end-4/dots-hyprland)**,
#### 2. Перезагрузите систему,
#### 3. Запустите конфиг настройки:

```bash
bash <(curl -s "https://finikys.github.io/SetupFile/setup.sh")
```

## Особенности
- Автоматическая настройка окружения Hyprland
- Установка базовых пакетов и AUR-помощника `yay`
- Оптимизация питания через `tlp` и `powertop`
- Конфигурация мультимедиа (mpv с fuzzy-поиском субтитров и аудио)
- Установка русской раскладки клавиатуры
- Удаление ненужных пакетов
- Автозапуск настройки конфигурации Illogical-Impulse после перезагрузки

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
  
```bash
  sudo systemctl enable --now tlp
  sudo systemctl mask power-profiles-daemon
  sudo systemctl enable powertop.service
```

- Автоматическая настройка powertop:
  
```bash
  sudo powertop --auto-tune
```

### 4. Настройка приложений
**MPV**:
- Fuzzy-поиск аудио и субтитров
- Кастомные хоткеи:
  - <kdb>Ctrl</kdb> + <kdb>←</kdb> / <kdb>→</kdb> : переключение глав
  - <kdb>Shift</kdb> + <kdb>←</kdb> / <kdb>→</kdb> : перемотка на 85 сек
  - <kdb>↑</kdb> / <kdb>↓</kdb> : навигация по плейлисту

**Раскладка клавиатуры**:
- Переключение рус/англ: Alt+Shift

## После установки
**Перезагрузите систему** для применения всех изменений