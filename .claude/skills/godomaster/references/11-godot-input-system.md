---
name: godot-input-system
description: "Handle player input including keyboard, mouse, gamepad, touch, and input mapping. Use when implementing controls, creating input actions, handling gestures, building remapping UI, or supporting multiple input devices."
triggers:
  - "input"
  - "keyboard"
  - "mouse"
  - "gamepad"
  - "controller"
  - "joystick"
  - "touch"
  - "input map"
  - "keybinding"
  - "remap"
---

# Godot Input System

Handle all types of player input with Godot's input action system.

## Input Actions (Input Map)

### Setup in Project Settings
```
# project.godot → Input Map

# Movement
move_up      → W, Up Arrow, Left Stick Up (gamepad)
move_down    → S, Down Arrow, Left Stick Down
move_left    → A, Left Arrow, Left Stick Left
move_right   → D, Right Arrow, Left Stick Right

# Actions
jump         → Space, Gamepad A (Xbox) / Cross (PS)
attack       → Left Click, Gamepad X / Square
interact     → E, Gamepad Y / Triangle
dash         → Shift, Gamepad B / Circle

# UI
ui_accept    → Enter, Space, Gamepad A
ui_cancel    → Escape, Backspace, Gamepad B
pause        → Escape, Start

# Special
sprint       → Left Shift (hold), Left Stick Click
```

### Reading Input
```gdscript
# Just pressed (one frame)
if Input.is_action_just_pressed("jump"):
    jump()

# Just released (one frame)
if Input.is_action_just_released("attack"):
    end_attack()

# Held down (every frame)
if Input.is_action_pressed("sprint"):
    speed = sprint_speed

# Axis (returns -1, 0, or 1)
var horizontal := Input.get_axis("move_left", "move_right")
var vertical := Input.get_axis("move_up", "move_down")

# Vector (returns normalized Vector2)
var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
```

## Raw Input (Advanced)

### Keyboard
```gdscript
func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey:
        if event.pressed and not event.echo:
            match event.keycode:
                KEY_F1:
                    toggle_debug()
                KEY_F5:
                    quick_save()
                KEY_F9:
                    quick_load()
                _:
                    print("Key pressed: ", OS.get_keycode_string(event.keycode))
```

### Mouse
```gdscript
func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
            shoot(event.position)
        elif event.button_index == MOUSE_BUTTON_RIGHT:
            if event.pressed:
                start_aim()
            else:
                stop_aim()
        elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
            zoom_in()
        elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
            zoom_out()

    if event is InputEventMouseMotion:
        look_direction = event.relative
        if Input.is_action_pressed("aim"):
            rotate_toward(event.global_position)
```

### Gamepad
```gdscript
func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventJoypadButton:
        if event.pressed:
            match event.button_index:
                JOY_BUTTON_A:
                    jump()
                JOY_BUTTON_B:
                    dodge()
                JOY_BUTTON_X:
                    attack()
                JOY_BUTTON_Y:
                    interact()
                JOY_BUTTON_LEFT_SHOULDER:
                    block()
                JOY_BUTTON_RIGHT_SHOULDER:
                    use_item()

    if event is InputEventJoypadMotion:
        # Left stick
        if event.axis == JOY_AXIS_LEFT_X:
            move_horizontal = event.axis_value
        elif event.axis == JOY_AXIS_LEFT_Y:
            move_vertical = event.axis_value

        # Triggers
        elif event.axis == JOY_AXIS_TRIGGER_LEFT:
            aim_strength = event.axis_value
        elif event.axis == JOY_AXIS_TRIGGER_RIGHT:
            shoot_strength = event.axis_value
```

### Mouse Mode
```gdscript
# Capture mouse (for FPS/3D games)
Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# Visible mouse (for menus)
Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

# Hidden but captured
Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# Check mode
if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
    # mouse is captured
    pass

# Release on Escape
func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_cancel"):
        if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
            Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
```

## Touch Input

### TouchScreenButton (for mobile)
```
# In scene tree:
TouchScreenButton
├── Texture: button_texture.png
├── Action: "jump" (maps to input action)
├── Visibility Mode: Always
└── Passby Press: false
```

### Multi-touch
```gdscript
var touches: Dictionary = {}

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        if event.pressed:
            touches[event.index] = event.position
            on_touch_start(event.index, event.position)
        else:
            touches.erase(event.index)
            on_touch_end(event.index, event.position)

    if event is InputEventScreenDrag:
        touches[event.index] = event.position
        on_touch_move(event.index, event.position)

func on_touch_start(index: int, pos: Vector2) -> void:
    if index == 0:  # first finger
        # Primary touch
        pass

func on_touch_move(index: int, pos: Vector2) -> void:
    pass

func on_touch_end(index: int, pos: Vector2) -> void:
    pass
```

