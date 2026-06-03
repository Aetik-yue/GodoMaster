---
name: godot-editor-mastery
description: "Master the Godot editor interface, panels, shortcuts, and debugging tools. Use when the user needs help navigating the editor, finding features, using debug tools, or customizing the workspace."
triggers:
  - "editor"
  - "how to use"
  - "where is"
  - "shortcut"
  - "debug"
  - "profiler"
  - "remote inspector"
  - "editor layout"
---

# Godot Editor Mastery

Help the user become productive in the Godot 4.x editor.

## Five Main Screens

| Screen | Shortcut | Purpose |
|--------|----------|---------|
| **2D** | `F1` | 2D scene editing, sprites, tilemaps, UI |
| **3D** | `F2` | 3D scene editing, meshes, lighting |
| **Script** | `F3` | GDScript editor, documentation |
| **AssetLib** | — | Browse and install addons |
| **Game** | `F5` | Run/debug the game |

## Essential Keyboard Shortcuts

### Navigation
| Action | Shortcut |
|--------|----------|
| Play scene | `F6` |
| Play project | `F5` |
| Stop | `F8` |
| Focus selected | `F` |
| Zoom to selection | `Shift+F` |
| Switch 2D/3D/Script | `F1`/`F2`/`F3` |

### Editing
| Action | Shortcut |
|--------|----------|
| Duplicate | `Ctrl+D` |
| Delete | `Delete` |
| Move node up/down | `Ctrl+Up/Down` |
| Attach script | `Ctrl+Shift+A` |
| Make scene root | drag to root |
| Group selected | `Ctrl+G` |
| Ungroup | `Ctrl+Shift+G` |

### Scene Tree
| Action | Shortcut |
|--------|----------|
| Create new node | `Ctrl+A` |
| Attach script | `Ctrl+Shift+A` |
| Instance scene | `Ctrl+Shift+O` |
| Expand/collapse | `Right/Left` |
| Multi-select | `Ctrl+Click` |

### 2D Specific
| Action | Shortcut |
|--------|----------|
| Pan | `Middle Mouse` |
| Zoom | `Scroll Wheel` |
| Snap to grid | hold `S` |
| Rotate | `R` |
| Scale | `S` |
| Move | `W` |

### 3D Specific
| Action | Shortcut |
|--------|----------|
| Freelook | `Shift+F` or `Right Mouse` |
| Move forward/back | `W/S` |
| Move left/right | `A/D` |
| Fly up/down | `E/Q` |
| Toggle perspective/orthogonal | `5` (numpad) |
| Align to view | `Ctrl+Alt+M` |

## Editor Panels

### Scene Dock
- Tree view of all nodes in current scene
- Right-click for context menu (attach, duplicate, reparent)
- Eye icon toggles visibility
- Lock icon prevents accidental selection

### Inspector
- Shows properties of selected node
- **Pin** icon locks inspector to one node
- Resource dropdown → edit sub-resources
- Group related properties with `@export_group`

### FileSystem
- Project file browser
- Drag assets into scene or inspector
- Right-click → New Resource, Scene, Script
- Filters: `*.tscn`, `*.gd`, `*.tres`

### Output / Debugger
- Output: `print()` statements, engine messages
- Debugger: breakpoints, call stack, errors
- Monitor: FPS, physics, memory, objects

### Audio Bus
- Mix audio channels
- Add effects: reverb, delay, EQ, compressor
- Default bus: "Master"

## Debug Tools

### Running with Debug
```
F5 — Run entire project
F6 — Run current scene only
F8 — Stop running
```

### Debugger Panel
- **Breakpoints**: Click gutter in script editor (F9)
- **Step Over**: F10
- **Step Into**: F11
- **Continue**: F12
- **Stack trace**: Shows call hierarchy
- **Inspector**: Live object inspection while paused

### Monitors (Performance)
View in real-time:
- **Time**: FPS, process, physics frame time
- **Memory**: Static, dynamic, video RAM
- **Objects**: Node count, resource count
- **Physics**: Collision pairs, active bodies
- **Rendering**: Draw calls, vertices, texture mem

### Remote Scene Tree
- When game is running, switch to "Remote" in Scene dock
- Inspect live scene tree
- Modify properties in real-time
- See node states during gameplay

### Output Filtering
```
# Print with categories
print("[AI] Enemy state changed to patrol")
print("[SAVE] Game saved to slot 1")
print("[AUDIO] Playing SFX: explosion_01")
```

## Editor Customization

### Layout
- Save layouts: Editor → Editor Layout → Save
- Rearrange panels by dragging tabs
- Split script editor: right-click tab → Split

### Themes
- Editor → Editor Settings → Text Editor → Theme
- Built-in themes or custom `.tet` files

### Editor Settings Worth Changing
```
text_editor/appearance/line_numbers → true
text_editor/completion/auto_brace_complete → true
interface/scene_tabs/restore_scenes_on_load → true
filesystem/directories/autoscan_project_path → your dev folder
```

## Common Workflows

### Creating a New Scene
1. Scene → New Scene
2. Add root node (Node2D, Node3D, Control, etc.)
3. Add child nodes to build hierarchy
4. Attach scripts via context menu or Ctrl+Shift+A
5. Save scene (Ctrl+S) to `scenes/` folder

### Instancing Scenes
- Drag `.tscn` file into another scene
- Creates an instance that updates when source changes
- Use for reusable components: player, enemies, UI panels

### Connecting Signals
1. Select node → Node panel (right side)
2. Double-click signal name
3. Choose target node and method
4. Or use code: `signal_name.connect(method_name)`

## Verification Checklist
- [ ] Can navigate between 2D/3D/Script screens
- [ ] Knows F5/F6/F8 for running games
- [ ] Can use debugger with breakpoints
- [ ] Understands Remote scene tree inspection
- [ ] Can connect signals via editor
- [ ] Knows how to instance scenes
