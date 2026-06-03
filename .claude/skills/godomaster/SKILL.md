---
name: godomaster
description: "GodoMaster — Godot 4.x game development intelligence: GDScript, nodes/scenes, 2D/3D rendering, physics, animation, UI, audio, input, shaders, networking, performance, export, and file I/O. Complete workflow for indie and professional game development based on official Godot documentation."
argument-hint: "[topic] [context]"
license: MIT
metadata:
  author: yanha
  version: "1.0.0"
---

# GodoMaster

Complete Godot 4.x game development skill: project setup, GDScript, scene architecture, 2D/3D, physics, animation, UI, audio, input, shaders, networking, performance, export, and data persistence.

## When to Use

This Skill should be used when the task involves **Godot game development** — writing GDScript, designing scenes, implementing gameplay systems, debugging, or optimizing.

### Must Use

This Skill must be invoked in the following situations:

- Creating or configuring a Godot project (renderer, settings, folder structure)
- Writing, reviewing, or debugging GDScript code
- Designing node hierarchies and scene composition
- Implementing 2D or 3D gameplay (sprites, tilemaps, meshes, cameras)
- Setting up physics (collisions, rigid bodies, raycasting)
- Creating animations (AnimationPlayer, Tween, AnimationTree)
- Building UI (menus, HUD, dialogs, themes)
- Adding audio (music, SFX, spatial audio, audio buses)
- Handling input (keyboard, mouse, gamepad, touch, remapping)
- Writing shaders (2D effects, 3D materials, post-processing)
- Implementing multiplayer/networking
- Exporting to platforms (Windows, Mac, Linux, Web, Mobile)
- Optimizing performance (profiling, draw calls, memory)
- Implementing save/load and file I/O

## Sub-skill Routing

| Task | Reference | Details |
|------|-----------|---------|
| New project, renderer, .gitignore | `references/01-godot-project-setup.md` | Project creation, folder structure, autoloads |
| Editor navigation, debug tools | `references/02-godot-editor-mastery.md` | Shortcuts, panels, profiler, remote tree |
| GDScript code, patterns, types | `references/03-gdscript-pro.md` | Type system, signals, movement, state machine |
| Scene tree, node types, composition | `references/04-godot-nodes-scenes.md` | Node reference, lifecycle, component pattern |
| Sprites, tilemaps, 2D lighting | `references/05-godot-2d-fundamentals.md` | AnimatedSprite, TileMapLayer, parallax, camera |
| 3D models, materials, environment | `references/06-godot-3d-fundamentals.md` | Import, PBR, lighting, sky, fog, navigation |
| Collision, physics bodies, raycast | `references/07-godot-physics.md` | CharacterBody, RigidBody, Area, joints |
| Animation, tweens, state machines | `references/08-godot-animation.md` | AnimationPlayer, Tween, AnimationTree |
| Menus, HUD, themes, layouts | `references/09-godot-ui-design.md` | Control nodes, anchors, dialog system |
| Music, SFX, audio buses | `references/10-godot-audio.md` | AudioStreamPlayer, effects, spatial audio |
| Input mapping, gamepad, touch | `references/11-godot-input-system.md` | Input actions, remapping, virtual joystick |
| Export, CI/CD, store publishing | `references/12-godot-export-deploy.md` | Platform presets, optimization, distribution |
| Profiling, FPS, draw calls | `references/13-godot-performance.md` | Monitors, batching, pooling, culling |
| Save/load, JSON, config files | `references/14-godot-file-io.md` | SaveManager, ConfigFile, encryption |
| Shaders, visual effects | `references/15-godot-shaders.md` | CanvasItem, Spatial, post-processing |
| Multiplayer, RPC, sync | `references/16-godot-networking.md` | ENet, lobby, state synchronization |

## Quick Reference

### GDScript Essentials

