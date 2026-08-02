

# GodoMaster

<p align="center">
  <img src="https://github.com/Aetik-yue/GodoMaster/raw/main/icon.png" width="128" height="128" alt="GodoMaster"><br>
  <img src="https://img.shields.io/github/stars/aetik-yue/GodoMaster?style=flat-square&label=stars" alt="Stars">
</p>

[**English**](README.en.md) | **简体中文**

A Claude Code game development skill pack built upon the official Godot documentation, covering the complete Godot 4.x development workflow.

## What's Included

| Domain | Coverage |
|--------|----------|
| **Project Setup** | Renderer selection, directory structure, .gitignore, auto-load, input mapping |
| **Editor** | Shortcuts, panels, debugger, performance monitor, remote scene tree |
| **GDScript** | Type system, @export, signals, movement patterns, state machines, object pooling |
| **Nodes & Scenes** | Complete node reference, scene composition, lifecycle, component pattern |
| **2D Development** | Sprites, TileMapLayer, terrain, parallax scrolling, 2D lighting, particles, camera |
| **3D Development** | Model import, PBR materials, lighting, environment, fog, sky, navigation |
| **Physics System** | Collision layers, hurtbox/hitbox, raycasting, rigid bodies, joints |
| **Animation System** | AnimationPlayer, Tween (chained/parallel/easing), AnimationTree, procedural animation |
| **UI Design** | Control nodes, layout, anchors, themes, dialogue systems, inventory UI |
| **Audio System** | Audio buses, sound pools, spatial audio, dynamic music layering |
| **Input System** | Input Map, raw input, gamepad, touchscreen, virtual joystick, key remapping |
| **Export & Deployment** | Windows/Mac/Linux/Web/Android/iOS, CI/CD, Steam/itch.io |
| **Performance Optimization** | Profiling, DrawCalls, MultiMesh, occlusion culling, object pooling |
| **File I/O** | Save systems, JSON, ConfigFile, CSV, Resource, encryption |
| **Shaders** | 2D effects (dissolve, outline, water), 3D materials (hologram, forcefield), post-processing |
| **Networking** | ENet, RPC, MultiplayerSpawner/Synchronizer, lobbies, client prediction |
| **Unit Testing** | GdUnit4 framework, unit testing, scene testing, mocking, CI/CD automation integration |
| **Architecture & Tooling** | Custom Resource architecture, @tool scripts, GDExtension (C++), EditorPlugin, EditorScript |
| **Localization** | tr(), TranslationServer, .po/.csv import, plural rules, pseudolocalization, RTL |
| **AI Behavior** | State machines, behavior trees, utility AI, NavigationAgent pathfinding/obstacle avoidance, LimboAI |
| **Asset Pipeline** | ResourceImporter, EditorImportPlugin, custom loaders/savers, Addon ecosystem |

## Installation

### NPM (Recommended)

```bash
# Global install, automatically copies to ~/.claude/skills/godomaster/
npm install -g godomaster-skill

# Or run directly without installing
npx godomaster-skill
```

Options:
- `npx godomaster-skill --force` — Overwrite existing installation
- `npx godomaster-skill --dry-run` — Preview without installing

### One-Click Shell Install (curl)

```bash
# Install directly from the repository
curl -fsSL https://raw.githubusercontent.com/yanha/GodoMaster/main/install.sh | bash

# Force reinstall
curl -fsSL https://raw.githubusercontent.com/yanha/GodoMaster/main/install.sh | bash -s -- --force
```

### Manual Copy

Copy the skill pack to `~/.claude/skills/godomaster/`:

```
~/.claude/skills/
└── godomaster/
    ├── SKILL.md              ← Main entry (routing + quick reference)
    └── references/           ← 21 detailed reference documents
        ├── 01-godot-project-setup.md
        ├── 02-godot-editor-mastery.md
        ├── ...
        └── 18-godot-architecture-tooling.md
        ├── 19-godot-localization.md           # Localization
        ├── 20-godot-ai-behavior.md            # AI Behavior System
        └── 21-godot-asset-pipeline.md         # Asset Pipeline
```

### Claude Plugin Marketplace

Install via the plugin system:

```json
// .claude-plugin/plugin.json
{
  "name": "godomaster",
  "skills": ["./.claude/skills/godomaster"]
}
```

## Usage

Type `/godomaster` to invoke the main skill, or mention Godot-related keywords in conversation to automatically load the corresponding reference:

| You say | Auto-loads |
|---------|------------|
| "Create a new Godot project" | Project Setup |
| "Write a character movement script" | GDScript + Physics |
| "Make a dissolve shader" | Shaders |
| "Implement save functionality" | File I/O |
| "Optimize DrawCalls" | Performance Optimization |
| "How to do multiplayer" | Networking |
| "Build a main menu UI" | UI Design |
| "Add background music and sound effects" | Audio System |

## Agent Integration (Optional)

If you are using Godot-related Agents like `godot-master`, you can allow the Agent to access the skill pack's knowledge base. Edit the Agent's configuration file (e.g., `~/.claude/agents/godot-master.md`) and add the following before the "Knowledge Scope" section:

