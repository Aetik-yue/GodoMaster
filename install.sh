#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

TARGET="${HOME}/.claude/skills/godomaster"

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════╗"
echo -e "║   GodoMaster — Installer                 ║"
echo -e "║   Godot 4.x Game Development Intelligence║"
echo -e "╚══════════════════════════════════════════╝${NC}"
echo ""

# Check if already installed
if [ -d "$TARGET" ]; then
    echo -e "${YELLOW}⚠ Already installed at: ${TARGET}${NC}"
    if [ "$1" != "--force" ] && [ "$1" != "-f" ]; then
        echo -e "${CYAN}ℹ Use --force to reinstall.${NC}"
        exit 0
    fi
    echo -e "${CYAN}ℹ Forcing reinstall...${NC}"
fi

# Find skill source (relative to script location)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_SRC="${SCRIPT_DIR}/.claude/skills/godomaster"

# If not in repo structure, try current directory
if [ ! -d "$SKILL_SRC" ]; then
    SKILL_SRC="${SCRIPT_DIR}"
fi

# Create target directory
mkdir -p "$TARGET"

# Copy SKILL.md
if [ -f "${SKILL_SRC}/SKILL.md" ]; then
    cp "${SKILL_SRC}/SKILL.md" "$TARGET/SKILL.md"
    echo -e "${GREEN}✓${NC} Installed: SKILL.md"
fi

# Copy references
if [ -d "${SKILL_SRC}/references" ]; then
    cp -r "${SKILL_SRC}/references" "$TARGET/"
    REF_COUNT=$(ls "$TARGET/references" | wc -l)
    echo -e "${GREEN}✓${NC} Installed: references/ (${REF_COUNT} files)"
fi

# Copy READMEs
for readme in "${SKILL_SRC}/README.md" "${SKILL_SRC}/README.zh-cn.md"; do
    if [ -f "$readme" ]; then
        cp "$readme" "$TARGET/"
    fi
done

echo ""
echo -e "${GREEN}✓ GodoMaster installed to: ${TARGET}${NC}"
echo ""
echo -e "${CYAN}ℹ Usage: Type /godomaster in Claude Code, or mention any Godot topic.${NC}"
echo -e "${CYAN}  Topics: GDScript, scene, tilemap, shader, physics, animation, etc.${NC}"
echo ""