```gdscript
# File structure
extends CharacterBody2D
class_name Player

const SPEED := 300.0
signal health_changed(new_health: int)

@export var max_health := 100
@export_range(0, 100) var start_health := 100

@onready var sprite := $Sprite2D
@onready var animation := $AnimationPlayer

var health: int
var velocity := Vector2.ZERO

func _ready() -> void:
    health = start_health

func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity.y += gravity * delta
    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = jump_velocity
    var direction := Input.get_axis("move_left", "move_right")
    velocity.x = direction * speed
    move_and_slide()
```

### Scene Composition Patterns

```
Player (CharacterBody2D)
├── CollisionShape2D
├── Sprite2D / AnimatedSprite2D
├── AnimationPlayer
├── Camera2D
├── Hitbox (Area2D) → CollisionShape2D
├── Hurtbox (Area2D) → CollisionShape2D
└── AudioStreamPlayer2D

Enemy (CharacterBody2D)
├── CollisionShape2D
├── Sprite2D
├── AnimationPlayer
├── NavigationAgent2D
├── DetectionArea (Area2D) → CollisionShape2D
└── StateMachine → IdleState, ChaseState, AttackState

HUD (CanvasLayer)
├── MarginContainer
│   ├── TopBar (HBoxContainer) → ScoreLabel, TimerLabel
│   ├── HealthBar (TextureProgressBar)
│   └── BottomBar (HBoxContainer) → HotbarSlots
```

### Node Lifecycle Order

```
_init()           → Object created (before tree)
_enter_tree()     → Enters scene tree
_ready()          → All children ready (bottom-up)
_process()        → Every frame
_physics_process()→ Every physics tick
_exit_tree()      → Leaves scene tree
```

### Collision Layers

```
Layer 1: Player    Mask: 2,3,4
Layer 2: Walls     Mask: (none)
Layer 3: Enemies   Mask: 1,2
Layer 4: Pickups   Mask: 1
Layer 5: Proj(PLY) Mask: 2,3
Layer 6: Proj(ENM) Mask: 1,2
```

### Common Autoloads

```
GameManager  → res://scripts/core/game_manager.gd
AudioManager → res://scripts/core/audio_manager.gd
SaveManager  → res://scripts/core/save_manager.gd
SignalBus    → res://scripts/core/signal_bus.gd
```

### Project Folder Structure

```
project/
├── scenes/  (world/, ui/, actors/, effects/)
├── scripts/ (core/, systems/, components/, ui/)
├── resources/ (data/, themes/, materials/)
├── art/ (sprites/, tiles/, audio/, vfx/)
└── addons/
```

### Renderer Selection

| Renderer | Best For |
|----------|----------|
| **Forward+** | Desktop, high-end visuals |
| **Mobile** | Mid-range, balanced |
| **Compatibility** | Low-end, web, old hardware |

### Input Actions (configure early)

```
move_up/down/left/right → WASD + Left Stick
jump → Space / Gamepad A
attack → Left Click / Gamepad X
interact → E / Gamepad Y
pause → Escape / Start
```

## References

| Topic | File |
|-------|------|
| Project Setup | `references/01-godot-project-setup.md` |
| Editor Guide | `references/02-godot-editor-mastery.md` |
| GDScript Reference | `references/03-gdscript-pro.md` |
| Nodes & Scenes | `references/04-godot-nodes-scenes.md` |
| 2D Workflow | `references/05-godot-2d-fundamentals.md` |
| 3D Workflow | `references/06-godot-3d-fundamentals.md` |
| Physics | `references/07-godot-physics.md` |
| Animation | `references/08-godot-animation.md` |
| UI Design | `references/09-godot-ui-design.md` |
| Audio | `references/10-godot-audio.md` |
| Input System | `references/11-godot-input-system.md` |
| Export & Deploy | `references/12-godot-export-deploy.md` |
| Performance | `references/13-godot-performance.md` |
| File I/O | `references/14-godot-file-io.md` |
| Shaders | `references/15-godot-shaders.md` |
| Networking | `references/16-godot-networking.md` |
