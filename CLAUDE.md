# CLAUDE.md

This file provides guidance to Claude Code when working with code in this repository.

## Project Overview

GodoMaster is a Claude Code skill providing comprehensive Godot 4.x game development intelligence. Based on official Godot documentation, it covers GDScript, scene architecture, 2D/3D rendering, physics, animation, UI, audio, input, shaders, networking, performance, export, and file I/O.

## Architecture

```
.claude/skills/godomaster/     # Skill entry point
├── SKILL.md                  # Main skill (routing + quick reference)
└── references/               # Detailed reference documents
    ├── 01-godot-project-setup.md
    ├── 02-godot-editor-mastery.md
    ├── 03-gdscript-pro.md
    ├── 04-godot-nodes-scenes.md
    ├── 05-godot-2d-fundamentals.md
    ├── 06-godot-3d-fundamentals.md
    ├── 07-godot-physics.md
    ├── 08-godot-animation.md
    ├── 09-godot-ui-design.md
    ├── 10-godot-audio.md
    ├── 11-godot-input-system.md
    ├── 12-godot-export-deploy.md
    ├── 13-godot-performance.md
    ├── 14-godot-file-io.md
    ├── 15-godot-shaders.md
    ├── 16-godot-networking.md
    ├── 17-godot-testing.md
    └── 18-godot-architecture-tooling.md
```

## Sync Rules

**Source of Truth:** `.claude/skills/godomaster/`

When modifying reference files, edit directly in the `references/` directory. The SKILL.md routing table must be updated if references are added or renamed.

**CLI Assets:** Run sync before publishing:

```bash
cp .claude/skills/godomaster/SKILL.md cli/assets/SKILL.md
cp .claude/skills/godomaster/references/*.md cli/assets/references/
cp README.md README.zh-cn.md cli/assets/
```

## Content Guidelines

- All code examples use GDScript (Godot 4.x syntax)
- Follow official Godot naming conventions (snake_case for files, PascalCase for classes)
- Include verification checklists at the end of each reference
- Keep SKILL.md quick reference under 200 lines
- Detailed content goes in reference files

## Git Workflow

1. Create a new branch: `git checkout -b feat/...` or `fix/...`
2. Commit changes
3. Push branch: `git push -u origin <branch>`
4. Create PR: `gh pr create`
