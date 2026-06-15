---
name: gdscript-pro
description: "Write, debug, and optimize GDScript code for Godot 4.x. Use when writing game logic, scripting nodes, implementing systems, fixing GDScript errors, or learning GDScript patterns and best practices."
triggers:
  - "gdscript"
  - "script"
  - "gd code"
  - "write code"
  - "function"
  - "class"
  - "signal"
  - "export"
  - "typing"
  - "gdscript error"
---

# GDScript Pro

Write production-quality GDScript for Godot 4.x.

## Language Fundamentals

### File Structure
```gdscript
# Constants
const SPEED := 300.0
const JUMP_VELOCITY := -400.0

# Signals
signal health_changed(new_health: int)
signal died

# Exports
@export var max_health := 100
@export_range(0, 100) var start_health := 100
@export var sprite_texture: Texture2D

# Variables
var health: int
var velocity := Vector2.ZERO
var is_alive := true

# Onready
@onready var sprite := $Sprite2D
@onready var collision := $CollisionShape2D
@onready var animation := $AnimationPlayer

# Lifecycle
func _ready() -> void:
    health = start_health

func _process(delta: float) -> void:
    pass

func _physics_process(delta: float) -> void:
    pass

# Methods
func take_damage(amount: int) -> void:
    health = clampi(health - amount, 0, max_health)
    health_changed.emit(health)
    if health <= 0:
        die()
```

### Type System
```gdscript
# Static typing (recommended)
var health: int = 100
var position: Vector2 = Vector2.ZERO
var name: String = "Player"
var is_active: bool = true

# Inferred types
var speed := 300.0          # float
var direction := Vector2.UP # Vector2
var label := $Label          # Label (inferred from scene)

# Typed arrays
var enemies: Array[Node2D] = []
var scores: Array[int] = [10, 20, 30]

# Typed dictionaries
var inventory: Dictionary[String, int] = {}

# Nested typed dictionaries (4.4+)
var stats: Dictionary[String, Dictionary] = {}
var lookup: Dictionary[String, Array[int]] = {}

# StringName literals — use & for signal/property keys (performance)
signal_name = &"health_changed"
prop_name = &"position"

# Nullable types
var target: Node2D = null
var target_ref: Node2D  # non-nullable, must assign before use
```

### @export Variants
```gdscript
# Basic exports
@export var speed: float = 100.0
@export var health: int = 10
@export var name: String = "Enemy"

# Ranged exports
@export_range(0, 100) var volume: int = 50
@export_range(0.0, 1.0, 0.05) var opacity: float = 1.0
@export_range(1, 10, 1, "or_greater") var max_jumps: int = 1

# Enum exports
enum State { IDLE, WALK, RUN, JUMP }
@export var current_state: State = State.IDLE

# Resource exports
@export var texture: Texture2D
@export var sound: AudioStream
@export var scene: PackedScene

# Grouped exports
@export_group("Movement")
@export var move_speed: float = 200.0
@export var acceleration: float = 10.0

@export_group("Combat")
@export var damage: int = 10
@export var attack_range: float = 50.0

# Export storage — serialized but hidden from Inspector (4.4+)
@export_storage var internal_state: int = 0

# Custom export hints (4.4+)
@export_custom(PROPERTY_HINT_RANGE, "0,100,1") var custom_value: int = 50
```

### Warning Control (4.4+)
```gdscript
# Suppress specific GDScript warnings when justified
@warning_ignore("shadowed_variable")
@warning_ignore("unused_parameter")
@warning_ignore("return_value_discarded")
func _process(_delta: float) -> void:
    pass

# Per-function or per-statement suppression
@warning_ignore("integer_division")
var result := 10 / 3
```

## Signals

### Defining and Emitting
```gdscript
# Define
signal player_died
signal score_changed(new_score: int)
signal item_picked_up(item: Resource)

# Emit
player_died.emit()
score_changed.emit(42)
item_picked_up.emit(current_item)
```

### Connecting
```gdscript
# In code
signal_name.connect(_on_signal_name)

# With parameters
enemy.health_changed.connect(_on_enemy_health_changed)

# One-shot connection
signal_name.connect(_on_signal, CONNECT_ONE_SHOT)

# Deferred connection (call on next idle frame)
signal_name.connect(_on_signal, CONNECT_DEFERRED)
```

### Callable Patterns
```gdscript
# Lambda
button.pressed.connect(func(): print("clicked"))

# Multi-statement lambda (4.4+)
button.pressed.connect(func():
    print("step 1")
    print("step 2")
)

# With bind
enemy.died.connect(_on_enemy_died.bind(enemy))

# Method reference
var callback := Callable(self, "_on_callback")
```

