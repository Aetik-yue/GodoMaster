---
name: godot-animation
description: "Create animations using AnimationPlayer, Tween, AnimationTree, and procedural methods. Use when animating sprites, properties, UI elements, cutscenes, character animations, or state machine blending."
triggers:
  - "animation"
  - "tween"
  - "animation player"
  - "animation tree"
  - "keyframe"
  - "sprite animation"
  - "cutscene"
  - "blend"
  - "skeleton"
---

# Godot Animation

Create all types of animations for gameplay, UI, and cutscenes.

## AnimationPlayer

### Keyframe Animation
```gdscript
@onready var anim := $AnimationPlayer

# Play animation
anim.play("walk")
anim.play("attack", 0.2)  # with 0.2s crossfade
anim.play_backwards("open_door")

# Queue animations
anim.queue("idle")

# Check
if anim.current_animation == "attack":
    pass

# Speed
anim.speed_scale = 1.5  # 1.5x speed
anim.speed_scale = -1.0  # reverse (with play_backwards)

# Signals
anim.animation_finished.connect(_on_anim_finished)
anim.animation_started.connect(_on_anim_started)
```

### Creating Animations in Editor
1. Add AnimationPlayer node
2. Click "Animation" → "New"
3. Name the animation (e.g., "idle", "walk", "attack")
4. Select node → click "key" icon next to property
5. Move timeline, change property, key again
6. Set loop mode: Loop, Ping-Pong, or None

### Property Tracks
```
Available tracks:
- Transform (position, rotation, scale)
- Sprite (frame, texture, offset)
- Modulate (color, alpha)
- Visibility (show/hide)
- Audio (play sound at frame)
- Method (call function at frame)
- Bezier (custom curve)
- Value (any property)
```

### Call Method Track
```gdscript
# In AnimationPlayer editor:
# 1. Add Call Method Track
# 2. Select the target node
# 3. Insert key at desired frame
# 4. Choose method to call

# Example: spawn hitbox during attack animation
func enable_hitbox() -> void:
    $Hitbox/CollisionShape2D.disabled = false

func disable_hitbox() -> void:
    $Hitbox/CollisionShape2D.disabled = true
```

## Tween

### Basic Tween
```gdscript
# Simple property tween
var tween := create_tween()
tween.tween_property($Sprite2D, "position:x", 200.0, 1.0)
tween.tween_property($Sprite2D, "modulate:a", 0.0, 0.5)
```

### Tween Chain
```gdscript
var tween := create_tween()
tween.tween_property(self, "position", Vector2(100, 0), 0.5)
tween.tween_property(self, "position", Vector2(100, 200), 0.5)
tween.tween_property(self, "position", Vector2(0, 200), 0.5)
tween.tween_property(self, "position", Vector2(0, 0), 0.5)
```

### Tween Parallel
```gdscript
var tween := create_tween()
tween.set_parallel(true)  # all tweens run at once
tween.tween_property($Sprite, "position:x", 200, 1.0)
tween.tween_property($Sprite, "modulate:a", 0.0, 1.0)
tween.tween_property($Sprite, "scale", Vector2(2, 2), 1.0)
```

### Tween Easing
```gdscript
var tween := create_tween()
tween.tween_property($Sprite, "position:x", 200, 1.0)\
    .set_ease(Tween.EASE_IN_OUT)\
    .set_trans(Tween.TRANS_ELASTIC)

# Easing types:
# EASE_IN — slow start, fast end
# EASE_OUT — fast start, slow end
# EASE_IN_OUT — slow start and end
# EASE_OUT_IN — fast start and end

# Transition types:
# TRANS_LINEAR — constant speed
# TRANS_SINE — smooth sine curve
# TRANS_QUAD — quadratic acceleration
# TRANS_CUBIC — cubic acceleration
# TRANS_ELASTIC — bouncy
# TRANS_BOUNCE — bouncing ball
# TRANS_BACK — overshoot then settle
```

### Tween Loops
```gdscript
# Loop
var tween := create_tween()
tween.set_loops(5)  # loop 5 times (0 = infinite)
tween.tween_property($Sprite, "modulate:a", 0.0, 0.5)
tween.tween_property($Sprite, "modulate:a", 1.0, 0.5)

# Ping-pong
var tween := create_tween()
tween.set_loops()
tween.tween_property($Sprite, "position:y", -10, 0.5).as_relative()
tween.tween_property($Sprite, "position:y", 10, 0.5).as_relative()
```

### Tween Callbacks
```gdscript
var tween := create_tween()
tween.tween_property($Sprite, "position:x", 200, 1.0)
tween.tween_callback(func(): print("Movement complete"))
tween.tween_callback(_on_movement_done)

# Interval
var tween := create_tween()
tween.tween_interval(1.0)  # wait 1 second
tween.tween_property($Sprite, "modulate:a", 0.0, 0.5)
```

### Tween from Value
```gdscript
# Animate from specific start value
var tween := create_tween()
tween.tween_property($Sprite, "position", Vector2(200, 0), 1.0).from(Vector2(0, 0))

# Animate from current value
tween.tween_property($Sprite, "position", Vector2(200, 0), 1.0).from_current()
```

## AnimationTree

