---
name: godot-asset-pipeline
description: "Manage the Godot asset pipeline including ResourceImporter, EditorImportPlugin, .import workflow, .tres custom loaders, and the addons ecosystem. Use when creating custom import workflows, managing asset conversion, building import plugins, or distributing addons."
triggers:
  - "import"
  - "resource importer"
  - "editor import plugin"
  - "asset pipeline"
  - "tres"
  - "addon"
  - "assetlib"
  - "custom loader"
  - "import plugin"
  - "resource format"
---

# Godot Asset Pipeline & Addon Ecosystem

Understand Godot's import system, create custom import plugins, and manage the addon ecosystem.

## The .import Workflow

### How Godot Imports Assets

When you add a file to the project folder, Godot's import system processes it:

```
1. Detect new/changed file in project directory
2. Match file extension to a ResourceImporter
3. Read import options (defaults or user-overridden)
4. Generate imported resources in .godot/imported/
5. Create .import metadata file alongside the source
6. Cache the result for fast subsequent loads
```

### The .godot/ Directory

```
project/
├── .godot/
│   ├── imported/          # All imported/converted resources
│   │   ├── texture.png-abc123.scn
│   │   ├── model.glb-def456.scn
│   │   └── ...
│   ├── editor/            # Editor metadata, scans, thumbnails
│   ├── uid_cache.bin      # Resource UID tracking
│   └── extension_list.cfg # GDExtension registry
└── ...
```

> **Important:** The `.godot/` directory should be in `.gitignore`. It is regenerated from source assets on each machine.

### .import Files

Each source asset gets a `.import` companion file with import settings:

```ini
# res://art/player.png.import
[remap]
importer="texture"
type="CompressedTexture2D"
uid="uid://bq3xk8j2n5vmp"
path="res://.godot/imported/player.png-abc123.ctex"

[deps]
source_file="res://art/player.png"
dest_files=["res://.godot/imported/player.png-abc123.ctex"]

[params]
compress/mode=0
compress/lossy_quality=0.7
compress/hdr_compression=1
mipmaps/generate=false
roughness/src_normal=""
process/fix_alpha_border=true
process/premult_alpha=false
process/normal_map_invert_y=false
process/hdr_as_srgb=false
process/size_limit=0
detect_3d/compress_to=1
```

### Reimporting Assets

```
# Force reimport a single asset:
# 1. In FileSystem dock, right-click → Reimport
# 2. Or delete the .import file and restart the editor

# Force full reimport (nuclear option):
# 1. Delete the .godot/imported/ directory
# 2. Restart the editor — all assets reimport from scratch

# Change import type:
# 1. Select the file in FileSystem dock
# 2. In the Import tab, change the importer (e.g., Texture → TextureAtlas)
# 3. Click Reimport
```

---

## ResourceImporter API

`ResourceImporter` is the base class for all built-in importers. You don't typically subclass it directly — use `EditorImportPlugin` instead for custom importers.

### Built-in Importers

| Importer | Source Extensions | Output Type |
|----------|------------------|-------------|
| `texture` | `.png`, `.jpg`, `.webp`, `.svg` | `CompressedTexture2D` |
| `scene` | `.glb`, `.gltf`, `.fbx`, `.obj` | `PackedScene` |
| `audio` | `.wav`, `.ogg`, `.mp3` | `AudioStream` |
| `font` | `.ttf`, `.otf`, `.woff2` | `FontFile` |
| `translation` | `.po`, `.csv` | `Translation` |
| `shader` | `.gdshader` | `Shader` |
| `json` | `.json` | `JSON` resource |

### Accessing Import Options

```gdscript
# Read import options for an asset in the editor
@tool
extends EditorScript

func _run() -> void:
    var ei := get_editor_interface()
    var fs := ei.get_resource_filesystem()
    # Get import info for a file
    var file_path := "res://art/player.png"
    var info := fs.get_file_type(file_path)
    print("Type: ", info)
```

---

## EditorImportPlugin

Create custom import plugins to bring unsupported file formats into Godot.

### Plugin Structure

```gdscript
# res://addons/custom_importer/custom_import_plugin.gd
@tool
extends EditorImportPlugin

func _get_importer_name() -> String:
    return "custom.data_importer"

func _get_visible_name() -> String:
    return "Custom Data Format"

func _get_recognized_extensions() -> PackedStringArray:
    return PackedStringArray(["cdata"])

func _get_resource_type() -> String:
    return "Resource"  # The type of resource this importer produces

func _get_save_extension() -> String:
    return "tres"  # Extension for the imported resource cache

func _get_preset_count() -> int:
    return 1  # Number of import presets

func _get_preset_name(preset_index: int) -> String:
    return "Default"

func _get_import_options(path: String, preset_index: int) -> Array[Dictionary]:
    return [
        {"name": "compress", "default_value": false, "property_hint": "", "hint_string": "", "usage_flags": 0},
        {"name": "quality", "default_value": 0.8, "property_hint": "range,0,1,0.01", "hint_string": "", "usage_flags": 0}
    ]

func _get_import_order() -> int:
    return 0  # Lower = imported first; use for dependencies

func _get_priority() -> float:
    return 1.0  # Higher priority wins if multiple importers handle same extension

func _import(source_file: String, save_path: String, options: Dictionary,
             platform_variants: Array[String], gen_files: Array[String]) -> Error:
    # Read the source file
    var file := FileAccess.open(source_file, FileAccess.READ)
    if not file:
        return ERR_CANT_OPEN

    var data := file.get_as_text()
    file.close()

    # Parse and create the resource
    var resource := CustomDataResource.new()
    resource.parse(data)

    # Apply options
    if options.get("compress", false):
        resource.compress()

    # Save the imported resource
    var err := ResourceSaver.save(resource, "%s.%s" % [save_path, _get_save_extension()])
    if err != OK:
        return err

    return OK
```

