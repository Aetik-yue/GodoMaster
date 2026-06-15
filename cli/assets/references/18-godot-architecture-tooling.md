---
name: godot-architecture-tooling
description: "Design modular systems using Custom Resources, extend the Godot editor with @tool scripts and plugins, integrate C++ via GDExtension, and distribute addons. Use when architecting databases, inventory data, configuring tool scripts, building editor tools, or creating GDExtension modules."
triggers:
  - "architecture"
  - "resource"
  - "custom resource"
  - "tool script"
  - "editor plugin"
  - "editorscript"
  - "tres"
  - "gdextension"
  - "godot-cpp"
  - "dependency injection"
  - "autoload"
  - "addon distribution"
---

# Godot Architecture & Editor Tooling

Build modular, data-driven games using custom Resources, extend the editor with `@tool` scripts and plugins, and integrate C++ via GDExtension.

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

## Autoload vs Singleton Patterns

### Autoload Basics

Autoloads are globally-accessible scripts that load before any scene. They are configured in **Project → Project Settings → Autoload**.

```gdscript
# res://scripts/core/game_manager.gd (registered as Autoload)
extends Node

var score: int = 0
var is_paused: bool = false

func add_score(points: int) -> void:
    score += points
```

### When to Use Autoload vs `class_name` Static Access

| Pattern | Best For | Pitfalls |
|---------|----------|----------|
| **Autoload** | Stateful managers (Audio, Save, Game), global event buses | Can create hidden dependencies, hard to test |
| **`class_name` static** | Pure utility functions (Math, Constants), stateless helpers | No state persistence, can't reference scene tree |
| **Resource injection** | Data-driven systems, testable components | More setup code |

### Autoload Pitfalls

```gdscript
# BAD: Too many autoloads for communication
# GameManager.gd, EnemyManager.gd, UIManager.gd, etc.
# Everything talks to everything via autoloads → spaghetti

# GOOD: Use signals and dependency injection for local communication
# Reserve autoloads for truly global, cross-cutting concerns:
# - AudioManager (plays sounds from anywhere)
# - SaveManager (persists data)
# - SignalBus (global events only)
# - SceneManager (scene transitions)
```

### Dependency Injection in Godot

```gdscript
# Constructor injection (via _init or setup method)
class_name PlayerController
extends CharacterBody2D

var _input_handler: InputHandler
var _stats: PlayerStats

func setup(input_handler: InputHandler, stats: PlayerStats) -> void:
    _input_handler = input_handler
    _stats = stats

# Setter injection (via @export)
@export var weapon: WeaponData:
    set(value):
        weapon = value
        _update_weapon_display()

# Resource-based injection
@export var character_class: CharacterClass  # Resource with all class data

# Owner pattern — parent injects dependencies into children
func _ready() -> void:
    for child in get_children():
        if child has_method("setup"):
            child.setup(self)
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

## GDExtension

GDExtension allows you to write performance-critical code in C++ (or other languages) and integrate it with Godot without recompiling the engine.

### When to Use GDExtension vs GDScript

| Criterion | GDScript | GDExtension (C++) |
|-----------|----------|-------------------|
| **Iteration speed** | ⚡ Instant | 🐢 Compile cycle |
| **Performance** | Moderate | High |
| **Library integration** | Limited | Full C/C++ library access |
| **Team skills** | GDScript knowledge | C++ knowledge required |
| **Debugging** | Editor debugger | GDB/LLDB, separate process |
| **Distribution** | Text files, cross-platform | Compiled binaries per platform |
| **Best for** | Game logic, prototyping | Physics, pathfinding, image processing, binding external libraries |

### GDExtension Workflow

```
1. Clone godot-cpp: git clone https://github.com/godotengine/godot-cpp
2. Create your C++ class
3. Create .gdextension metadata file
4. Build with SCons
5. Copy .gdextension + compiled library to your Godot project
6. Use the class like any other node/resource in GDScript
```

### C++ Class Example

```cpp
// src/math_utils.cpp
#include <godot_cpp/classes/node.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

namespace godot {
class MathUtils : public Node {
    GDCLASS(MathUtils, Node)

protected:
    static void _bind_methods() {
        ClassDB::bind_method(D_METHOD("clamp_angle", "angle", "min_angle", "max_angle"), &MathUtils::clamp_angle);
    }

public:
    double clamp_angle(double angle, double min_angle, double max_angle) {
        // Custom high-performance math function
        return fmod(clamp(angle, min_angle, max_angle), Math_TAU);
    }
};
} // namespace godot
```

### .gdextension File

```ini
# addons/math_utils/math_utils.gdextension
[configuration]
entry_symbol = "gdext_rust_init"  # or gdext_cpp_init
compatibility_minimum = 4.3
reloadable = true

