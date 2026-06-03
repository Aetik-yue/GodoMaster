---
name: godot-2d-fundamentals
description: "Build 2D games with sprites, tilemaps, parallax, and 2D-specific features. Use when working with 2D graphics, sprite animation, tile-based levels, 2D lighting, parallax scrolling, or 2D particle effects."
triggers:
  - "2d"
  - "sprite"
  - "tilemap"
  - "tileset"
  - "parallax"
  - "2d lighting"
  - "pixel art"
  - "sprite sheet"
  - "2d particles"
---

# Godot 2D Fundamentals

Build complete 2D games using Godot's 2D engine.

## Coordinate System
- Origin: top-left corner
- X: right positive
- Y: down positive (unlike math)
- Units: pixels
- Rotation: clockwise positive

## Sprites

### Sprite2D Setup
```gdscript
extends Sprite2D

func _ready() -> void:
    # Set texture
    texture = preload("res://art/player.png")

    # Flip
    flip_h = false  # horizontal
    flip_v = false  # vertical

    # Offset
    offset = Vector2(0, -16)  # shift sprite up

    # Region (spritesheet)
    region_enabled = true
    region_rect = Rect2(0, 0, 32, 32)  # first frame
```

### AnimatedSprite2D
```gdscript
extends AnimatedSprite2D

func _ready() -> void:
    # Play animation
    play("idle")

    # Switch animation
    if velocity.x != 0:
        play("walk")
    else:
        play("idle")

    # Flip based on direction
    flip_h = velocity.x < 0

    # Animation finished
    animation_finished.connect(_on_animation_finished)

func _on_animation_finished() -> void:
    if animation == "attack":
        play("idle")
```

### Sprite Sheet Workflow
1. Import sprite sheet as texture
2. Create `SpriteFrames` resource in AnimatedSprite2D
3. Add animations: "idle", "walk", "run", "jump"
4. Set frame duration and loop settings
5. Add frames from the sheet using region coordinates

## TileMaps

### TileMapLayer Setup (Godot 4.3+)
```
TileMapLayer node
├── TileSet resource
│   ├── Texture (spritesheet)
│   ├── Physics layer (collision)
│   ├── Navigation layer (pathfinding)
│   └── Custom data layers
└── Painted tiles
```

### Creating a TileSet
1. Add `TileMapLayer` node
2. Click on TileSet in Inspector → New TileSet
3. Open TileSet editor (bottom panel)
4. Drag texture into Atlas panel
5. Configure tile size (16x16, 32x32, etc.)
6. Paint tiles in TileMap panel

### Physics in TileMaps
```
TileSet → Physics Layers → Add Layer
→ Select tiles → Paint collision polygons
→ Set collision layer/mask
```

### Terrains (Auto-Tiling)
```
TileSet → Terrain Set → Add Terrain Set
→ Add Terrain (e.g., "grass", "dirt", "water")
→ Paint terrain bits on tiles (center, edge, corner)
→ Use Terrain mode to auto-connect tiles
```

### TileMap in Code
```gdscript
extends TileMapLayer

func _ready() -> void:
    # Get tile at position
    var tile_pos := local_to_map(global_position)
    var tile_data := get_cell_tile_data(tile_pos)

    # Set tile
    set_cell(tile_pos, source_id, atlas_coords, alternative_tile)

    # Erase tile
    erase_cell(tile_pos)

    # Get used cells
    var all_cells := get_used_cells()
    var cells_by_tile := get_used_cells_by_id(source_id)

    # Custom data
    if tile_data:
        var is_solid: bool = tile_data.get_custom_data("solid")
        var damage: int = tile_data.get_custom_data("damage")
```

### TileMap Best Practices
- Use separate TileMapLayer nodes for: terrain, decoration, objects
- Name them descriptively: "Ground", "Walls", "Decorations"
- Set collision layers properly (ground=1, walls=2, etc.)
- Use custom data for tile properties (walkable, damage, sound)
- Keep tile size consistent (16x16 or 32x32)

## Parallax Backgrounds

### ParallaxBackground Setup
```
ParallaxBackground
├── ParallaxLayer (sky - slowest)
│   └── Sprite2D (sky texture)
├── ParallaxLayer (mountains)
│   └── Sprite2D (mountains texture)
├── ParallaxLayer (trees)
│   └── Sprite2D (trees texture)
└── ParallaxLayer (ground detail - fastest)
    └── Sprite2D (ground texture)
```