### Static Methods and Variables
```gdscript
class_name MathUtils
extends RefCounted

# Static method — callable without an instance
static func clamp_angle(angle: float, min_angle: float, max_angle: float) -> float:
    return fposmod(clampf(angle, min_angle, max_angle), TAU)

# Static variable — shared across all instances (4.4+)
static var instance_count: int = 0

func _init() -> void:
    instance_count += 1

# Factory pattern
static func create_with_stats(hp: int, dmg: int) -> CharacterStats:
    var stats := CharacterStats.new()
    stats.max_health = hp
    stats.damage = dmg
    return stats
```

## Node Access

```gdscript
# Dollar sign (relative path)
@onready var sprite := $Sprite2D
@onready var health_bar := $UI/HealthBar

# Absolute path (from root)
@onready var game_manager := /root/GameManager

# Group access
var enemies := get_tree().get_nodes_in_group("enemies")
var player := get_tree().get_first_node_in_group("player")

# Null-safe access
var target := get_node_or_null("Target")
if target:
    target.take_damage(10)

# Find children
var bullets := find_children("*", "Bullet", true, false)
```

## Movement Patterns

### CharacterBody2D Movement
```gdscript
extends CharacterBody2D

@export var speed := 300.0
@export var jump_velocity := -400.0
@export var gravity_multiplier := 2.5

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta: float) -> void:
    # Gravity
    if not is_on_floor():
        velocity.y += gravity * gravity_multiplier * delta

    # Jump
    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = jump_velocity

    # Horizontal movement
    var direction := Input.get_axis("move_left", "move_right")
    velocity.x = direction * speed

    move_and_slide()
```

### RigidBody2D Movement
```gdscript
extends RigidBody2D

@export var move_force := 500.0
@export var max_speed := 300.0

func _physics_process(delta: float) -> void:
    var direction := Input.get_axis("move_left", "move_right")

    if direction != 0:
        apply_force(Vector2(direction * move_force, 0))

    # Clamp velocity
    if linear_velocity.length() > max_speed:
        linear_velocity = linear_velocity.normalized() * max_speed
```

### CharacterBody3D Movement
```gdscript
extends CharacterBody3D

@export var speed := 5.0
@export var jump_velocity := 4.5
@export var mouse_sensitivity := 0.002

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        rotate_y(-event.relative.x * mouse_sensitivity)
        $Camera3D.rotate_x(-event.relative.y * mouse_sensitivity)
        $Camera3D.rotation.x = clampf($Camera3D.rotation.x, -1.2, 1.2)

func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity.y -= gravity * delta

    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = jump_velocity

    var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

    velocity.x = direction.x * speed
    velocity.z = direction.z * speed

    move_and_slide()
```

## Common Patterns

### State Machine
```gdscript
# state_machine.gd
class_name StateMachine
extends Node

signal state_changed(old_state: String, new_state: String)

@export var initial_state: State
var current_state: State
var states: Dictionary = {}

func _ready() -> void:
    for child in get_children():
        if child is State:
            states[child.name.to_lower()] = child
            child.state_machine = self

    if initial_state:
        current_state = initial_state
        current_state.enter()

func _process(delta: float) -> void:
    if current_state:
        current_state.update(delta)

func _physics_process(delta: float) -> void:
    if current_state:
        current_state.physics_update(delta)

func transition_to(new_state_name: String) -> void:
    var new_state := states.get(new_state_name.to_lower())
    if not new_state or new_state == current_state:
        return

    var old_state := current_state
    current_state.exit()
    current_state = new_state
    current_state.enter()
    state_changed.emit(old_state.name, new_state.name)

# state.gd (base class)
class_name State
extends Node

var state_machine: StateMachine

func enter() -> void:
    pass

func exit() -> void:
    pass

func update(_delta: float) -> void:
    pass

func physics_update(_delta: float) -> void:
    pass
```

### Object Pooling
```gdscript
class_name ObjectPool
extends Node

@export var pool_scene: PackedScene
@export var pool_size := 20

var pool: Array[Node] = []

func _ready() -> void:
    for i in pool_size:
        var obj := pool_scene.instantiate()
        obj.visible = false
        obj.process_mode = Node.PROCESS_MODE_DISABLED
        add_child(obj)
        pool.append(obj)

func get_object() -> Node:
    for obj in pool:
        if not obj.visible:
            obj.visible = true
            obj.process_mode = Node.PROCESS_MODE_INHERIT
            return obj
    # Pool exhausted, create new
    var obj := pool_scene.instantiate()
    add_child(obj)
    pool.append(obj)
    return obj

func return_object(obj: Node) -> void:
    obj.visible = false
    obj.process_mode = Node.PROCESS_MODE_DISABLED
```

