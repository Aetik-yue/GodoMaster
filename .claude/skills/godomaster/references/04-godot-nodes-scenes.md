---
name: godot-nodes-scenes
description: "Design and organize Godot node trees and scene architecture. Use when planning scene structure, choosing node types, composing scenes from sub-scenes, managing scene lifecycle, or implementing component patterns."
triggers:
  - "node"
  - "scene"
  - "scene tree"
  - "node hierarchy"
  - "composition"
  - "scene architecture"
  - "component"
  - "node type"
  - "add child"
---

# Godot Nodes & Scenes

Design robust scene architectures using Godot's node-based composition system.

## Node Type Reference

### 2D Nodes
| Node | Purpose |
|------|---------|
| **Node2D** | Base 2D transform node |
| **Sprite2D** | Display a texture |
| **AnimatedSprite2D** | Sprite sheet / frame animation |
| **TileMapLayer** | Tile-based level design |
| **Camera2D** | 2D viewport camera |
| **Path2D** | Define a curve path |
| **PathFollow2D** | Move along Path2D |
| **ParallaxLayer** | Parallax scrolling |
| **ParallaxBackground** | Container for parallax layers |

### 3D Nodes
| Node | Purpose |
|------|---------|
| **Node3D** | Base 3D transform node |
| **MeshInstance3D** | Display a 3D mesh |
| **Camera3D** | 3D viewport camera |
| **DirectionalLight3D** | Sun / directional light |
| **OmniLight3D** | Point light |
| **SpotLight3D** | Spot/cone light |
| **WorldEnvironment** | Environment settings |
| **NavigationRegion3D** | Navigation mesh |
| **GPUParticles3D** | 3D particle system |

### Physics Nodes
| Node | Purpose |
|------|---------|
| **CharacterBody2D/3D** | Player/NPC movement |
| **RigidBody2D/3D** | Physics-driven body |
| **StaticBody2D/3D** | Immovable collider |
| **AnimatableBody2D/3D** | Moving platform |
| **Area2D/3D** | Detection zones |
| **CollisionShape2D/3D** | Define collision shape |
| **CollisionPolygon2D/3D** | Complex collision shape |
| **Joint2D/3D** | Connect physics bodies |

### UI (Control) Nodes
| Node | Purpose |
|------|---------|
| **Control** | Base UI node |
| **Label** | Display text |
| **Button** | Clickable button |
| **TextureRect** | Display texture in UI |
| **Panel** | Background container |
| **VBoxContainer** | Vertical layout |
| **HBoxContainer** | Horizontal layout |
| **GridContainer** | Grid layout |
| **MarginContainer** | Add margins |
| **ScrollContainer** | Scrollable area |
| **TabContainer** | Tabbed interface |
| **ProgressBar** | Loading / health bar |
| **TextEdit** | Multi-line text input |
| **LineEdit** | Single-line text input |
| **RichTextLabel** | Formatted text |
| **SubViewport** | Render to texture |
| **SubViewportContainer** | Display SubViewport |

### Utility Nodes
| Node | Purpose |
|------|---------|
| **Timer** | Countdown / interval |
| **Tween** | Property animation |
| **AnimationPlayer** | Keyframe animation |
| **AnimationTree** | Blend animations |
| **AudioStreamPlayer** | 2D audio |
| **AudioStreamPlayer2D** | Positional 2D audio |
| **AudioStreamPlayer3D** | Positional 3D audio |
| **CanvasLayer** | Separate rendering layer |
| **RemoteTransform2D/3D** | Copy transform to another node |
| **BoneAttachment3D** | Attach to skeleton bone |

## Scene Composition Patterns

### Player Scene
```
Player (CharacterBody2D)
├── CollisionShape2D
├── Sprite2D (or AnimatedSprite2D)
├── AnimationPlayer
├── Camera2D
├── Hitbox (Area2D)
│   └── CollisionShape2D
├── Hurtbox (Area2D)
│   └── CollisionShape2D
└── AudioStreamPlayer2D
```

### Enemy Scene
```
Enemy (CharacterBody2D)
├── CollisionShape2D
├── Sprite2D
├── AnimationPlayer
├── NavigationAgent2D
├── DetectionArea (Area2D)
│   └── CollisionShape2D
├── Hitbox (Area2D)
│   └── CollisionShape2D
└── StateMachine
    ├── IdleState
    ├── PatrolState
    ├── ChaseState
    └── AttackState
```