### ParallaxLayer Settings
```gdscript
# Motion scale controls scroll speed relative to camera
# (0, 0) = static (moves with camera, no parallax)
# (0.5, 0.5) = half camera speed
# (1, 1) = same as camera speed (no parallax effect)
# (2, 2) = double camera speed (foreground elements)

# For infinite scrolling
parallax_layer.motion_mirroring = Vector2(texture_width, 0)
```

## 2D Lighting

### Light Setup
```
# Point light
PointLight2D
├── Texture: light_circle.png
├── Color: warm yellow
├── Energy: 1.0
├── Texture Scale: 2.0
└── Range: Z-index above sprites

# Directional light (sun)
DirectionalLight2D
├── Color: white
└── Energy: 0.8
```

### Normal Maps for 2D Lighting
1. Create normal map texture (same size as sprite)
2. Set in Sprite2D → Material → Normal Map
3. Light interacts with normal map for 3D-like effect
4. Use `CanvasItemMaterial` for blend mode settings

### Shadow Setup
```
PointLight2D
├── Shadow Enabled: true
├── Shadow Filter: PCF5 (smooth)
├── Shadow Filter Smooth: 1.0
└── Item Cull Mask: match sprite layers

Sprite2D (wall)
├── Light Mask: match light layer
└── Material → Cast Shadow: true
```

## 2D Particles

### GPUParticles2D
```gdscript
extends GPUParticles2D

func _ready() -> void:
    # Configure process material
    var mat := process_material as ParticleProcessMaterial
    mat.direction = Vector3(0, -1, 0)  # upward
    mat.initial_velocity_min = 50.0
    mat.initial_velocity_max = 100.0
    mat.gravity = Vector3(0, 98, 0)  # fall down
    mat.scale_min = 0.5
    mat.scale_max = 1.5
    mat.color = Color.RED

    # Emission
    emitting = true
    amount = 50
    lifetime = 1.0
    one_shot = false  # true for explosion
    explosiveness = 0.0  # 1.0 = all at once

    # Texture
    texture = preload("res://art/particle.png")
```

### Particle Presets
- **Fire**: direction=up, gravity=0, color=orange→red→transparent
- **Smoke**: direction=up, slow velocity, fade out, gray
- **Explosion**: one_shot, explosiveness=1.0, all directions
- **Rain**: direction=down, high velocity, many particles
- **Sparkle**: small, random direction, short lifetime
- **Dust**: low velocity, gravity down, brown/tan

## 2D Camera

### Camera2D Setup
```gdscript
extends Camera2D

@export var target: Node2D
@export var smoothing_speed := 5.0
@export var look_ahead := 50.0

func _ready() -> void:
    # Smoothing
    position_smoothing_enabled = true
    position_smoothing_speed = smoothing_speed

    # Limits (for level bounds)
    limit_left = 0
    limit_top = 0
    limit_right = 1920
    limit_bottom = 1080

    # Drag margins (for screen-edge follow)
    drag_horizontal_enabled = true
    drag_vertical_enabled = true
    drag_left_margin = 0.2
    drag_right_margin = 0.2
    drag_top_margin = 0.2
    drag_bottom_margin = 0.2

func _process(delta: float) -> void:
    if target:
        global_position = target.global_position
```

### Camera Effects
```gdscript
# Shake effect
func shake(intensity: float = 5.0, duration: float = 0.2) -> void:
    var tween := create_tween()
    for i in int(duration / 0.02):
        var offset := Vector2(
            randf_range(-intensity, intensity),
            randf_range(-intensity, intensity)
        )
        tween.tween_property(self, "offset", offset, 0.02)
    tween.tween_property(self, "offset", Vector2.ZERO, 0.02)

# Zoom effect
func zoom_in(target_zoom: Vector2 = Vector2(2, 2), duration: float = 0.5) -> void:
    var tween := create_tween()
    tween.tween_property(self, "zoom", target_zoom, duration)
```

## Verification Checklist
- [ ] Coordinate system understood (Y-down)
- [ ] Sprite2D or AnimatedSprite2D configured
- [ ] TileMapLayer with physics collision set up
- [ ] Parallax layers with correct motion scales
- [ ] Lighting with shadows if needed
- [ ] Camera2D with smoothing and limits
- [ ] Particle effects configured for game feel
