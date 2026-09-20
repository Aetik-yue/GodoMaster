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

# Bail out before fetching anything if this is a plain re-run over an existing install
if [ -d "$TARGET" ] && [ "$1" != "--force" ] && [ "$1" != "-f" ]; then
    echo -e "${YELLOW}⚠ Already installed at: ${TARGET}${NC}"
    echo -e "${CYAN}ℹ Use --force to reinstall.${NC}"
    exit 0
fi

REPO_URL="https://github.com/Aetik-yue/GodoMaster.git"
TMP_DIR=""
trap 'if [ -n "$TMP_DIR" ]; then rm -rf "$TMP_DIR"; fi' EXIT

# Locate the skill source. Run via `curl | bash` there are no local files, so fetch the repo.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_SRC="${SCRIPT_DIR}/.claude/skills/godomaster"

if [ ! -f "${SKILL_SRC}/SKILL.md" ]; then
    if ! command -v git >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠ git is needed to fetch the skill. Clone the repo and run ./install.sh instead.${NC}"
        exit 1
    fi
    TMP_DIR="$(mktemp -d)"
    echo -e "${CYAN}ℹ Fetching ${REPO_URL}${NC}"
    if ! git clone --quiet --depth 1 "$REPO_URL" "${TMP_DIR}/repo"; then
        echo -e "${YELLOW}⚠ Clone failed — check network and that the repo is public.${NC}"
        exit 1
    fi
    SCRIPT_DIR="${TMP_DIR}/repo"
    SKILL_SRC="${SCRIPT_DIR}/.claude/skills/godomaster"
fi

# A source is in hand now, so replacing the old install is safe. Wipe it rather than overwrite,
# so references renamed or removed since the last install don't linger in the target.
if [ -d "$TARGET" ]; then
    case "$TARGET" in
        */.claude/skills/godomaster) rm -rf "$TARGET" ;;
        *) echo -e "${YELLOW}⚠ Refusing to replace unexpected path: ${TARGET}${NC}"; exit 1 ;;
    esac
    echo -e "${CYAN}ℹ Replaced the previous installation.${NC}"
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

# Copy READMEs (they live at the repo root, not in the skill directory)
for readme in "README.md" "README.en.md"; do
    if [ -f "${SCRIPT_DIR}/${readme}" ]; then
        cp "${SCRIPT_DIR}/${readme}" "$TARGET/"
        echo -e "${GREEN}✓${NC} Installed: ${readme}"
    fi
done

if [ ! -f "${TARGET}/SKILL.md" ]; then
    echo -e "${YELLOW}⚠ Nothing installed — SKILL.md not found in ${SKILL_SRC}${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}✓ GodoMaster installed to: ${TARGET}${NC}"
echo ""
echo -e "${CYAN}ℹ Usage: Type /godomaster in Claude Code, or mention any Godot topic.${NC}"
echo -e "${CYAN}  Topics: GDScript, scene, tilemap, shader, physics, animation, etc.${NC}"
echo ""