### Virtual Joystick (mobile)
```gdscript
extends Control

signal joystick_input(direction: Vector2)

var touch_index: int = -1
var deadzone := 0.15

@onready var knob := $Knob
@onready var base := $Base

func _gui_input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        if event.pressed and touch_index == -1:
            touch_index = event.index
            knob.global_position = event.position - knob.size / 2
        elif not event.pressed and event.index == touch_index:
            touch_index = -1
            knob.position = base.size / 2 - knob.size / 2
            joystick_input.emit(Vector2.ZERO)

    if event is InputEventScreenDrag and event.index == touch_index:
        var center := base.global_position + base.size / 2
        var direction := (event.position - center) / (base.size.x / 2)
        direction = direction.limit_length(1.0)

        if direction.length() < deadzone:
            direction = Vector2.ZERO

        knob.position = base.size / 2 + direction * (base.size.x / 2 - knob.size.x / 2) - knob.size / 2
        joystick_input.emit(direction)
```

## Input Remapping

### Runtime Key Rebinding
```gdscript
extends Control

@onready var action_list := $VBoxContainer/ScrollContainer/ActionList

var is_listening := false
var current_action := ""
var current_event_index := 0

func _ready() -> void:
    populate_actions()

func populate_actions() -> void:
    for child in action_list.get_children():
        child.queue_free()

    var actions := ["move_up", "move_down", "move_left", "move_right",
                    "jump", "attack", "interact"]

    for action in actions:
        var hbox := HBoxContainer.new()

        var label := Label.new()
        label.text = action.replace("_", " ").capitalize()
        label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        hbox.add_child(label)

        var events := InputMap.action_get_events(action)
        for i in events.size():
            var btn := Button.new()
            btn.text = event_to_string(events[i])
            btn.pressed.connect(_on_remap_button_pressed.bind(action, i))
            hbox.add_child(btn)

        action_list.add_child(hbox)

func event_to_string(event: InputEvent) -> String:
    if event is InputEventKey:
        return OS.get_keycode_string(event.keycode)
    elif event is InputEventMouseButton:
        return "Mouse " + str(event.button_index)
    elif event is InputEventJoypadButton:
        return Input.get_joy_button_string(event.button_index)
    return event.as_text()

func _on_remap_button_pressed(action: String, event_index: int) -> void:
    is_listening = true
    current_action = action
    current_event_index = event_index
    # Update button text to "Press any key..."

func _input(event: InputEvent) -> void:
    if not is_listening:
        return

    if event is InputEventKey and event.pressed:
        rebind_action(current_action, current_event_index, event)
        is_listening = false
    elif event is InputEventMouseButton and event.pressed:
        rebind_action(current_action, current_event_index, event)
        is_listening = false

func rebind_action(action: String, index: int, new_event: InputEvent) -> void:
    var events := InputMap.action_get_events(action)
    if index < events.size():
        InputMap.action_erase_event(action, events[index])
    InputMap.action_add_event(action, new_event)
    populate_actions()
    save_keybindings()

func save_keybindings() -> void:
    var config := ConfigFile.new()
    var actions := InputMap.get_actions()
    for action in actions:
        if action.begins_with("ui_"):
            continue
        var events := InputMap.action_get_events(action)
        config.set_value("keybindings", action, events)
    config.save("user://keybindings.cfg")

func load_keybindings() -> void:
    var config := ConfigFile.new()
    if config.load("user://keybindings.cfg") == OK:
        for action in config.get_section_keys("keybindings"):
            if InputMap.has_action(action):
                InputMap.action_erase_events(action)
                for event in config.get_value("keybindings", action):
                    InputMap.action_add_event(action, event)
```

## Input Buffer

### Fighting Game Input Buffer
```gdscript
extends Node

var input_buffer: Array[Dictionary] = []
@export var buffer_window := 0.15  # seconds

func _physics_process(delta: float) -> void:
    # Clean old inputs
    var current_time := Time.get_ticks_msec() / 1000.0
    input_buffer = input_buffer.filter(
        func(entry): return current_time - entry.time < buffer_window
    )

    # Check for buffered actions
    if has_buffered_input("attack"):
        perform_attack()
        clear_buffer("attack")

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed:
        var action := find_action_for_key(event.keycode)
        if action:
            input_buffer.append({
                "action": action,
                "time": Time.get_ticks_msec() / 1000.0
            })

func has_buffered_input(action: String) -> bool:
    return input_buffer.any(func(e): return e.action == action)

func clear_buffer(action: String = "") -> void:
    if action.is_empty():
        input_buffer.clear()
    else:
        input_buffer = input_buffer.filter(func(e): return e.action != action)
```

## Input Best Practices

1. **Always use Input Map actions** — never hardcode keys in game logic
2. **Use `get_axis`/`get_vector`** — smooth analog stick movement
3. **Use `is_action_just_pressed`** — for one-shot actions (jump, attack)
4. **Use `is_action_pressed`** — for continuous actions (sprint, aim)
5. **Support both keyboard and gamepad** — check both input types
6. **Capture mouse for gameplay** — release for menus
7. **Deadzone for analog sticks** — ignore small movements
8. **Input buffer for responsiveness** — queue actions slightly early
9. **Save/load keybindings** — ConfigFile for persistence
10. **Test with gamepad** — even if targeting PC

## Verification Checklist
- [ ] Input Map configured in project settings
- [ ] Actions used (not raw key codes)
- [ ] Both keyboard and gamepad supported
- [ ] Mouse captured during gameplay
- [ ] Touch input for mobile targets
- [ ] Key rebinding UI functional
- [ ] Keybindings saved/loaded
- [ ] Input buffer for responsive controls