### State Machine Setup
```
AnimationTree
├── Tree Root: AnimationNodeStateMachine
│   ├── "idle" (AnimationNodeAnimation)
│   ├── "walk" (AnimationNodeAnimation)
│   ├── "run" (AnimationNodeAnimation)
│   ├── "jump" (AnimationNodeAnimation)
│   └── "attack" (AnimationNodeAnimation)
└── Transitions:
    idle → walk (Auto, based on condition)
    walk → idle (Auto)
    walk → run (Auto)
    idle → jump (Auto)
    any → attack (Auto)
```

### AnimationTree in Code
```gdscript
extends CharacterBody2D

@onready var anim_tree := $AnimationTree
@onready var state_machine := anim_tree.get("parameters/playback")

func _ready() -> void:
    anim_tree.active = true

func _physics_process(delta: float) -> void:
    # State machine playback
    if velocity.length() > 0:
        state_machine.travel("walk")
    else:
        state_machine.travel("idle")

    if Input.is_action_just_pressed("attack"):
        state_machine.travel("attack")

    # Blend position (for blend spaces)
    anim_tree.set("parameters/walk/blend_position", velocity.x)
```

### Blend Space
```
AnimationNodeBlendSpace2D
├── X axis: horizontal velocity (-1 to 1)
├── Y axis: vertical velocity (-1 to 1)
├── "walk_left" at (-1, 0)
├── "walk_right" at (1, 0)
├── "walk_up" at (0, -1)
├── "walk_down" at (0, 1)
└── "idle" at (0, 0)

Set blend position in code:
anim_tree.set("parameters/BlendSpace/blend_position", velocity)
```

## Procedural Animation

### Shake Effect
```gdscript
func shake(node: Node2D, intensity: float = 5.0, duration: float = 0.3) -> void:
    var original_pos := node.position
    var tween := create_tween()
    for i in int(duration / 0.03):
        var offset := Vector2(
            randf_range(-intensity, intensity),
            randf_range(-intensity, intensity)
        )
        tween.tween_property(node, "position", original_pos + offset, 0.03)
    tween.tween_property(node, "position", original_pos, 0.03)
```

### Squash & Stretch
```gdscript
func squash_stretch(node: Node2D, squash: Vector2 = Vector2(1.3, 0.7), duration: float = 0.15) -> void:
    var original := node.scale
    var tween := create_tween()
    tween.tween_property(node, "scale", squash, duration * 0.3)
    tween.tween_property(node, "scale", original * Vector2(0.9, 1.1), duration * 0.3)
    tween.tween_property(node, "scale", original, duration * 0.4)
```

### Fade In/Out
```gdscript
func fade_in(node: CanvasItem, duration: float = 0.5) -> void:
    node.modulate.a = 0.0
    node.visible = true
    var tween := create_tween()
    tween.tween_property(node, "modulate:a", 1.0, duration)

func fade_out(node: CanvasItem, duration: float = 0.5) -> void:
    var tween := create_tween()
    tween.tween_property(node, "modulate:a", 0.0, duration)
    await tween.finished
    node.visible = false
```

### Slide In/Out
```gdscript
func slide_in(node: Control, from: Vector2, duration: float = 0.3) -> void:
    var target := node.position
    node.position = from
    node.visible = true
    var tween := create_tween()
    tween.tween_property(node, "position", target, duration)\
        .set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func slide_out(node: Control, to: Vector2, duration: float = 0.3) -> void:
    var tween := create_tween()
    tween.tween_property(node, "position", to, duration)\
        .set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
    await tween.finished
    node.visible = false
```

## Cutscene System

### Simple Timeline
```gdscript
extends Node

@export var cutscene_steps: Array[CutsceneStep] = []

func play_cutscene() -> void:
    for step in cutscene_steps:
        await execute_step(step)

func execute_step(step: CutsceneStep) -> void:
    match step.type:
        "dialog":
            await show_dialog(step.text, step.speaker)
        "move":
            await move_character(step.character, step.target, step.duration)
        "wait":
            await get_tree().create_timer(step.duration).timeout
        "camera":
            await move_camera(step.position, step.duration)
        "animation":
            step.character.play(step.animation)
            await step.character.animation_finished
```

## Animation Best Practices

1. **Name animations clearly**: `idle`, `walk`, `run`, `attack`, `die`, `jump`
2. **Use AnimationPlayer for complex sequences**: keyframes, method calls, audio
3. **Use Tween for simple property changes**: fade, move, scale
4. **Use AnimationTree for state machines**: character animation states
5. **Set up transitions in editor**: easier to visualize than code
6. **Use `travel()` not `play()`** in state machines: smooth transitions
7. **Add method tracks for gameplay**: enable hitbox, spawn projectile, play SFX
8. **Loop idle and walk**: set loop mode in animation
9. **Don't loop attack/jump**: play once, return to idle
10. **Crossfade transitions**: `play("walk", 0.2)` for smooth blending

## Verification Checklist
- [ ] AnimationPlayer configured for each animated entity
- [ ] Idle, walk, attack animations created
- [ ] Tween used for UI animations
- [ ] AnimationTree for character state machines
- [ ] Method tracks for gameplay events (hitbox, SFX)
- [ ] Squash/stretch for game feel
- [ ] Transitions are smooth (crossfade)
