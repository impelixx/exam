#!/bin/bash
# =============================================================================
# Скрипт создания нового билета
# =============================================================================
#
# Использование (из папки предмета):
#   ../../scripts/new-ticket.sh [номер]
#
# Или с указанием предмета из корня:
#   ./scripts/new-ticket.sh <предмет> [номер]
#
# Примеры:
#   ./scripts/new-ticket.sh cpp 5
#   cd subjects/cpp && ../../scripts/new-ticket.sh 3
#
# =============================================================================

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# Определение директории предмета
if [ -f "main.tex" ] && [ -d "tickets" ]; then
    SUBJECT_DIR="$(pwd)"
    TICKET_NUM="${1:-}"
elif [ $# -ge 1 ] && [ -d "$ROOT_DIR/subjects/$1" ]; then
    SUBJECT_DIR="$ROOT_DIR/subjects/$1"
    TICKET_NUM="${2:-}"
else
    echo -e "${RED}Ошибка: не удалось определить предмет${NC}"
    echo ""
    echo "Использование:"
    echo "  Из папки предмета: ../../scripts/new-ticket.sh [номер]"
    echo "  Из корня:          ./scripts/new-ticket.sh <предмет> [номер]"
    exit 1
fi

TICKETS_DIR="$SUBJECT_DIR/tickets"

# Автоопределение номера билета
if [ -z "$TICKET_NUM" ]; then
    LAST_NUM=$(ls "$TICKETS_DIR"/ticket-*.tex 2>/dev/null | \
        sed 's/.*ticket-\([0-9]*\)\.tex/\1/' | \
        sort -n | tail -1 || echo "0")
    TICKET_NUM=$((10#$LAST_NUM + 1))
fi

TICKET_NUM_PADDED=$(printf "%02d" "$TICKET_NUM")
TICKET_FILE="$TICKETS_DIR/ticket-$TICKET_NUM_PADDED.tex"

if [ -f "$TICKET_FILE" ]; then
    echo -e "${RED}Ошибка: файл ticket-$TICKET_NUM_PADDED.tex уже существует${NC}"
    exit 1
fi

cat > "$TICKET_FILE" << TICKET_EOF
% =============================================================================
% БИЛЕТ $TICKET_NUM
% =============================================================================

\\ticket{$TICKET_NUM}{}

\\question{Вопрос 1}

% Ответ...

\\question{Вопрос 2}

% Ответ...

\\question{Вопрос 3}

% Ответ...

TICKET_EOF

echo -e "${GREEN}✓ Создан билет: ticket-$TICKET_NUM_PADDED.tex${NC}"
echo -e "  Путь: ${BLUE}$TICKET_FILE${NC}"
