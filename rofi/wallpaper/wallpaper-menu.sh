#!/bin/bash
WALL_DIR="$HOME/.config/hypr/wallpapers"

LIST=$(find "$WALL_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.jpeg" \) | sed "s|$WALL_DIR/||" | sort)

if [ -z "$LIST" ]; then
    notify-send "🖼️ Обои" "В папке $WALL_DIR не найдено изображений"
    exit 1
fi

CHOSEN=$(echo "$LIST" | rofi -dmenu -p " " -i -lines 15 -width 40)

if [ -n "$CHOSEN" ]; then
    awww img "$WALL_DIR/$CHOSEN" --transition-type wipe --transition-duration 0.5
fi
