---
name: godot-file-io
description: "Handle file I/O, save/load systems, data serialization, and configuration files. Use when implementing save games, loading data, reading config files, JSON/XML parsing, or file system operations."
triggers:
  - "save"
  - "load"
  - "file"
  - "json"
  - "config"
  - "serialize"
  - "data"
  - "persistence"
  - "save game"
  - "highscore"
---

# Godot File I/O & Data Persistence

Implement save systems, configuration, and data loading.

## File Operations

### Basic File Read/Write
```gdscript
# Write text file
func save_text(path: String, content: String) -> void:
    var file := FileAccess.open(path, FileAccess.WRITE)
    if file:
        file.store_string(content)
        file.close()

# Read text file
func load_text(path: String) -> String:
    if not FileAccess.file_exists(path):
        return ""
    var file := FileAccess.open(path, FileAccess.READ)
    if file:
        var content := file.get_as_text()
        file.close()
        return content
    return ""

# Append to file
func append_text(path: String, content: String) -> void:
    var file := FileAccess.open(path, FileAccess.WRITE_READ)
    if file:
        file.seek_end()
        file.store_string(content + "\n")
        file.close()
```

### Binary File
```gdscript
# Write binary
func save_binary(path: String, data: PackedByteArray) -> void:
    var file := FileAccess.open(path, FileAccess.WRITE)
    if file:
        file.store_buffer(data)
        file.close()

# Read binary
func load_binary(path: String) -> PackedByteArray:
    if not FileAccess.file_exists(path):
        return PackedByteArray()
    var file := FileAccess.open(path, FileAccess.READ)
    if file:
        var data := file.get_buffer(file.get_length())
        file.close()
        return data
    return PackedByteArray()
```

### File System Checks
```gdscript
# Check if file exists
if FileAccess.file_exists("user://save.dat"):
    pass

# Check if directory exists
if DirAccess.dir_exists_absolute("user://saves"):
    pass

# Create directory
DirAccess.make_dir_recursive_absolute("user://saves")

# List files in directory
func list_files(path: String) -> Array[String]:
    var files: Array[String] = []
    var dir := DirAccess.open(path)
    if dir:
        dir.list_dir_begin()
        var file_name := dir.get_next()
        while file_name != "":
            if not dir.current_is_dir():
                files.append(file_name)
            file_name = dir.get_next()
        dir.list_dir_end()
    return files

# Delete file
DirAccess.remove_absolute("user://old_save.dat")

# Copy file
DirAccess.copy_absolute("res://data.csv", "user://data.csv")
```

### Important Paths
```
res:// — project directory (read-only in exported builds)
user:// — user data directory (read/write, persistent)

Windows: %APPDATA%/Godot/app_userdata/[project_name]/
macOS: ~/Library/Application Support/Godot/app_userdata/[project_name]/
Linux: ~/.local/share/godot/app_userdata/[project_name]/
```

## JSON

### Save/Load JSON
```gdscript
# Save JSON
func save_json(path: String, data: Variant) -> void:
    var json_string := JSON.stringify(data, "\t")  # pretty print
    var file := FileAccess.open(path, FileAccess.WRITE)
    if file:
        file.store_string(json_string)
        file.close()

# Load JSON
func load_json(path: String) -> Variant:
    if not FileAccess.file_exists(path):
        return null
    var file := FileAccess.open(path, FileAccess.READ)
    if file:
        var json_string := file.get_as_text()
        file.close()
        var json := JSON.new()
        var error := json.parse(json_string)
        if error == OK:
            return json.data
    return null

# Example usage
var save_data := {
    "player": {
        "name": "Hero",
        "level": 5,
        "health": 80,
        "position": {"x": 100, "y": 200}
    },
    "inventory": ["sword", "shield", "potion"],
    "score": 1500
}
save_json("user://save.json", save_data)
var loaded = load_json("user://save.json")
```

### JSON Best Practices
```gdscript
# Validate JSON before using
func safe_load_json(path: String) -> Variant:
    if not FileAccess.file_exists(path):
        push_warning("File not found: " + path)
        return null

    var file := FileAccess.open(path, FileAccess.READ)
    var json_string := file.get_as_text()
    file.close()

    var json := JSON.new()
    var error := json.parse(json_string)
    if error != OK:
        push_error("JSON parse error at line %d: %s" % [json.get_error_line(), json.get_error_message()])
        return null

    return json.data
```

## Config File

