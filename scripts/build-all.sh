#!/bin/bash
# =============================================================================
# Сборка всех билетов
# =============================================================================
#
# Использование:
#   ./scripts/build-all.sh           - собрать все предметы
#   ./scripts/build-all.sh <slug>    - собрать один предмет
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
SUBJECTS_DIR="$ROOT_DIR/subjects"
OUTPUT_DIR="$ROOT_DIR/output"

mkdir -p "$OUTPUT_DIR"

build_subject() {
    local subject_dir="$1"
    local subject_name=$(basename "$subject_dir")

    if [ ! -f "$subject_dir/main.tex" ]; then
        return 1
    fi

    echo -e "${YELLOW}→ Сборка: $subject_name${NC}"

    cd "$subject_dir"

    if xelatex -interaction=nonstopmode -halt-on-error main.tex > /dev/null 2>&1 \
    && xelatex -interaction=nonstopmode -halt-on-error main.tex > /dev/null 2>&1; then
        cp main.pdf "$OUTPUT_DIR/${subject_name}.pdf"
        echo -e "${GREEN}  ✓ ${subject_name}.pdf${NC}"
    else
        echo -e "${RED}  ✗ Ошибка сборки${NC}"
        xelatex -interaction=nonstopmode main.tex 2>&1 | grep -E "^!|Error" | head -5 | sed "s/^/    /"
        cd - > /dev/null
        return 1
    fi

    cd - > /dev/null
    return 0
}

echo -e "${BLUE}╔══════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Сборка билетов                       ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════╝${NC}"
echo ""

SUCCESS=0
FAILED=0

if [ $# -ge 1 ]; then
    SUBJECT="$1"
    if [ -d "$SUBJECTS_DIR/$SUBJECT" ]; then
        if build_subject "$SUBJECTS_DIR/$SUBJECT"; then
            SUCCESS=$((SUCCESS + 1))
        else
            FAILED=$((FAILED + 1))
        fi
    else
        echo -e "${RED}Предмет '$SUBJECT' не найден${NC}"
        exit 1
    fi
else
    for subject_dir in "$SUBJECTS_DIR"/*/; do
        if [ -d "$subject_dir" ]; then
            if build_subject "$subject_dir"; then
                SUCCESS=$((SUCCESS + 1))
            else
                FAILED=$((FAILED + 1))
            fi
        fi
    done
fi

echo ""
echo -e "${BLUE}═══════════════════════════════════════════${NC}"
echo -e "Успешно: ${GREEN}$SUCCESS${NC}"
echo -e "Ошибок:  ${RED}$FAILED${NC}"
echo -e "Выход:   ${BLUE}$OUTPUT_DIR/${NC}"
echo ""