```markdown
## Knowledge Base

When detailed technical references are needed, read the following GodoMaster skill pack files:

- **Main Entry**: `~/.claude/skills/godomaster/SKILL.md` (routing index + quick reference)
- **Reference Directory**: `~/.claude/skills/godomaster/references/`, containing 21 modules

| File | Content |
|------|--------|
| `01-godot-project-setup.md` | Project setup, renderer, directory structure, auto-load |
| `02-godot-editor-mastery.md` | Editor shortcuts, panels, debugging tools |
| `03-gdscript-pro.md` | GDScript type system, signals, state machines, object pooling |
| `04-godot-nodes-scenes.md` | Node reference, scene composition, lifecycle, component pattern |
| `05-godot-2d-fundamentals.md` | Sprites, TileMap, parallax, 2D lighting, camera |
| `06-godot-3d-fundamentals.md` | Model import, PBR materials, lighting, environment, navigation |
| `07-godot-physics.md` | Collision layers, hurtbox, raycasting, rigid bodies, joints |
| `08-godot-animation.md` | AnimationPlayer, Tween, AnimationTree |
| `09-godot-ui-design.md` | Control nodes, layout, anchors, themes, dialogue system |
| `10-godot-audio.md` | Audio buses, sound pools, spatial audio, dynamic music |
| `11-godot-input-system.md` | Input Map, gamepad, touchscreen, key remapping |
| `12-godot-export-deploy.md` | Export presets, CI/CD, Steam/itch.io |
| `13-godot-performance.md` | Profiling, DrawCalls, MultiMesh, object pooling |
| `14-godot-file-io.md` | Save system, JSON, ConfigFile, encryption |
| `15-godot-shaders.md` | CanvasItem shaders, Spatial shaders, post-processing |
| `16-godot-networking.md` | ENet, RPC, synchronizer, lobbies, client prediction |
| `17-godot-testing.md` | GdUnit4, unit & integration testing, PlayGodot automation, CI/CD |
| `18-godot-architecture-tooling.md` | Custom Resources, @tool scripts, GDExtension, EditorPlugin, EditorScript |
| `19-godot-localization.md` | Localization, tr(), TranslationServer, plural rules, pseudolocalization |
| `20-godot-ai-behavior.md` | State machines, behavior trees, utility AI, navigation AI, LimboAI |
| `21-godot-asset-pipeline.md` | ResourceImporter, EditorImportPlugin, Addon ecosystem |
```

Once configured, the Agent will automatically consult these reference documents when answering Godot-related questions, sharing the same knowledge base as the Skill.

## Project Structure

```
GodoMaster/
├── skill.json                    # Skill metadata
├── README.md                     # Chinese documentation (main page)
├── README.en.md                  # English documentation
├── CLAUDE.md                     # Project guidance
├── install.sh                    # Shell install script
├── .gitignore
├── .claude-plugin/
│   ├── plugin.json               # Plugin configuration
│   └── marketplace.json          # Marketplace listing configuration
├── .claude/skills/godomaster/
│   ├── SKILL.md                  # Main skill (routing + quick reference)
│   └── references/               # 21 detailed reference documents
│       ├── 01-godot-project-setup.md     # Project Setup
│       ├── 02-godot-editor-mastery.md    # Editor Mastery
│       ├── 03-gdscript-pro.md            # Advanced GDScript
│       ├── 04-godot-nodes-scenes.md      # Nodes & Scenes
│       ├── 05-godot-2d-fundamentals.md   # 2D Fundamentals
│       ├── 06-godot-3d-fundamentals.md   # 3D Fundamentals
│       ├── 07-godot-physics.md           # Physics System
│       ├── 08-godot-animation.md         # Animation System
│       ├── 09-godot-ui-design.md         # UI Design
│       ├── 10-godot-audio.md             # Audio System
│       ├── 11-godot-input-system.md      # Input System
│       ├── 12-godot-export-deploy.md     # Export & Deployment
│       ├── 13-godot-performance.md       # Performance Optimization
│       ├── 14-godot-file-io.md           # File I/O
│       ├── 15-godot-shaders.md           # Shaders
│       ├── 16-godot-networking.md        # Networking
│       ├── 17-godot-testing.md           # Unit Testing & CI
│       └── 18-godot-architecture-tooling.md # Architecture & Editor Tooling
│       ├── 19-godot-localization.md          # Localization
│       ├── 20-godot-ai-behavior.md           # AI Behavior System
│       └── 21-godot-asset-pipeline.md        # Asset Pipeline
├── cli/
│   ├── package.json              # NPM package configuration
│   ├── bin/install.js            # Install script
│   └── assets/                   # Skill files
└── src/godomaster/               # Source directory (future expansion)
    ├── data/                     # Data files
    └── templates/                # Template files
```

## Quick Reference

### Basic GDScript Structure

```gdscript
extends CharacterBody2D
class_name Player

const SPEED := 300.0
signal health_changed(new_health: int)

@export var max_health := 100
@onready var sprite := $Sprite2D

var health: int
var velocity := Vector2.ZERO

func _ready() -> void:
    health = max_health

func _physics_process(delta: float) -> void:
    var direction := Input.get_axis("move_left", "move_right")
    velocity.x = direction * speed
    move_and_slide()
```

### Common Node Compositions

```
Player (CharacterBody2D)
├── CollisionShape2D
├── Sprite2D / AnimatedSprite2D
├── AnimationPlayer
├── Camera2D
├── Hitbox (Area2D) → CollisionShape2D
└── Hurtbox (Area2D) → CollisionShape2D

HUD (CanvasLayer)
├── MarginContainer
│   ├── HealthBar (TextureProgressBar)
│   └── ScoreLabel (Label)
```

### Renderer Selection

| Renderer | Use Case |
|----------|----------|
| **Forward+** | Desktop, high fidelity |
| **Mobile** | Mid-range devices, balanced quality & performance |
| **Compatibility** | Low-end devices, Web, legacy hardware |

### Collision Layer Planning

```
Layer 1: Player      Mask: 2,3,4
Layer 2: Walls      Mask: (none)
Layer 3: Enemies    Mask: 1,2
Layer 4: Pickups   Mask: 1
```

## License

MIT
