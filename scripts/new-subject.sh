#!/bin/bash
# =============================================================================
# Скрипт создания нового предмета (билеты)
# =============================================================================
#
# Использование:
#   ./scripts/new-subject.sh "Название предмета" [slug]
#
# Примеры:
#   ./scripts/new-subject.sh "Математический анализ"
#   ./scripts/new-subject.sh "Линейная алгебра" linalg
#   ./scripts/new-subject.sh "С++" cpp
#
# =============================================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
TEMPLATE_DIR="$ROOT_DIR/template"
SUBJECTS_DIR="$ROOT_DIR/subjects"

transliterate() {
    echo "$1" | sed \
        -e 's/а/a/g' -e 's/б/b/g' -e 's/в/v/g' -e 's/г/g/g' -e 's/д/d/g' \
        -e 's/е/e/g' -e 's/ё/yo/g' -e 's/ж/zh/g' -e 's/з/z/g' -e 's/и/i/g' \
        -e 's/й/y/g' -e 's/к/k/g' -e 's/л/l/g' -e 's/м/m/g' -e 's/н/n/g' \
        -e 's/о/o/g' -e 's/п/p/g' -e 's/р/r/g' -e 's/с/s/g' -e 's/т/t/g' \
        -e 's/у/u/g' -e 's/ф/f/g' -e 's/х/kh/g' -e 's/ц/ts/g' -e 's/ч/ch/g' \
        -e 's/ш/sh/g' -e 's/щ/sch/g' -e 's/ъ//g' -e 's/ы/y/g' -e 's/ь//g' \
        -e 's/э/e/g' -e 's/ю/yu/g' -e 's/я/ya/g' \
        -e 's/А/A/g' -e 's/Б/B/g' -e 's/В/V/g' -e 's/Г/G/g' -e 's/Д/D/g' \
        -e 's/Е/E/g' -e 's/Ё/Yo/g' -e 's/Ж/Zh/g' -e 's/З/Z/g' -e 's/И/I/g' \
        -e 's/Й/Y/g' -e 's/К/K/g' -e 's/Л/L/g' -e 's/М/M/g' -e 's/Н/N/g' \
        -e 's/О/O/g' -e 's/П/P/g' -e 's/Р/R/g' -e 's/С/S/g' -e 's/Т/T/g' \
        -e 's/У/U/g' -e 's/Ф/F/g' -e 's/Х/Kh/g' -e 's/Ц/Ts/g' -e 's/Ч/Ch/g' \
        -e 's/Ш/Sh/g' -e 's/Щ/Sch/g' -e 's/Ъ//g' -e 's/Ы/Y/g' -e 's/Ь//g' \
        -e 's/Э/E/g' -e 's/Ю/Yu/g' -e 's/Я/Ya/g' \
        -e 's/ /-/g' -e 's/[^a-zA-Z0-9-]//g' | tr '[:upper:]' '[:lower:]'
}

if [ $# -lt 1 ]; then
    echo -e "${RED}Ошибка: укажите название предмета${NC}"
    echo ""
    echo "Использование: $0 \"Название предмета\" [slug]"
    exit 1
fi

SUBJECT_NAME="$1"
SUBJECT_SLUG="${2:-$(transliterate "$SUBJECT_NAME")}"
SUBJECT_DIR="$SUBJECTS_DIR/$SUBJECT_SLUG"

echo -e "${BLUE}╔══════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Создание предмета (билеты)             ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════╝${NC}"
echo ""
echo -e "  Название:  ${GREEN}$SUBJECT_NAME${NC}"
echo -e "  Папка:     ${GREEN}subjects/$SUBJECT_SLUG/${NC}"
echo ""

if [ -d "$SUBJECT_DIR" ]; then
    echo -e "${RED}Ошибка: папка '$SUBJECT_SLUG' уже существует${NC}"
    exit 1
fi

if [ ! -d "$TEMPLATE_DIR" ]; then
    echo -e "${RED}Ошибка: шаблон не найден в '$TEMPLATE_DIR'${NC}"
    exit 1
fi

mkdir -p "$SUBJECTS_DIR"

echo -e "${YELLOW}→ Копирование шаблона...${NC}"
cp -r "$TEMPLATE_DIR" "$SUBJECT_DIR"

# Очищаем билеты шаблона
rm -f "$SUBJECT_DIR/tickets/"*.tex 2>/dev/null || true

echo -e "${YELLOW}→ Настройка main.tex...${NC}"
sed -i.bak "s/Математический анализ/$SUBJECT_NAME/g" "$SUBJECT_DIR/main.tex"
rm -f "$SUBJECT_DIR/main.tex.bak"

echo -e "${YELLOW}→ Создание первого билета...${NC}"
cat > "$SUBJECT_DIR/tickets/ticket-01.tex" << 'TICKET_EOF'
% =============================================================================
% БИЛЕТ 1
% =============================================================================

\ticket{1}{}

\question{Вопрос 1}

% Ответ...

\question{Вопрос 2}

% Ответ...

\question{Вопрос 3}

% Ответ...

TICKET_EOF

echo ""
echo -e "${GREEN}✓ Предмет успешно создан!${NC}"
echo ""
echo -e "Следующие шаги:"
echo -e "  1. Перейдите в папку:  ${BLUE}cd subjects/$SUBJECT_SLUG${NC}"
echo -e "  2. Положите картинку:  ${BLUE}island.png${NC} (логотип на титульной странице)"
echo -e "  3. Отредактируйте:     ${BLUE}main.tex${NC} (преподаватель, семестр и т.д.)"
echo -e "  4. Добавляйте билеты:  ${BLUE}../../scripts/new-ticket.sh${NC}"
echo -e "  5. Компилируйте:       ${BLUE}xelatex main.tex && xelatex main.tex${NC}"
echo ""