### Registering with EditorPlugin

```gdscript
# res://addons/custom_importer/plugin.gd
@tool
extends EditorPlugin

var import_plugin: EditorImportPlugin

func _enter_tree() -> void:
    import_plugin = CustomImportPlugin.new()
    add_import_plugin(import_plugin)

func _exit_tree() -> void:
    remove_import_plugin(import_plugin)
    import_plugin = null
```

### Custom Data Resource

```gdscript
# res://addons/custom_importer/custom_data_resource.gd
class_name CustomDataResource
extends Resource

@export var entries: Array[String] = []
@export var metadata: Dictionary = {}

func parse(raw_text: String) -> void:
    var lines := raw_text.split("\n")
    for line in lines:
        var trimmed := line.strip_edges()
        if trimmed != "" and not trimmed.begins_with("#"):
            entries.append(trimmed)

func compress() -> void:
    # Apply compression logic
    pass
```

---

## Custom Resource Loaders

For loading custom file formats directly (without the import pipeline), implement `ResourceFormatLoader`.

### ResourceFormatLoader Subclass

```gdscript
# res://addons/custom_loader/custom_format_loader.gd
class_name CustomFormatLoader
extends ResourceFormatLoader

func _get_recognized_extensions() -> PackedStringArray:
    return PackedStringArray(["cdata"])

func _handles_type(typename: StringName) -> bool:
    return typename == &"CustomDataResource"

func _recognize_path(path: String, typehint: StringName) -> bool:
    return path.get_extension() == "cdata"

func _load(path: String, original_path: String, use_sub_threads: bool, cache_mode: int) -> Variant:
    var file := FileAccess.open(path, FileAccess.READ)
    if not file:
        return ERR_CANT_OPEN

    var data := file.get_as_text()
    file.close()

    var resource := CustomDataResource.new()
    resource.parse(data)
    resource.resource_path = original_path
    return resource
```

### Registering Custom Loaders

```gdscript
# In your plugin's _enter_tree():
var _loader := CustomFormatLoader.new()
ResourceLoader.register_custom_loader(_loader)

# In _exit_tree():
ResourceLoader.unregister_custom_loader(_loader)
```

> **When to use EditorImportPlugin vs ResourceFormatLoader:**
> - **EditorImportPlugin**: Converts external files into Godot resources at import time. The imported resource is cached. Best for production — imported assets load fast.
> - **ResourceFormatLoader**: Loads files at runtime without importing. Useful for mod support, user-created content, or files outside the project.

---

## Custom Resource Savers

To save resources in a custom format, implement `ResourceFormatSaver`.

### ResourceFormatSaver Subclass

```gdscript
# res://addons/custom_saver/custom_format_saver.gd
class_name CustomFormatSaver
extends ResourceFormatSaver

func _get_recognized_extensions() -> PackedStringArray:
    return PackedStringArray(["cdata"])

func _recognize(resource: Resource) -> bool:
    return resource is CustomDataResource

func _save(path: String, resource: Resource, flags: int) -> Error:
    var data_resource := resource as CustomDataResource
    if not data_resource:
        return ERR_INVALID_PARAMETER

    var file := FileAccess.open(path, FileAccess.WRITE)
    if not file:
        return ERR_CANT_OPEN

    for entry in data_resource.entries:
        file.store_line(entry)
    file.close()
    return OK
```

### Registering Custom Savers

```gdscript
# In your plugin's _enter_tree():
var _saver := CustomFormatSaver.new()
ResourceSaver.register_custom_saver(_saver)

# In _exit_tree():
ResourceSaver.unregister_custom_saver(_saver)
```

---

## Addon Ecosystem

### Popular Godot 4.x Addons

| Addon | Purpose | URL |
|-------|---------|-----|
| **LimboAI** | Behavior trees & GOAP with visual editor | github.com/limbonaut/limboai |
| **Dialogic 2** | Dialogue & narrative engine | github.com/dialogic-godot/dialogic |
| **Phantom Camera** | Cinematic camera system | github.com/phantom-camera/phantom-camera |
| **Aseprite Importer** | Import Aseprite animations directly | github.com/viniciusgerevini/godot-aseprite-importer |
| **Godot Steam** | Steamworks integration | github.com/GodotSteam/GodotSteam |
| **GUT** | GDScript Unit Testing | github.com/bitwes/Gut |
| **GdUnit4** | GDScript Unit Testing (modern) | github.com/MikeSchulze/gdUnit4 |
| **Kehom's Godot Addons** | Audio, UI, and utility addons | github.com/Kehom/GodotAddons |
| **Scatter** | Procedural object scattering | github.com/HungryProton/scatter |
| **Terrain3D** | 3D terrain editor | github.com/TokisanGames/Terrain3D |

