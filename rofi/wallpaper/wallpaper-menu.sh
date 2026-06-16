#!/bin/bash

set -euo pipefail

WALL_DIR="$HOME/.config/hypr/wallpapers"
WAYBAR_DIR="$HOME/.config/waybar"
ROFI_CONF="$HOME/.config/rofi/config.rasi"
ALACRITTY_DIR="$HOME/.config/alacritty"

LIST=$(find "$WALL_DIR" -type f \( \
    -iname "*.jpg" -o \
    -iname "*.jpeg" -o \
    -iname "*.png" -o \
    -iname "*.webp" \
\) | sed "s|$WALL_DIR/||" | sort)

if [ -z "$LIST" ]; then
    notify-send "🖼️ Обои" "В папке $WALL_DIR не найдено изображений"
    exit 1
fi

CHOSEN=$(echo "$LIST" | rofi -dmenu -i -p " " -lines 15)

[ -z "${CHOSEN:-}" ] && exit 0

if command -v awww >/dev/null 2>&1; then
    awww img "$WALL_DIR/$CHOSEN" \
        --transition-type wipe \
        --transition-duration 0.5
fi

THEME=$(printf "Тёмная\nСветлая\n" | rofi -dmenu -p "🎨 Тема")

[ -z "${THEME:-}" ] && exit 0

echo "THEME=[$THEME]"
echo "WAYBAR_DIR=[$WAYBAR_DIR]"

for file in \
    "$WAYBAR_DIR/style.css" \
    "$WAYBAR_DIR/style-dark.css" \
    "$WAYBAR_DIR/style-light.css"
do
    if [ ! -f "$file" ]; then
        notify-send "❌ Ошибка" "Не найден файл: $file"
        exit 1
    fi
done

case "$THEME" in
    "Светлая")
        echo "Переключение на светлую тему"

        if [ -f "$ROFI_CONF" ]; then
            sed -i '12s|.*|@import "/themes/ef-cherie-light.rasi"|' "$ROFI_CONF"
        fi

        cp -f "$WAYBAR_DIR/style-light.css" "$WAYBAR_DIR/style.css"
        cp -f "$ALACRITTY_DIR/themes/theme-light.toml" "$ALACRITTY_DIR/themes/theme.toml"

        notify-send "🎨 Тема" "Применена СВЕТЛАЯ тема"
        ;;

    "Тёмная")
        echo "Переключение на тёмную тему"

        if [ -f "$ROFI_CONF" ]; then
            sed -i '12s|.*|@import "themes/ef-cherie-dark.rasi"|' "$ROFI_CONF"
        fi

        cp -f "$WAYBAR_DIR/style-dark.css" "$WAYBAR_DIR/style.css"
        cp -f "$ALACRITTY_DIR/themes/theme-dark.toml" "$ALACRITTY_DIR/themes/theme.toml"

        notify-send "🎨 Тема" "Применена ТЁМНАЯ тема"
        ;;

    *)
        echo "Неизвестный выбор: [$THEME]"
        exit 1
        ;;
esac

echo
echo "===== style.css ====="
head -n 10 "$WAYBAR_DIR/style.css"
echo "====================="
echo

pkill -x waybar 2>/dev/null || true
sleep 1

nohup waybar >/dev/null 2>&1 &

notify-send "✅ Готово" "Waybar перезапущен"