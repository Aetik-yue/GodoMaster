---
name: godot-performance
description: "Profile, debug, and optimize Godot game performance. Use when games run slowly, need FPS optimization, memory management, draw call reduction, physics optimization, or general performance tuning."
triggers:
  - "performance"
  - "optimization"
  - "fps"
  - "lag"
  - "slow"
  - "profiler"
  - "draw call"
  - "memory"
  - "batching"
  - "occlusion"
  - "culling"
---

# Godot Performance Optimization

Profile and optimize games for maximum performance.

## Profiling Tools

### Built-in Monitors
```
Editor → Debugger → Monitors tab

Categories:
- Time: FPS, process time, physics time
- Memory: static, dynamic, video RAM
- Objects: node count, resource count, orphan nodes
- Physics: collision pairs, active bodies, island count
- Rendering: draw calls, vertices, texture memory
- Navigation: navigation map queries
```

### Print-based Profiling
```gdscript
func _ready() -> void:
    var start := Time.get_ticks_usec()
    # ... expensive operation ...
    var elapsed := Time.get_ticks_usec() - start
    print("Operation took: %d µs" % elapsed)

# FPS counter
func _process(delta: float) -> void:
    if Engine.get_frames_per_second() % 60 == 0:
        print("FPS: %d" % Engine.get_frames_per_second())
```

### Remote Profiler
```
1. Run game with F5
2. Open Debugger → Profiler tab
3. Click "Start" to begin profiling
4. Play the game, trigger actions
5. Click "Stop" and analyze

Shows:
- Function call times
- Script vs engine time
- Per-frame breakdown
```

## Rendering Optimization

### Draw Call Reduction
```
Problem: Each unique material/mesh = 1 draw call
Solution: Batch, merge, use atlases

Techniques:
1. Texture Atlas — combine small textures into one large
2. MultiMesh — thousands of same mesh instances
3. Merge Meshes — combine static geometry
4. Use fewer materials — share materials across objects
5. CanvasItem batching (2D) — automatic for same-texture sprites
```

### MultiMesh for Instancing
```gdscript
# For thousands of identical objects (grass, trees, particles)
extends MultiMeshInstance3D

func _ready() -> void:
    multimesh.instance_count = 10000

    for i in 10000:
        var transform := Transform3D()
        transform.origin = Vector3(
            randf_range(-50, 50),
            0,
            randf_range(-50, 50)
        )
        multimesh.set_instance_transform(i, transform)
```

### Occlusion Culling
```
# For complex 3D scenes with many hidden objects

1. Add OccluderInstance3D nodes to walls/structures
2. Create Occluder3D resource (box, sphere, or polygon)
3. Enable in Project Settings:
   rendering/occlusion_culling/use_occlusion_culling → true

# For rooms: each room has occluders that hide what's behind walls
```

### LOD (Level of Detail)
```
# Automatically reduce detail for distant objects

MeshInstance3D → LOD settings:
- LOD Bias: higher = switch to low detail sooner
- LOD Range: distance thresholds for each mesh detail

Or use code:
if camera.distance_to(mesh) > 100:
    mesh.mesh = low_detail_mesh
```

### VisibilityNotifier
```gdscript
# Disable processing when off-screen
extends CharacterBody2D

@onready var notifier := $VisibleOnScreenNotifier2D

func _ready() -> void:
    notifier.screen_entered.connect(_on_screen_entered)
    notifier.screen_exited.connect(_on_screen_exited)

func _on_screen_entered() -> void:
    set_process(true)
    set_physics_process(true)
    visible = true

func _on_screen_exited() -> void:
    set_process(false)
    set_physics_process(false)
    visible = false
```

## 2D Optimization

### TileMap Performance
```
1. Use TileMapLayer (not old TileMap) — better batching
2. Limit layers — each layer = separate draw
3. Use occlusion for large maps
4. Chunk loading — only load visible tiles
5. Navigation mesh — don't use tilemap nav for large maps
```

### Sprite Batching
```
2D batching happens automatically when:
- Same texture
- Same material
- Same blend mode
- Adjacent in draw order

Tips:
- Use sprite sheets (atlas)
- Avoid interleaving different textures
- Group same-texture sprites together in scene tree
- Use CanvasItemMaterial sparingly
```

### Particle Optimization
```
GPUParticles2D/3D:
- Reduce particle count
- Use simpler process material
- Disable when off-screen (VisibilityNotifier)
- Use one_shot for bursts
- Lower lifetime

CPUParticles2D/3D (deprecated, use GPU):
- Simpler but less features
- Better for very few particles
```

## Physics Optimization

### Collision Optimization
```
1. Use simple collision shapes
   - Rectangle/Circle > Convex polygon > Concave polygon
   - Never use mesh for collision

2. Collision layers and masks
   - Only collide what needs to collide
   - Disable unnecessary layers

3. Static bodies
   - Use StaticBody for immovable objects
   - Don't use RigidBody for walls

4. Physics process
   - Disable when off-screen
   - Use set_physics_process(false)
```