[libraries]
windows.debug.x86_64 = "bin/math_utils.windows.debug.x86_64.dll"
windows.release.x86_64 = "bin/math_utils.windows.release.x86_64.dll"
linux.debug.x86_64 = "bin/math_utils.linux.debug.x86_64.so"
linux.release.x86_64 = "bin/math_utils.linux.release.x86_64.so"
macos.debug = "bin/math_utils.macos.debug.dylib"
macos.release = "bin/math_utils.macos.release.dylib"
```

### Building with SCons

```bash
# Build for current platform
scons platform=windows target=template_debug
scons platform=windows target=template_release

# The godot-cpp SConstruct file handles most of the build configuration
# Ensure your SConstruct file points to the godot-cpp directory
```

### Using in GDScript

```gdscript
# After placing the .gdextension and compiled libraries in your project:
var math_utils := MathUtils.new()
var clamped := math_utils.clamp_angle(angle, -PI, PI)
```

> **Important:** The `godot-cpp` version must match your exact Godot version. Always update `godot-cpp` when upgrading Godot.

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

### EditorInspectorPlugin

Create custom inspector editors for your resource types.

```gdscript
# res://addons/my_plugin/inspector_plugin.gd
@tool
extends EditorInspectorPlugin

func _can_handle(object: Object) -> bool:
    return object is ItemData

func _parse_property(object: Object, type: Variant.Type, name: String, hint_type: PropertyHint, hint_string: String, usage_flags: int, wide: bool) -> bool:
    if name == "damage":
        # Add a custom editor for the damage property
        var custom_editor := preload("res://addons/my_plugin/damage_editor.tscn").instantiate()
        custom_editor.setup(object as ItemData)
        add_custom_control(custom_editor)
        return true  # We handled this property
    return false  # Use default editor for other properties
```

Register in your plugin:
```gdscript
var inspector_plugin: EditorInspectorPlugin

func _enter_tree() -> void:
    inspector_plugin = MyInspectorPlugin.new()
    add_inspector_plugin(inspector_plugin)

func _exit_tree() -> void:
    remove_inspector_plugin(inspector_plugin)
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

## Plugin Distribution via AssetLib

### Preparing Your Plugin

```
addons/your_plugin/
├── plugin.cfg         # Required — plugin metadata
├── plugin.gd          # Required — entry script
├── README.md          # Recommended — usage documentation
├── LICENSE            # Required — license file
├── icons/             # Optional — editor icons
└── scenes/            # Optional — dock scenes, inspector scenes
```

### plugin.cfg Reference

```ini
[plugin]
name="Your Plugin"
description="A helpful description of what your plugin does."
author="Your Name"
version="1.0.0"
script="plugin.gd"
```

### Submitting to AssetLib

1. Go to https://godotengine.org/asset-library
2. Create an account
3. Click **Submit Asset**
4. Fill in: name, category, version, **Godot version compatibility**, description
5. Upload a ZIP of the `addons/your_plugin/` directory
6. Add screenshots and documentation links
7. Wait for review (typically 1–3 days)

### Version Compatibility

Always declare the minimum and maximum Godot version your plugin supports. Test with each new Godot release and update the compatibility range.

---

## Verification Checklist

- [ ] Custom Resource classes are declared with `class_name`
- [ ] Resource properties are annotated with `@export`
- [ ] `@tool` scripts check `Engine.is_editor_hint()` before accessing autoloads or tree elements
- [ ] Properties affecting visual elements in `@tool` scripts implement setters that trigger updates (e.g., `queue_redraw()`)
- [ ] Custom EditorPlugins implement cleanup code in `_exit_tree()`
- [ ] EditorScripts inherit from `EditorScript` and implement `_run()`
- [ ] Autoloads used judiciously, not as a default communication pattern
- [ ] GDExtension considered for performance-critical or C++ library integration
- [ ] Plugin distribution follows AssetLib conventions and includes `plugin.cfg`
- [ ] EditorInspectorPlugin registered and unregistered properly
- [ ] .gdextension file lists all target platform libraries
