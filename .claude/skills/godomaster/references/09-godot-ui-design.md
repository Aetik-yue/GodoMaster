---
name: godot-ui-design
description: "Build game UI with Control nodes, themes, layouts, menus, HUD, and dialog systems. Use when creating menus, health bars, inventory screens, dialog boxes, settings panels, or any user interface."
triggers:
  - "ui"
  - "menu"
  - "hud"
  - "button"
  - "label"
  - "health bar"
  - "inventory"
  - "dialog"
  - "theme"
  - "control node"
  - "layout"
---

# Godot UI Design

Build polished user interfaces using Godot's Control node system.

## UI Node Hierarchy

### Container Nodes (Layout)
| Container | Behavior |
|-----------|----------|
| **VBoxContainer** | Stack children vertically |
| **HBoxContainer** | Stack children horizontally |
| **GridContainer** | Arrange in grid (set columns) |
| **MarginContainer** | Add margins around child |
| **CenterContainer** | Center child |
| **PanelContainer** | Background panel |
| **ScrollContainer** | Scrollable area |
| **TabContainer** | Tabbed pages |
| **HSplitContainer** | Resizable horizontal split |
| **VSplitContainer** | Resizable vertical split |
| **AspectRatioContainer** | Maintain aspect ratio |
| **FlowContainer** | Wrap like text flow |

### Display Nodes
| Node | Purpose |
|------|---------|
| **Label** | Simple text display |
| **RichTextLabel** | Formatted text (BBCode) |
| **TextureRect** | Display image |
| **TextureProgressBar** | Image-based progress bar |
| **ProgressBar** | Simple progress bar |
| **ColorRect** | Colored rectangle |
| **NinePatchRect** | Scalable bordered image |

### Input Nodes
| Node | Purpose |
|------|---------|
| **Button** | Clickable button |
| **CheckBox** | Toggle checkbox |
| **CheckButton** | Toggle switch |
| **OptionButton** | Dropdown select |
| **SpinBox** | Number input |
| **LineEdit** | Single-line text |
| **TextEdit** | Multi-line text |
| **HSlider / VSlider** | Slider input |
| **HSeparator / VSeparator** | Visual separator |

## Common UI Patterns

### Main Menu
```
MainMenu (Control)
├── Background (TextureRect)
│   └── Expand: true
├── MarginContainer
│   └── VBoxContainer
│       ├── Title (Label)
│       │   └── Text: "Game Title"
│       ├── Spacer (Control)
│       │   └── Size Flags: Expand
│       ├── PlayButton (Button)
│       ├── SettingsButton (Button)
│       ├── CreditsButton (Button)
│       └── QuitButton (Button)
└── VersionLabel (Label)
    └── Anchors: Bottom-Right
```

### HUD Layout
```
HUD (CanvasLayer)
├── TopBar (HBoxContainer)
│   ├── ScoreLabel (Label)
│   └── TimerLabel (Label)
│       └── Size Flags: Expand + Right
├── HealthBar (TextureProgressBar)
│   └── Anchors: Top-Left
├── ManaBar (TextureProgressBar)
│   └── Anchors: Top-Left (offset below health)
├── Minimap (SubViewportContainer)
│   └── Anchors: Top-Right
└── BottomBar (HBoxContainer)
    └── Anchors: Bottom-Center
    ├── HotbarSlot1 (TextureRect)
    ├── HotbarSlot2 (TextureRect)
    └── HotbarSlot3 (TextureRect)
```

### Settings Panel
```
SettingsPanel (PanelContainer)
├── MarginContainer
│   └── VBoxContainer
│       ├── Title (Label)
│       │   └── Text: "Settings"
│       ├── TabContainer
│       │   ├── Audio (VBoxContainer)
│       │   │   ├── MasterVolume (HBoxContainer)
│       │   │   │   ├── Label: "Master"
│       │   │   │   └── HSlider (0-100)
│       │   │   ├── MusicVolume (HBoxContainer)
│       │   │   └── SFXVolume (HBoxContainer)
│       │   ├── Video (VBoxContainer)
│       │   │   ├── Resolution (OptionButton)
│       │   │   ├── Fullscreen (CheckButton)
│       │   │   └── VSync (CheckButton)
│       │   └── Controls (VBoxContainer)
│       │       └── Key binding buttons
│       └── HBoxContainer
│           ├── ApplyButton (Button)
│           └── BackButton (Button)
```

