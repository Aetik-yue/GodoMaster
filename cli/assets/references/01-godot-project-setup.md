---
name: godot-project-setup
description: "Create, configure, and organize Godot projects from scratch. Use when setting up a new game project, configuring project settings, choosing renderer, setting up version control, or organizing folder structure."
triggers:
  - "new project"
  - "project setup"
  - "project configuration"
  - "project.godot"
  - "renderer choice"
  - "folder structure"
  - "version control"
  - "gitignore"
---

# Godot Project Setup

Guide the user through creating and configuring a Godot 4.x project from zero to a working development environment.

## Project Creation

### Choosing the Right Version
- Use **Godot 4.x stable** for new projects
- Use **standard version** (GDScript) unless C# is explicitly needed
- C# version requires .NET SDK and has separate export templates

### Renderer Selection
| Renderer | Best For | Trade-off |
|----------|----------|-----------|
| **Forward+** | Desktop, high-end | Best visuals, higher GPU requirement |
| **Mobile** | Mid-range devices | Balanced quality and performance |
| **Compatibility** | Low-end, web, old hardware | Broadest support, limited effects |

Decision flow:
1. Target desktop only? → **Forward+**
2. Target mobile or web? → **Compatibility**
3. Need to support both? → **Mobile** as baseline

### Project Settings Essentials
```
# Must configure early:
display/window/size/viewport_width   # Game resolution width
display/window/size/viewport_height  # Game resolution height
display/window/stretch/mode          # canvas_items (recommended)
display/window/stretch/aspect        # expand or keep
rendering/renderer/rendering_method  # forward_plus, mobile, gl_compatibility
```

## Folder Structure

### Recommended Layout
```
project/
├── scenes/
│   ├── world/          # Levels, maps, environments
│   ├── ui/             # Menus, HUD, dialogs
│   ├── actors/         # Player, NPCs, enemies
│   ├── buildings/      # Structures, furniture
│   └── effects/        # Particles, VFX scenes
├── scripts/
│   ├── core/           # Autoloads, globals, save/load
│   ├── systems/        # Economy, inventory, AI, time
│   ├── components/     # Reusable node behaviors
│   └── ui/             # UI-specific scripts
├── resources/
│   ├── data/           # Balance tables, configs
│   ├── themes/         # UI themes, fonts
│   └── materials/      # Shared materials
├── art/
│   ├── sprites/        # 2D sprites and sheets
│   ├── tiles/          # Tilemap assets
│   ├── audio/          # Music and SFX
│   └── vfx/            # Particle textures
└── addons/             # Third-party plugins
```

### Naming Conventions
- **Scenes**: `snake_case.tscn` → `player.tscn`, `main_menu.tscn`
- **Scripts**: `snake_case.gd` → `player.gd`, `inventory_system.gd`
- **Resources**: `snake_case.tres` → `default_theme.tres`
- **PascalCase** for class names in GDScript: `class_name PlayerController`

## Version Control

### .gitignore for Godot
```
# Godot-specific
.godot/
*.import
export.cfg
export_presets.cfg

# Imported resources
.import/

# IDE
.idea/
.vscode/
*.code-workspace

# OS
.DS_Store
Thumbs.db

# Builds
builds/
export/
```

### What to Track
- `project.godot` — always
- `*.tscn`, `*.gd`, `*.tres` — always
- `*.import` — debatable, small projects can include
- `.godot/` — never (auto-generated)

### Git LFS Setup
Game projects involve large binary files (textures, audio, 3D meshes, fonts). Use Git LFS (Large File Storage) to prevent repository bloat.

Create a `.gitattributes` file in the project root:
```
# 3D models and animation
*.fbx filter=lfs diff=lfs merge=lfs -text
*.obj filter=lfs diff=lfs merge=lfs -text
*.gltf filter=lfs diff=lfs merge=lfs -text
*.glb filter=lfs diff=lfs merge=lfs -text
*.blend filter=lfs diff=lfs merge=lfs -text

# Textures and images
*.png filter=lfs diff=lfs merge=lfs -text
*.jpg filter=lfs diff=lfs merge=lfs -text
*.jpeg filter=lfs diff=lfs merge=lfs -text
*.svg filter=lfs diff=lfs merge=lfs -text
*.tga filter=lfs diff=lfs merge=lfs -text
*.webp filter=lfs diff=lfs merge=lfs -text

# Audio assets
*.wav filter=lfs diff=lfs merge=lfs -text
*.ogg filter=lfs diff=lfs merge=lfs -text
*.mp3 filter=lfs diff=lfs merge=lfs -text

# Compiled/exported binaries
*.pck filter=lfs diff=lfs merge=lfs -text
*.zip filter=lfs diff=lfs merge=lfs -text
```


## Autoload Setup

Common autoloads for most projects:
```
# project.godot → Autoload tab
GameManager    → res://scripts/core/game_manager.gd
AudioManager   → res://scripts/core/audio_manager.gd
SaveManager    → res://scripts/core/save_manager.gd
SignalBus      → res://scripts/core/signal_bus.gd
```

### Signal Bus Pattern
```gdscript
# signal_bus.gd — Autoload singleton
extends Node

signal player_died
signal score_changed(new_score: int)
signal level_completed(level_id: int)
signal game_paused(is_paused: bool)
```

## Input Map Setup

Configure input actions early in project settings:
```
# project.godot → Input Map
move_up     → W, Up Arrow, Left Stick Up
move_down   → S, Down Arrow, Left Stick Down
move_left   → A, Left Arrow, Left Stick Left
move_right  → D, Right Arrow, Left Stick Right
jump        → Space, Gamepad A
attack      → Left Click, Gamepad X
interact    → E, Gamepad Y
pause       → Escape, Start
```

## Verification Checklist
- [ ] Project.godot created with correct renderer
- [ ] Window size and stretch mode configured
- [ ] Folder structure created
- [ ] .gitignore set up
- [ ] Core autoloads registered
- [ ] Input map defined for all actions
- [ ] First scene (main menu or test level) created