### Timer Patterns
```gdscript
# One-shot timer
func start_cooldown(duration: float) -> void:
    await get_tree().create_timer(duration).timeout
    # Code after cooldown

# Repeating timer
@onready var timer := $Timer

func _ready() -> void:
    timer.wait_time = 1.0
    timer.timeout.connect(_on_timer_timeout)
    timer.start()

func _on_timer_timeout() -> void:
    print("Tick every second")

# Tween animation
func fade_out(node: CanvasItem, duration: float = 0.5) -> void:
    var tween := create_tween()
    tween.tween_property(node, "modulate:a", 0.0, duration)
    await tween.finished
    node.visible = false
```

### Await Patterns (4.4+)
```gdscript
# Await with typed signal parameters
signal data_loaded(data: Dictionary)
var result := await data_loaded
# result is typed as Dictionary

# Safe await with timeout
func await_with_timeout(signal_ref: Signal, timeout: float = 5.0) -> Variant:
    var results := await signal_ref or get_tree().create_timer(timeout).timeout
    return results[0] if results else null

# Race pattern — first signal to fire wins
func wait_for_any(signals: Array[Signal]) -> void:
    for sig in signals:
        sig.connect(func(): _race_won = true, CONNECT_ONE_SHOT)
    while not _race_won:
        await get_tree().process_frame
```

### Dependency Injection (DI)
Decouple classes from their dependencies by passing dependencies in during initialization or setup.

```gdscript
# constructor injection
class_name PlayerController
extends CharacterBody2D

var _input_handler: InputHandler
var _stats: PlayerStats

# Inject dependencies via a setup/initialize method
func setup(input_handler: InputHandler, stats: PlayerStats) -> void:
    _input_handler = input_handler
    _stats = stats
```

### Service Locator
A registry singleton that allows systems to register themselves and others to query them without hard references.

```gdscript
# res://scripts/core/service_locator.gd (Autoload)
extends Node

var _services: Dictionary[String, Variant] = {}

func register_service(name: String, service: Variant) -> void:
    _services[name] = service

func get_service(name: String) -> Variant:
    if _services.has(name):
        return _services[name]
    push_error("Service not found: ", name)
    return null

func unregister_service(name: String) -> void:
    _services.erase(name)
```

### Event Bus (Signal Bus)
Avoid tight coupling between distant nodes by using a centralized event bus for global events.

```gdscript
# res://scripts/core/event_bus.gd (Autoload)
extends Node

signal player_spawned(player: Player)
signal score_updated(new_score: int)
signal quest_completed(quest_id: String)
signal game_saved
```

To use the Event Bus:
```gdscript
# In Player.gd:
func _ready() -> void:
    EventBus.player_spawned.emit(self)

# In HUD.gd:
func _ready() -> void:
    EventBus.score_updated.connect(_on_score_updated)
```

```

## Best Practices

1. **Always use static typing** — catches errors early, better autocomplete
2. **Use `@onready`** for node references — ensures tree is loaded
3. **Prefer signals over direct calls** — loose coupling between systems
4. **Use `class_name`** for reusable classes — enables type checking
5. **Keep scripts focused** — one responsibility per script
6. **Use `@export` for designer values** — tune without code changes
7. **Null-check before accessing** — use `is_instance_valid()` or `if node:`
8. **Avoid `_process` when possible** — use `_physics_process` for game logic
9. **Use `await` carefully** — can cause issues if node is freed during await
10. **Group related nodes** — `add_to_group("enemies")` for easy queries
11. **Use `StringName` (`&"literal"`)** for signal/property keys — faster than String
12. **Prefer `@export_storage`** for data that needs serialization but not editor exposure
13. **Use `@warning_ignore` sparingly** — fix the root cause first

## Common Errors and Fixes

| Error | Cause | Fix |
|-------|-------|-----|
| `Invalid call. Nonexistent function` | Method doesn't exist on type | Check spelling, check node type |
| `Invalid get index` | Accessing property on null | Add null check, verify `@onready` |
| `Expected ":" after signal name` | Missing colon in signal def | Add `:` after parameters |
| `Cannot assign to const` | Modifying a constant | Use `var` instead |
| `Node not found` | Wrong path in `$Path` | Check scene tree, use absolute path |
| `Condition "!is_inside_tree()"` | Accessing tree before `_ready` | Use `@onready` or wait for `_ready` |