### ConfigFile Usage
```gdscript
# Save settings
func save_settings() -> void:
    var config := ConfigFile.new()

    config.set_value("video", "fullscreen", true)
    config.set_value("video", "resolution", Vector2i(1920, 1080))
    config.set_value("video", "vsync", true)

    config.set_value("audio", "master_volume", 0.8)
    config.set_value("audio", "music_volume", 0.6)
    config.set_value("audio", "sfx_volume", 1.0)

    config.set_value("controls", "mouse_sensitivity", 0.3)
    config.set_value("controls", "invert_y", false)

    config.save("user://settings.cfg")

# Load settings
func load_settings() -> void:
    var config := ConfigFile.new()
    if config.load("user://settings.cfg") != OK:
        return  # use defaults

    fullscreen = config.get_value("video", "fullscreen", true)
    resolution = config.get_value("video", "resolution", Vector2i(1920, 1080))
    master_volume = config.get_value("audio", "master_volume", 0.8)
    mouse_sensitivity = config.get_value("controls", "mouse_sensitivity", 0.3)
```

## Save Game System

### Complete Save Manager
```gdscript
# save_manager.gd — Autoload singleton
extends Node

const SAVE_DIR := "user://saves/"
const MAX_SAVES := 5

signal save_completed(slot: int)
signal load_completed(slot: int)

func _ready() -> void:
    DirAccess.make_dir_recursive_absolute(SAVE_DIR)

# --- Save ---
func save_game(slot: int = 0) -> void:
    var save_data := {
        "version": "1.0.0",
        "timestamp": Time.get_datetime_string_from_system(),
        "playtime": GameManager.playtime,
        "player": get_player_data(),
        "world": get_world_data(),
        "inventory": get_inventory_data(),
        "quests": get_quest_data(),
        "settings": get_settings_data()
    }

    var path := SAVE_DIR + "save_%d.json" % slot
    save_json(path, save_data)
    save_completed.emit(slot)
    print("Game saved to slot %d" % slot)

# --- Load ---
func load_game(slot: int = 0) -> bool:
    var path := SAVE_DIR + "save_%d.json" % slot
    var data = load_json(path)

    if data == null:
        push_error("Failed to load save slot %d" % slot)
        return false

    # Version check
    if data.get("version", "") != "1.0.0":
        push_warning("Save version mismatch")
        # Handle migration if needed

    # Apply data
    apply_player_data(data.player)
    apply_world_data(data.world)
    apply_inventory_data(data.inventory)
    apply_quest_data(data.quests)

    load_completed.emit(slot)
    print("Game loaded from slot %d" % slot)
    return true

# --- Delete ---
func delete_save(slot: int) -> void:
    var path := SAVE_DIR + "save_%d.json" % slot
    if FileAccess.file_exists(path):
        DirAccess.remove_absolute(path)

# --- List Saves ---
func get_save_info() -> Array[Dictionary]:
    var saves: Array[Dictionary] = []
    for i in MAX_SAVES:
        var path := SAVE_DIR + "save_%d.json" % i
        if FileAccess.file_exists(path):
            var data = load_json(path)
            if data:
                saves.append({
                    "slot": i,
                    "timestamp": data.get("timestamp", ""),
                    "playtime": data.get("playtime", 0)
                })
        else:
            saves.append({"slot": i, "empty": true})
    return saves

# --- Auto Save ---
func auto_save() -> void:
    save_game(0)  # slot 0 = auto save

# --- Data Collection ---
func get_player_data() -> Dictionary:
    var player := get_tree().get_first_node_in_group("player")
    if not player:
        return {}
    return {
        "health": player.health,
        "max_health": player.max_health,
        "position": {"x": player.global_position.x, "y": player.global_position.y},
        "level": player.level,
        "experience": player.experience
    }

func get_world_data() -> Dictionary:
    return {
        "current_level": get_tree().current_scene.scene_file_path,
        "time_of_day": WorldManager.time_of_day,
        "weather": WorldManager.current_weather
    }

func get_inventory_data() -> Array:
    return InventoryManager.get_all_items()

func get_quest_data() -> Dictionary:
    return QuestManager.get_quest_states()

func get_settings_data() -> Dictionary:
    return {
        "master_volume": AudioManager.master_volume,
        "music_volume": AudioManager.music_volume,
        "sfx_volume": AudioManager.sfx_volume
    }

# --- Data Application ---
func apply_player_data(data: Dictionary) -> void:
    var player := get_tree().get_first_node_in_group("player")
    if not player:
        return
    player.health = data.get("health", 100)
    player.max_health = data.get("max_health", 100)
    var pos := data.get("position", {"x": 0, "y": 0})
    player.global_position = Vector2(pos.x, pos.y)
    player.level = data.get("level", 1)
    player.experience = data.get("experience", 0)

func apply_world_data(data: Dictionary) -> void:
    var level_path: String = data.get("current_level", "")
    if level_path and ResourceLoader.exists(level_path):
        get_tree().change_scene_to_file(level_path)

func apply_inventory_data(data: Array) -> void:
    InventoryManager.clear()
    for item in data:
        InventoryManager.add_item(item)

func apply_quest_data(data: Dictionary) -> void:
    QuestManager.set_quest_states(data)
```