## Anchors & Layout

### Anchor Presets
```
Full Rect: (0,0) to (1,1) — fills parent
Center: (0.5,0.5) to (0.5,5) — centered
Top-Left: (0,0) to (0,0)
Top-Right: (1,0) to (1,0)
Bottom-Left: (0,1) to (0,1)
Bottom-Right: (1,1) to (1,1)
Top: (0,0) to (1,0) — full width, top
Bottom: (0,1) to (1,1) — full width, bottom
Left: (0,0) to (0,1) — full height, left
Right: (1,0) to (1,1) — full height, right
```

### Size Flags
```
Size Flags Horizontal/Vertical:
- Fill: take available space
- Expand: share extra space with siblings
- Shrink Center: center when smaller than parent
- Shrink End: align to end when smaller

Common combo: Fill + Expand (distribute evenly)
```

### Margin Container
```gdscript
# Add margins in editor or code
var margin_container := $MarginContainer
margin_container.add_theme_constant_override("margin_left", 20)
margin_container.add_theme_constant_override("margin_top", 20)
margin_container.add_theme_constant_override("margin_right", 20)
margin_container.add_theme_constant_override("margin_bottom", 20)
```

## Themes

### Creating a Theme
```
1. Create Theme resource (.tres)
2. Set default font, colors, styles
3. Configure specific node types:
   - Button → normal, hover, pressed, disabled styles
   - Label → font_color, font_size
   - Panel → style (background)
4. Apply to root Control node
```

### Theme Properties in Code
```gdscript
# Set theme on a control
$Control.theme = preload("res://themes/game_theme.tres")

# Override specific property
$Button.add_theme_stylebox_override("normal", custom_style)
$Button.add_theme_color_override("font_color", Color.WHITE)
$Label.add_theme_font_size_override("font_size", 24)

# Create StyleBoxFlat
var style := StyleBoxFlat.new()
style.bg_color = Color(0.2, 0.2, 0.3, 0.9)
style.border_color = Color(0.4, 0.4, 0.5)
style.set_border_width_all(2)
style.set_corner_radius_all(8)
style.set_content_margin_all(12)
```

### Font Setup
```gdscript
# In theme resource or code
var font := load("res://fonts/game_font.ttf")
$Label.add_theme_font_override("font", font)
$Label.add_theme_font_size_override("font_size", 32)

# Dynamic font settings
font.fixed_width = true  # monospace
```

## Dialog System

### Simple Dialog Box
```gdscript
extends PanelContainer

@onready var name_label := $VBox/NameLabel
@onready var text_label := $VBox/RichTextLabel
@onready var continue_indicator := $VBox/ContinueIndicator

signal dialog_finished

var dialog_queue: Array[Dictionary] = []
var is_typing := false
var type_speed := 0.03

func show_dialog(speaker: String, text: String) -> void:
    name_label.text = speaker
    text_label.visible_characters = 0
    text_label.text = text
    visible = true
    is_typing = true

    for i in text.length():
        text_label.visible_characters = i + 1
        await get_tree().create_timer(type_speed).timeout
        if not is_typing:
            text_label.visible_characters = -1
            break

    is_typing = false
    continue_indicator.visible = true

func _input(event: InputEvent) -> void:
    if not visible:
        return

    if event.is_action_pressed("interact"):
        if is_typing:
            is_typing = false  # skip typing
        elif dialog_queue.size() > 0:
            var next := dialog_queue.pop_front()
            show_dialog(next.speaker, next.text)
        else:
            visible = false
            dialog_finished.emit()
```

