# GodoMaster

A comprehensive Claude Code skill for Godot 4.x game development. Based on the official Godot documentation, covering the complete game development workflow.

## What's Included

| Domain | Coverage |
|--------|----------|
| **Project Setup** | Renderer selection, folder structure, .gitignore, autoloads, input map |
| **Editor** | Shortcuts, panels, debugger, profiler, remote scene tree |
| **GDScript** | Type system, @export, signals, movement patterns, state machine, object pooling |
| **Nodes & Scenes** | Full node reference, scene composition, lifecycle, component pattern |
| **2D** | Sprites, TileMapLayer, terrains, parallax, 2D lighting, particles, camera |
| **3D** | Model import, PBR materials, lighting, environment, fog, sky, navigation |
| **Physics** | Collision layers, hitbox/hurtbox, raycasting, rigid bodies, joints |
| **Animation** | AnimationPlayer, Tween (chain/parallel/ease), AnimationTree, procedural effects |
| **UI** | Control nodes, layouts, anchors, themes, dialog system, inventory UI |
| **Audio** | Audio buses, effects, SFX pool, spatial audio, dynamic music layers |
| **Input** | Input Map, raw input, gamepad, touch, virtual joystick, key rebinding |
| **Export** | Windows/Mac/Linux/Web/Android/iOS, CI/CD, Steam/itch.io |
| **Performance** | Profiling, draw calls, MultiMesh, occlusion culling, pooling |
| **File I/O** | Save/load system, JSON, ConfigFile, CSV, Resources, encryption |
| **Shaders** | 2D effects (dissolve, outline, water), 3D materials (hologram, force field), post-processing |
| **Networking** | ENet, RPC, MultiplayerSpawner/Synchronizer, lobby, client prediction |

## Installation

### NPM (recommended)

```bash
# Install globally, auto-copies to ~/.claude/skills/godomaster/
npm install -g godomaster-skill

# Or run without installing
npx godomaster-skill
```

Options:
- `npx godomaster-skill --force` — overwrite existing installation
- `npx godomaster-skill --dry-run` — preview without installing

### Shell Script (curl)

```bash
# Install directly from repository
curl -fsSL https://raw.githubusercontent.com/yanha/GodoMaster/main/install.sh | bash

# With force reinstall
curl -fsSL https://raw.githubusercontent.com/yanha/GodoMaster/main/install.sh | bash -s -- --force
```

### Manual Copy

Copy to `~/.claude/skills/godomaster/`:

```
~/.claude/skills/
└── godomaster/
    ├── SKILL.md
    └── references/
        ├── 01-godot-project-setup.md
        ├── 02-godot-editor-mastery.md
        ├── ...
        └── 16-godot-networking.md
```

### Claude Marketplace (plugin)

Install via the plugin system:

```json
// .claude-plugin/plugin.json
{
  "name": "godomaster",
  "skills": ["./.claude/skills/godomaster"]
}
```

## Usage

Type `/godomaster` to invoke the main skill, or mention any Godot topic to auto-load the relevant sub-skill:

- "set up a new Godot project" → project setup
- "write a player movement script" → GDScript + physics
- "create a dissolve shader" → shaders
- "implement save game" → file I/O
- "optimize draw calls" → performance

## Structure

```
GodoMaster/
├── skill.json                    # Skill metadata
├── README.md                     # This file
├── README.zh-cn.md               # Chinese documentation
├── CLAUDE.md                     # Project guidance
├── install.sh                    # Shell installer
├── .gitignore
├── .claude-plugin/
│   ├── plugin.json               # Plugin config
│   └── marketplace.json          # Marketplace listing
├── .claude/skills/godomaster/
│   ├── SKILL.md                  # Main skill (routing + quick ref)
│   └── references/               # 16 detailed reference files
│       ├── 01-godot-project-setup.md
│       ├── 02-godot-editor-mastery.md
│       ├── 03-gdscript-pro.md
│       ├── 04-godot-nodes-scenes.md
│       ├── 05-godot-2d-fundamentals.md
│       ├── 06-godot-3d-fundamentals.md
│       ├── 07-godot-physics.md
│       ├── 08-godot-animation.md
│       ├── 09-godot-ui-design.md
│       ├── 10-godot-audio.md
│       ├── 11-godot-input-system.md
│       ├── 12-godot-export-deploy.md
│       ├── 13-godot-performance.md
│       ├── 14-godot-file-io.md
│       ├── 15-godot-shaders.md
│       └── 16-godot-networking.md
├── cli/
│   ├── package.json              # NPM package
│   ├── bin/install.js            # Installer
│   └── assets/                   # Bundled skill files
└── src/godomaster/               # Source of truth
    ├── data/                     # Data files (future)
    └── templates/                # Templates (future)
```

## License

MIT