## CSV Data Loading

### Game Balance Data
```gdscript
# Load CSV for game balance (enemies, items, etc.)
func load_csv(path: String) -> Array[Dictionary]:
    var result: Array[Dictionary] = []
    var file := FileAccess.open(path, FileAccess.READ)
    if not file:
        return result

    var headers := file.get_csv_line()
    while not file.eof_reached():
        var values := file.get_csv_line()
        if values.size() < 2:
            continue
        var row := {}
        for i in headers.size():
            if i < values.size():
                row[headers[i]] = values[i]
        result.append(row)

    file.close()
    return result

# Example CSV (enemies.csv):
# id,name,health,damage,speed
# 1,Goblin,50,10,150
# 2,Orc,100,25,100
# 3,Dragon,500,50,200

# Usage
var enemies = load_csv("res://data/enemies.csv")
for enemy in enemies:
    print("%s: HP=%s DMG=%s" % [enemy.name, enemy.health, enemy.damage])
```

## Resource-Based Data

### Custom Resource
```gdscript
# item_data.gd
class_name ItemData
extends Resource

@export var id: String
@export var name: String
@export var description: String
@export var icon: Texture2D
@export var max_stack: int = 99
@export var price: int = 0
@export var item_type: ItemType

enum ItemType { CONSUMABLE, WEAPON, ARMOR, MATERIAL }

# enemy_data.gd
class_name EnemyData
extends Resource

@export var id: String
@export var name: String
@export var max_health: int
@export var damage: int
@export var speed: float
@export var loot_table: Array[ItemData]
@export var sprite: Texture2D
```

### Using Resources
```gdscript
# Load resource
var sword_data: ItemData = preload("res://data/items/sword.tres")

# Create in code
var new_item := ItemData.new()
new_item.id = "custom_sword"
new_item.name = "Magic Sword"
new_item.price = 500
new_item.item_type = ItemData.ItemType.WEAPON

# Save resource
ResourceSaver.save(new_item, "user://custom_item.tres")
```

## Encryption

### Encrypted Save Files
```gdscript
const ENCRYPTION_KEY := "my_secret_key_32bytes_long!!!!"  # 32 bytes

func save_encrypted(path: String, data: Dictionary) -> void:
    var json_string := JSON.stringify(data)
    var file := FileAccess.open_encrypted_with_pass(path, FileAccess.WRITE, ENCRYPTION_KEY)
    if file:
        file.store_string(json_string)
        file.close()

func load_encrypted(path: String) -> Dictionary:
    if not FileAccess.file_exists(path):
        return {}
    var file := FileAccess.open_encrypted_with_pass(path, FileAccess.READ, ENCRYPTION_KEY)
    if file:
        var json_string := file.get_as_text()
        file.close()
        var json := JSON.new()
        if json.parse(json_string) == OK:
            return json.data
    return {}
```

## File I/O Best Practices

1. **Always use `user://`** for save files — `res://` is read-only in exports
2. **Check `FileAccess.file_exists()`** before reading
3. **Use JSON for human-readable** data — easy to debug
4. **Use ConfigFile for settings** — built-in key-value store
5. **Use Resources for game data** — type-safe, editor-friendly
6. **Version your save files** — handle migration between versions
7. **Encrypt sensitive saves** — prevent easy cheating
8. **Auto-save periodically** — don't lose player progress
9. **Compress large files** — `FileAccess.open_compressed()`
10. **Handle file errors gracefully** — don't crash on missing files

## Verification Checklist
- [ ] Save system creates files in user://
- [ ] Load system handles missing/corrupt files
- [ ] JSON parsing with error handling
- [ ] ConfigFile for settings persistence
- [ ] Resources for game data (enemies, items)
- [ ] Auto-save implemented
- [ ] Save version migration (if needed)
- [ ] Encryption for anti-cheat (optional)