### Dialog with Choices
```gdscript
extends PanelContainer

@onready var text_label := $VBox/RichTextLabel
@onready var choices_container := $VBox/Choices

signal choice_made(index: int)

func show_choice(text: String, choices: Array[String]) -> void:
    text_label.text = text
    visible = true

    # Clear old choices
    for child in choices_container.get_children():
        child.queue_free()

    # Create choice buttons
    for i in choices.size():
        var btn := Button.new()
        btn.text = choices[i]
        btn.pressed.connect(_on_choice_pressed.bind(i))
        choices_container.add_child(btn)

func _on_choice_pressed(index: int) -> void:
    visible = false
    choice_made.emit(index)
```

## Inventory UI

### Grid Inventory Display
```gdscript
extends GridContainer

@export var slot_scene: PackedScene
@export var inventory: Inventory  # Resource with items array

var slots: Array[InventorySlot] = []

func _ready() -> void:
    columns = inventory.max_slots
    for i in inventory.max_slots:
        var slot := slot_scene.instantiate() as InventorySlot
        add_child(slot)
        slot.slot_index = i
        slot.clicked.connect(_on_slot_clicked)
        slots.append(slot)
    update_display()

func update_display() -> void:
    for i in slots.size():
        var item := inventory.get_item(i)
        slots[i].set_item(item)

func _on_slot_clicked(index: int) -> void:
    var item := inventory.get_item(index)
    if item:
        inventory.use_item(index)
        update_display()
```

## Progress Bars

### Health Bar
```gdscript
extends TextureProgressBar

@onready var label := $Label

func update_health(current: int, max_val: int) -> void:
    max_value = max_val
    value = current
    label.text = "%d / %d" % [current, max_val]

    # Color based on percentage
    var pct := float(current) / float(max_val)
    if pct > 0.5:
        tint_progress = Color.GREEN
    elif pct > 0.25:
        tint_progress = Color.YELLOW
    else:
        tint_progress = Color.RED

    # Animate change
    var tween := create_tween()
    tween.tween_property(self, "value", current, 0.3)
```

## UI Animation

### Menu Transitions
```gdscript
func show_menu(menu: Control) -> void:
    menu.visible = true
    menu.modulate.a = 0.0
    menu.scale = Vector2(0.8, 0.8)
    var tween := create_tween().set_parallel(true)
    tween.tween_property(menu, "modulate:a", 1.0, 0.3)
    tween.tween_property(menu, "scale", Vector2.ONE, 0.3)\
        .set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func hide_menu(menu: Control) -> void:
    var tween := create_tween().set_parallel(true)
    tween.tween_property(menu, "modulate:a", 0.0, 0.2)
    tween.tween_property(menu, "scale", Vector2(0.8, 0.8), 0.2)
    await tween.finished
    menu.visible = false
```

### Button Hover Effect
```gdscript
extends Button

func _ready() -> void:
    mouse_entered.connect(_on_hover)
    mouse_exited.connect(_on_unhover)

func _on_hover() -> void:
    var tween := create_tween()
    tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.1)

func _on_unhover() -> void:
    var tween := create_tween()
    tween.tween_property(self, "scale", Vector2.ONE, 0.1)
```

## UI Best Practices

1. **Use CanvasLayer for HUD** — renders on top, unaffected by camera
2. **Anchor everything** — use Full Rect for background, corners for fixed UI
3. **Use containers for layout** — VBox/HBox for stacking, Grid for grids
4. **Theme from root** — set theme on top Control, inherits to children
5. **Responsive design** — use anchors and size flags, not fixed positions
6. **Signal for communication** — buttons emit signals, don't directly modify game state
7. **Separate UI scenes** — HUD, Menu, Settings as separate scenes
8. **Input focus management** — set focus neighbors for gamepad navigation
9. **Animate transitions** — fade, slide, scale for polish
10. **Test with different resolutions** — use stretch mode canvas_items

## Verification Checklist
- [ ] CanvasLayer used for HUD
- [ ] Anchors set correctly for all UI elements
- [ ] Containers used for layout (VBox, HBox, Grid)
- [ ] Theme applied and consistent
- [ ] Buttons connected to signals
- [ ] Menu transitions animated
- [ ] Tested at different resolutions
- [ ] Gamepad navigation works (focus neighbors)