### Installing Addons

```
# Method 1: AssetLib (built-in)
# 1. Editor → AssetLib tab
# 2. Search for the addon
# 3. Download and install
# 4. Enable in Project → Project Settings → Plugins

# Method 2: Manual (GitHub releases)
# 1. Download the release archive
# 2. Extract the addon folder into res://addons/
# 3. Enable in Project → Project Settings → Plugins

# Method 3: Git submodule (for version control)
git submodule add https://github.com/user/addon.git addons/addon_name
```

### Vendoring Addons in Source Control

```
# .gitignore — DO NOT ignore addons/ (they should be committed)
# .gitignore — DO ignore .godot/ (regenerated)

# Best practice: commit addons/ to git
# This ensures all team members have the exact same addon versions
# For git submodule addons, team members run:
git submodule update --init --recursive
```

### Version-Locking Addons

```gdscript
# Create a addons_manifest.gd or addons.cfg to track versions
# Example: addons.cfg (ConfigFile format)
[limboai]
version = "1.2.0"
source = "assetlib"

[dialogic]
version = "2.0.0-rc1"
source = "github"

[phantom_camera]
version = "0.7.0"
source = "github"
```

---

## Addon Distribution

### Publishing to AssetLib

1. **Prepare your addon:**
   ```
   addons/your_addon/
   ├── plugin.cfg         # Required — plugin metadata
   ├── plugin.gd          # Required — entry script
   ├── README.md          # Recommended — usage docs
   ├── LICENSE            # Required — license file
   ├── icons/             # Optional — plugin icons
   └── scenes/            # Optional — plugin scenes
   ```

2. **Configure `plugin.cfg`:**
   ```ini
   [plugin]
   name="Your Addon"
   description="A helpful description of what your addon does."
   author="Your Name"
   version="1.0.0"
   script="plugin.gd"
   ```

3. **Submit to AssetLib:**
   - Go to https://godotengine.org/asset-library
   - Create an account
   - Click "Submit Asset"
   - Fill in: name, category, version, Godot version compatibility, description
   - Upload a ZIP of the `addons/your_addon/` directory
   - Add screenshots and documentation links
   - Wait for review (usually 1–3 days)

### Version Compatibility Declaration

```
# When submitting to AssetLib, specify:
# - Minimum Godot version (e.g., 4.3)
# - Maximum Godot version (e.g., 4.6 or leave blank for latest)
# This helps users find compatible addons for their Godot version
```

### plugin.cfg Complete Reference

```ini
[plugin]
# Required fields
name="My Plugin"                          # Display name in the editor
description="Does something useful."       # One-line description
author="Author Name"                       # Your name or organization
version="1.0.0"                            # Semantic version
script="plugin.gd"                         # Entry script (relative path)

# Optional (set via code or Project Settings)
# depends="some_other_plugin"             # Plugin dependency
```

---

## Best Practices

1. **Version-lock addons** — Commit addons/ to git with exact versions; never use "latest" in production.
2. **Use `.gdignore`** — Add a `.gdignore` file to any directory that contains non-Godot tools (e.g., build scripts, raw assets) to prevent the editor from scanning them.
3. **Keep `addons/` in git** — Commit the entire addons/ directory so all team members have the same versions.
4. **Test reimport after engine upgrades** — When upgrading Godot, clear `.godot/imported/` and verify all assets reimport correctly.
5. **Use EditorImportPlugin for production pipelines** — Import plugins convert assets at import time, resulting in faster runtime loading.
6. **Use ResourceFormatLoader for mod support** — Runtime loading without import is ideal for user-generated content.
7. **Document your addon's Godot version compatibility** — Test with each new Godot release and update the compatibility range.
8. **Provide a README with every addon** — Include: installation, usage, configuration, known issues, and version history.
9. **Use `@tool` carefully in addon scripts** — Errors in `@tool` scripts can crash the editor; always guard with `Engine.is_editor_hint()`.
10. **Clean up in `_exit_tree()`** — Always remove docks, import plugins, and custom inspectors when your plugin is disabled.

---

## Verification Checklist

- [ ] `.godot/` directory is in `.gitignore`
- [ ] `addons/` directory is committed to git (not ignored)
- [ ] Custom import plugins are registered via EditorPlugin
- [ ] Custom loaders/savers are registered and unregistered properly
- [ ] Import options have sensible defaults
- [ ] Reimport tested after engine version upgrade
- [ ] Addon plugin.cfg is complete with name, description, author, version, script
- [ ] Addon includes README.md and LICENSE
- [ ] `.gdignore` used for non-Godot directories
- [ ] Resource paths use `res://` not absolute paths