### Physics FPS
```
# Project Settings
physics/common/physics_fps → 60 (default)

# Lower for less CPU usage (30 FPS physics)
# Higher for more accurate simulation (120 FPS)

# Fixed timestep with interpolation:
func _process(delta: float) -> void:
    var fraction := Engine.get_physics_interpolation_fraction()
    # Interpolate visual position between physics frames
```

### Navigation Optimization
```
1. Use NavigationRegion3D with simple mesh
2. Don't rebake navigation every frame
3. Use path simplification (reduce waypoints)
4. Limit agent count (NavigationAgent3D)
5. Async pathfinding (spread over frames)
```

## Memory Management

### Resource Loading
```gdscript
# Preload (load at script compile time)
const TEXTURE = preload("res://icon.png")

# Load (load on demand)
var texture = load("res://icon.png")

# Shared resources
# Resources are cached — loading same path returns same object
var tex1 = load("res://icon.png")
var tex2 = load("res://icon.png")
# tex1 == tex2 (same reference)
```

### Freeing Objects
```gdscript
# Queue free (safe, end of frame)
node.queue_free()

# Immediate free (dangerous, can break iteration)
node.free()

# Remove from tree without freeing
remove_child(node)
# Later: add_child(node) to re-add

# Check before accessing freed objects
if is_instance_valid(node):
    node.do_something()
```

### Object Pooling
```gdscript
class_name ObjectPool
extends Node

@export var scene: PackedScene
@export var pool_size := 50

var available: Array[Node] = []
var in_use: Array[Node] = []

func _ready() -> void:
    for i in pool_size:
        var obj := scene.instantiate()
        obj.visible = false
        obj.process_mode = Node.PROCESS_MODE_DISABLED
        add_child(obj)
        available.append(obj)

func acquire() -> Node:
    var obj: Node
    if available.size() > 0:
        obj = available.pop_back()
    else:
        obj = scene.instantiate()
        add_child(obj)

    obj.visible = true
    obj.process_mode = Node.PROCESS_MODE_INHERIT
    in_use.append(obj)
    return obj

func release(obj: Node) -> void:
    obj.visible = false
    obj.process_mode = Node.PROCESS_MODE_DISABLED
    in_use.erase(obj)
    available.append(obj)
```

### Texture Memory
```
Import settings per texture:
- Compress: VRAM (lossy, GPU-native)
- Size Limit: reduce max resolution
- Mipmaps: enable for 3D, disable for 2D pixel art
- Format: S3TC/BPTC (desktop), ETC2/ASTC (mobile)

Monitor:
Debugger → Monitors → Video → Video Memory
```

## Script Optimization

### GDScript Performance Tips
```
1. Use static typing — enables optimizations
2. Use typed arrays — Array[int] > Array
3. Avoid string operations in hot loops
4. Cache node references — don't $Node every frame
5. Use signals instead of polling
6. Avoid _process when possible — use timers
7. Use bitwise operations for flags
8. Prefer math over branches when possible
9. Use call_deferred for non-urgent operations
10. Profile before optimizing — don't guess
```

### Hot Path Optimization
```gdscript
# BAD: String operation every frame
func _process(delta: float) -> void:
    $Label.text = "Score: " + str(score)  # allocates string

# GOOD: Only update when changed
var last_score := -1
func _process(delta: float) -> void:
    if score != last_score:
        $Label.text = "Score: %d" % score
        last_score = score

# BAD: Find node every frame
func _process(delta: float) -> void:
    get_node("Enemy").take_damage(1)  # lookup every frame

# GOOD: Cache reference
@onready var enemy := $Enemy
func _process(delta: float) -> void:
    enemy.take_damage(1)  # direct access
```

## Performance Checklist

### Quick Wins
- [ ] Static typing enabled
- [ ] Node references cached (@onready)
- [ ] Unused nodes freed (queue_free)
- [ ] Object pooling for bullets/particles
- [ ] Texture compression enabled
- [ ] Simple collision shapes
- [ ] VisibilityNotifier for off-screen objects

### Rendering
- [ ] Draw calls under 100 (2D) or 2000 (3D)
- [ ] Texture atlas for small sprites
- [ ] MultiMesh for repeated objects
- [ ] Occlusion culling for complex 3D scenes
- [ ] LOD for distant 3D objects

### Physics
- [ ] Collision layers optimized
- [ ] Simple collision shapes
- [ ] Physics disabled when off-screen
- [ ] Navigation mesh optimized

### Memory
- [ ] Resources shared (not duplicated)
- [ ] Objects pooled (bullets, enemies)
- [ ] Textures compressed for target platform
- [ ] No orphan nodes (check monitors)

## Verification Checklist
- [ ] Profiler shows no bottleneck > 16ms per frame
- [ ] FPS stable at target (60 or 30)
- [ ] Draw calls within budget
- [ ] Memory usage stable (no leaks)
- [ ] Physics performance acceptable
- [ ] Tested on target hardware (not just dev machine)