### UI Scene
```
HUD (CanvasLayer)
├── MarginContainer
│   ├── TopBar (HBoxContainer)
│   │   ├── ScoreLabel
│   │   └── TimerLabel
│   ├── LeftPanel (VBoxContainer)
│   │   ├── HealthBar
│   │   └── ManaBar
│   └── BottomBar (HBoxContainer)
│       ├── HotbarSlot1
│       ├── HotbarSlot2
│       └── HotbarSlot3
└── PauseMenu (Panel) [hidden by default]
```

### Level Scene
```
Level1 (Node2D)
├── TileMapLayer (terrain)
├── TileMapLayer (decorations)
├── Player (instanced)
├── Enemies
│   ├── Enemy1 (instanced)
│   └── Enemy2 (instanced)
├── Pickups
│   ├── Coin1 (instanced)
│   └── HealthPack1 (instanced)
├── Triggers
│   ├── Checkpoint (Area2D)
│   └── LevelEnd (Area2D)
├── ParallaxBackground
└── WorldBoundary (StaticBody2D)
```

## Scene Lifecycle

### Node Lifecycle Order
```
1. _init()          — Called when object is created (before scene tree)
2. _enter_tree()    — Node enters the scene tree
3. _ready()         — All children are ready (bottom-up)
4. _process()       — Every frame (after _ready)
5. _physics_process() — Every physics tick
6. _exit_tree()     — Node leaves the scene tree
7. _notification()  — Engine notifications
```

### Key Lifecycle Tips
- `_ready()` is called bottom-up: children before parents
- Use `@onready` for node references — guaranteed to work in `_ready`
- `_init()` runs before the node is in the tree — no `$Child` access
- `await ready` if you need to wait for a node from outside

### Adding/Removing Nodes
```gdscript
# Add child
var enemy = enemy_scene.instantiate()
add_child(enemy)
enemy.global_position = spawn_point

# Remove child
enemy.queue_free()  # Safe removal at end of frame

# Reparent
old_parent.remove_child(node)
new_parent.add_child(node)

# Check if child exists
if has_node("Enemy"):
    $Enemy.take_damage(10)
```

## Component Pattern

### Health Component
```gdscript
# health_component.gd
class_name HealthComponent
extends Node

signal died
signal health_changed(current: int, max_health: int)

@export var max_health := 100
var current_health: int

func _ready() -> void:
    current_health = max_health

func take_damage(amount: int) -> void:
    current_health = clampi(current_health - amount, 0, max_health)
    health_changed.emit(current_health, max_health)
    if current_health <= 0:
        died.emit()

func heal(amount: int) -> void:
    current_health = clampi(current_health + amount, 0, max_health)
    health_changed.emit(current_health, max_health)
```

### Hitbox/Hurtbox Pattern
```gdscript
# hitbox.gd
class_name Hitbox
extends Area2D

@export var damage := 10

# hurtbox.gd
class_name Hurtbox
extends Area2D

signal hurt(damage: int)

func _ready() -> void:
    area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
    if area is Hitbox:
        hurt.emit(area.damage)
```

### Movement Component
```gdscript
# movement_component.gd
class_name MovementComponent
extends Node

@export var speed := 200.0
@export var acceleration := 10.0
@export var friction := 8.0

var velocity := Vector2.ZERO

func calculate_velocity(direction: Vector2, delta: float) -> Vector2:
    if direction != Vector2.ZERO:
        velocity = velocity.lerp(direction * speed, acceleration * delta)
    else:
        velocity = velocity.lerp(Vector2.ZERO, friction * delta)
    return velocity
```

## Scene Instancing vs Inheritance

### When to Instance
- Reusable entities: player, enemies, pickups
- UI components: health bar, dialog box
- Level elements: doors, switches, platforms

### When to Use Inheritance (class_name)
- Base classes for common behavior: `class_name Enemy`
- Utility classes: `class_name StateMachine`
- Data classes: `class_name ItemData extends Resource`

### Scene Organization Rules
1. **One primary entity per scene** — Player scene = player logic only
2. **Instance, don't copy** — always use scene instances
3. **Group for queries** — `add_to_group("enemies")` for batch operations
4. **Signals for communication** — never reach into another scene's children directly
5. **Composition over deep inheritance** — use components as child nodes

## Verification Checklist
- [ ] Scene tree is shallow (max 4-5 levels deep)
- [ ] Reusable entities are separate scenes
- [ ] Communication uses signals, not direct references
- [ ] Components are attached as child nodes
- [ ] Groups are used for batch queries
- [ ] Lifecycle order is respected (_ready before _process)
