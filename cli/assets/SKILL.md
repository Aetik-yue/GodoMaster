---
name: godomaster
description: "GodoMaster — Godot 4.x game development intelligence: GDScript, nodes/scenes, 2D/3D rendering, physics, animation, UI, audio, input, shaders, networking, performance, export, file I/O, testing, localization, AI behavior, asset pipeline, and architecture tooling. Complete workflow for indie and professional game development based on official Godot documentation."
argument-hint: "[topic] [context]"
license: MIT
metadata:
  author: yanha
  version: "2.0.0"
---

# GodoMaster

Complete Godot 4.x game development skill: project setup, GDScript, scene architecture, 2D/3D, physics, animation, UI, audio, input, shaders, networking, performance, export, data persistence, localization, AI behavior, and asset pipeline.

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
- Implementing localization or multi-language support (tr(), TranslationServer)
- Building AI behavior systems (state machines, behavior trees, utility AI)
- Working with the asset import pipeline (ResourceImporter, EditorImportPlugin, addons)
- Creating GDExtension modules (C++ integration, godot-cpp)

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
| Shaders, visual effects | `references/15-godot-shaders.md` | CanvasItem, Spatial, fog, post-processing |
| Multiplayer, RPC, sync | `references/16-godot-networking.md` | ENet, WebSocket, WebRTC, lobby, matchmaking |
| Unit tests, integration tests, CI | `references/17-godot-testing.md` | GdUnit4, mocking, scene tests, headless CLI |
| Custom Resources, @tool, plugins, GDExtension | `references/18-godot-architecture-tooling.md` | Resource-based architecture, @tool, GDExtension, EditorPlugin |
| Localization, tr(), TranslationServer | `references/19-godot-localization.md` | .po/.csv import, plural rules, pseudolocalization, RTL |
| AI, behavior trees, utility AI | `references/20-godot-ai-behavior.md` | State machines, BT pattern, navigation AI, LimboAI |
| Asset pipeline, import plugins, addons | `references/21-godot-asset-pipeline.md` | ResourceImporter, EditorImportPlugin, AssetLib distribution |

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
@export_storage var internal_state: int = 0  # 4.4+ serialized but hidden

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

### Localization Quick Pattern

```gdscript
# Localization
func _ready() -> void:
    label.text = tr("KEY_GREETING")
    count_label.text = tr_n("1 enemy", "%d enemies", count) % count
    TranslationServer.set_locale("zh_CN")
```

### AI Quick Pattern

```gdscript
# Behavior tree tick pattern
func _physics_process(delta: float) -> void:
    behavior_tree.tick(self, blackboard)

# NavigationAgent avoidance (4.4+)
nav_agent.avoidance_enabled = true
nav_agent.set_velocity(desired_velocity)
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
