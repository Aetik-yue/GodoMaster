---
name: godot-architecture-tooling
description: "Design modular systems using Custom Resources and extend the Godot editor using @tool scripts and plugins. Use when architecting databases, inventory data, configuring tool scripts, or building editor tools."
triggers:
  - "architecture"
  - "resource"
  - "custom resource"
  - "tool script"
  - "editor plugin"
  - "editorscript"
  - "draw in editor"
  - "tres"
---

# Godot Architecture & Editor Tooling

Build modular, data-driven games using custom Resources, and extend the Godot editor's capabilities using `@tool` scripts and custom plugins.

## Resource-Based Architecture

In Godot, **Resources** are data containers that can hold properties and scripts, but have no visual presence on their own. They are the ideal way to implement modular, decoupled systems (e.g., inventory databases, item stats, character classes, dialogue structures).

### Defining a Custom Resource
```gdscript
# res://scripts/resources/item_data.gd
class_name ItemData
extends Resource

@export var name: String = "Generic Item"
@export var icon: Texture2D
@export var max_stack: int = 99
@export var damage: int = 0
@export var is_usable: bool = false

# Custom logic inside resources is fully supported
func get_description() -> String:
    return "%s (Damage: %d, Max Stack: %d)" % [name, damage, max_stack]
```

### Instantiating Resources
1. In the FileSystem dock, right-click and choose **New Resource...**
2. Search for your custom class `ItemData`.
3. Fill in the parameters in the Inspector (e.g., set Name = "Iron Sword", Damage = 15).
4. Save the resource as a `.tres` file (e.g., `iron_sword.tres`).

### Injecting Resources into Nodes
Nodes can load and references resources easily, decoupling game logic from static data.
```gdscript
# res://scripts/actors/player.gd
extends CharacterBody2D

# Expose slot in inspector for a resource
@export var weapon_data: ItemData

func _ready() -> void:
    if weapon_data:
        print("Equipped: ", weapon_data.get_description())
```

### Dynamic Saving and Loading
Save dynamically modified resources (like a player's customized status) at runtime:
```gdscript
# Save a resource
func save_player_stats(stats: PlayerStats, path: String) -> void:
    var err := ResourceSaver.save(stats, path)
    if err != OK:
        push_error("Failed to save stats to: ", path)

# Load a resource
func load_player_stats(path: String) -> PlayerStats:
    if ResourceLoader.exists(path):
        return ResourceLoader.load(path) as PlayerStats
    return null
```

---

## Tool Scripts (`@tool`)

The `@tool` annotation at the top of a script causes it to execute inside the editor workspace. This is useful for procedural generation, level design helpers, and visualizing changes in real-time without running the game.

### Basic Structure
```gdscript
# res://scripts/tools/visual_path.gd
@tool
extends Node2D

@export var color: Color = Color.RED:
    set(value):
        color = value
        # queue_redraw tells the editor to redraw the node in the viewport
        queue_redraw()

func _ready() -> void:
    # Code in _ready runs in BOTH editor and game. Check environment:
    if Engine.is_editor_hint():
        print("Running in Editor context!")
    else:
        print("Running in Game context!")

func _draw() -> void:
    # Custom editor drawing
    draw_circle(Vector2.ZERO, 32.0, color)
    draw_line(Vector2.ZERO, Vector2(100, 100), color, 4.0)
```

> [!WARNING]
> Since `@tool` runs directly inside the editor, syntax or runtime errors can crash the editor viewport. Always use safety checks (`if Engine.is_editor_hint():`) around logic that interacts with game singletons or autoloads, as those do not exist in the editor.

---

## Custom Editor Plugins

Editor plugins let you add custom panels (docks), inspector controls, and custom import scripts.

### Creating a Plugin
1. Go to **Project → Project Settings → Plugins**.
2. Click **Create New Plugin**.
3. Fill in name, directory, author, version, and the entry script name (typically `plugin.gd`).
4. This creates a directory under `addons/` containing `plugin.cfg` and your plugin script.

### Entry Script Structure (`plugin.gd`)
```gdscript
# res://addons/my_custom_plugin/plugin.gd
@tool
extends EditorPlugin

var dock_instance: Control

func _enter_tree() -> void:
    # Load and instantiate custom dock scene
    var dock_scene = preload("res://addons/my_custom_plugin/my_dock.tscn")
    dock_instance = dock_scene.instantiate()
    
    # Add to the bottom panel or left/right docks
    add_control_to_dock(DOCK_SLOT_LEFT_UR, dock_instance)

func _exit_tree() -> void:
    # Always clean up nodes when the plugin is disabled
    if dock_instance:
        remove_control_from_docks(dock_instance)
        dock_instance.queue_free()
```

---

## EditorScript

If you need to run a single batch script in the editor (e.g., mass renaming nodes, batch importing assets, importing custom levels from text), use `EditorScript`.

### Script Structure
```gdscript
# res://scripts/tools/batch_rename.gd
@tool
extends EditorScript

# Select the script in FileSystem -> Right Click -> Run
func _run() -> void:
    var editor_interface := get_editor_interface()
    var selected_nodes := editor_interface.get_selection().get_selected_nodes()
    
    for node in selected_nodes:
        if node.name.begins_with("Old_"):
            node.name = node.name.replace("Old_", "New_")
            print("Renamed: ", node.name)
```

---

## Verification Checklist
- [ ] Custom Resource classes are declared with `class_name`
- [ ] Resource properties are annotated with `@export`
- [ ] `@tool` scripts check `Engine.is_editor_hint()` before accessing autoloads or tree elements
- [ ] Properties affecting visual elements in `@tool` scripts implement setters that trigger updates (e.g., `queue_redraw()`)
- [ ] Custom EditorPlugins implement cleanup code in `_exit_tree()`
- [ ] EditorScripts inherit from `EditorScript` and implement `_run()`
