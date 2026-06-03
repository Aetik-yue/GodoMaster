---
name: godot-3d-fundamentals
description: "Build 3D games with meshes, materials, lighting, and 3D-specific features. Use when working with 3D models, materials, 3D lighting, environment setup, fog, skyboxes, or 3D world building."
triggers:
  - "3d"
  - "mesh"
  - "material"
  - "3d lighting"
  - "environment"
  - "fog"
  - "skybox"
  - "3d model"
  - "import model"
  - "pbr"
---

# Godot 3D Fundamentals

Build complete 3D games using Godot's 3D engine.

## Coordinate System
- Origin: center
- X: right positive
- Y: up positive
- Z: forward positive (toward camera in default view)
- Units: meters (by convention)
- Rotation: Euler angles in radians

## Meshes

### MeshInstance3D Setup
```gdscript
extends MeshInstance3D

func _ready() -> void:
    # Built-in meshes
    mesh = BoxMesh.new()
    mesh = SphereMesh.new()
    mesh = CylinderMesh.new()
    mesh = PlaneMesh.new()
    mesh = PrismMesh.new()
    mesh = TorusMesh.new()

    # Configure mesh
    var box := mesh as BoxMesh
    box.size = Vector3(1, 2, 1)

    # Material
    mesh.surface_set_material(0, preload("res://materials/wood.tres"))
```

### Importing 3D Models
```
Supported formats:
- .glTF / .glb (recommended)
- .FBX
- .OBJ (simple, no animation)
- .DAE (Collada)

Import workflow:
1. Place model file in project folder
2. Godot auto-imports
3. Click .glb → Import tab → configure
4. Drag into scene or instance as MeshInstance3D
```

### Import Settings
```
Meshes:
- Generate Lightmap UV: for baked lighting
- Ensure Tangents: for normal maps

Animation:
- Import Animation: toggle
- FPS: animation framerate
- Loop Mode: linear, ping-pong, clamp

Materials:
- Generate Material: auto-create materials
- Material Location: where to save
```

## Materials

### StandardMaterial3D (PBR)
```gdscript
var material := StandardMaterial3D.new()

# Albedo (base color)
material.albedo_color = Color(1, 0.8, 0.6)
material.albedo_texture = preload("res://textures/diffuse.png")

# Metallic
material.metallic = 0.0       # 0=non-metal, 1=full metal
material.metallic_texture = preload("res://textures/metallic.png")
material.metallic_specular = 0.5

# Roughness
material.roughness = 0.5      # 0=mirror, 1=fully rough
material.roughness_texture = preload("res://textures/roughness.png")

# Normal map
material.normal_enabled = true
material.normal_texture = preload("res://textures/normal.png")
material.normal_scale = 1.0

# Emission
material.emission_enabled = true
material.emission = Color(1, 0.5, 0)
material.emission_energy_multiplier = 2.0

# Transparency
material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
material.albedo_color.a = 0.5

# Culling
material.cull_mode = BaseMaterial3D.CULL_DISABLED  # double-sided

# Blend mode
material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD  # additive

# Rim (edge glow)
material.rim_enabled = true
material.rim = 1.0
material.rim_tint = 0.5

# Backlight (translucent)
material.backlight_enabled = true
material.backlight = Color(1, 1, 1)
```

### ShaderMaterial
```gdscript
var shader_mat := ShaderMaterial.new()
shader_mat.shader = preload("res://shaders/my_shader.gdshader")
shader_mat.set_shader_parameter("color", Color.RED)
shader_mat.set_shader_parameter("speed", 2.0)
```

## 3D Lighting

### Light Types
```
DirectionalLight3D — Sun, moon (infinite distance)
├── Shadow Enabled: true
├── Directional Shadow → Max Distance
├── Light Color
└── Light Energy

OmniLight3D — Point light (bulb, fire)
├── Omni Range: light radius
├── Omni Attenuation: falloff curve
├── Shadow Enabled
└── Light Color/Energy

SpotLight3D — Cone light (flashlight, spotlight)
├── Spot Angle: cone width
├── Spot Angle Attenuation: edge softness
├── Spot Range: distance
└── Shadow Enabled
```

### Light Baking
```
# For static lights on static objects:
1. Set light → Bake Mode: Static
2. Set mesh → Global Illumination → Use in Baked Light
3. Create LightmapGI node in scene
4. Click "Bake Lightmaps" in editor

# For real-time shadows:
Light → Shadow Enabled = true
Light → Bake Mode: Disabled
```

### Volumetric Fog
```
WorldEnvironment
└── Environment
    ├── Volumetric Fog
    │   ├── Enabled: true
    │   ├── Density: 0.01-0.05
    │   ├── Albedo: Color (fog color)
    │   ├── Emission: Color (self-illumination)
    │   └── GI Inject: 0.5-1.0
    └── Volumetric Fog Filter
        ├── Temporal Reprojection: true
        └── Filter Size: 3-5
```

## Environment

### WorldEnvironment Setup
```
WorldEnvironment
└── Environment
    ├── Background
    │   ├── Mode: Sky
    │   └── Sky → ProceduralSkyMaterial or PanoramaSkyMaterial
    ├── Ambient Light
    │   ├── Source: Sky or Disabled
    │   └── Energy: 0.5-1.0
    ├── Tonemap
    │   ├── Mode: Filmic or Aces
    │   └── White: 6.0
    ├── SSAO (Screen Space Ambient Occlusion)
    │   └── Enabled: true
    ├── SSIL (Screen Space Indirect Lighting)
    │   └── Enabled: true
    ├── Glow
    │   ├── Enabled: true
    │   ├── Intensity: 0.8
    │   └── Bloom: 0.1
    ├── SSR (Screen Space Reflections)
    │   └── Enabled: true
    ├── SSAO
    │   └── Enabled: true
    └── Fog
        ├── Enabled: true
        ├── Light Color
        └── Density
```

### Sky Types
```gdscript
# Procedural sky (dynamic day/night)
var sky_mat := ProceduralSkyMaterial.new()
sky_mat.sky_top_color = Color(0.3, 0.5, 0.8)
sky_mat.sky_horizon_color = Color(0.6, 0.7, 0.9)
sky_mat.ground_bottom_color = Color(0.1, 0.07, 0.05)
sky_mat.ground_horizon_color = Color(0.6, 0.7, 0.9)
sky_mat.sun_angle_max = 30.0
sky_mat.sun_curve = 0.15

# Panoramic sky (HDRI)
var panorama := PanoramaSkyMaterial.new()
panorama.panorama = preload("res://hdri/sky.hdr")
```

## Camera3D

### FPS Camera
```gdscript
extends Camera3D

@export var mouse_sensitivity := 0.002
@export var pitch_limit := 89.0

func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        # Horizontal rotation (parent node)
        get_parent().rotate_y(-event.relative.x * mouse_sensitivity)

        # Vertical rotation (camera only)
        rotate_x(-event.relative.y * mouse_sensitivity)
        rotation.x = clampf(rotation.x, deg_to_rad(-pitch_limit), deg_to_rad(pitch_limit))
```

### Third Person Camera
```gdscript
extends Node3D  # Camera pivot

@export var target: Node3D
@export var distance := 5.0
@export var height := 2.0
@export var mouse_sensitivity := 0.003

var yaw := 0.0
var pitch := -20.0

func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        yaw -= event.relative.x * mouse_sensitivity
        pitch = clampf(pitch - event.relative.y * mouse_sensitivity, -80, 20)

func _process(delta: float) -> void:
    if not target:
        return

    global_position = target.global_position

    rotation.y = yaw
    $Camera3D.rotation.x = deg_to_rad(pitch)
    $Camera3D.position = Vector3(0, height, distance)
```

## 3D Movement (CharacterBody3D)

### Standard 3D Controller
```gdscript
extends CharacterBody3D

@export var speed := 5.0
@export var sprint_speed := 8.0
@export var jump_velocity := 4.5
@export var mouse_sensitivity := 0.002

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var camera := $Camera3D

func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        rotate_y(-event.relative.x * mouse_sensitivity)
        camera.rotate_x(-event.relative.y * mouse_sensitivity)
        camera.rotation.x = clampf(camera.rotation.x, -1.2, 1.2)

func _physics_process(delta: float) -> void:
    # Gravity
    if not is_on_floor():
        velocity.y -= gravity * delta

    # Jump
    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = jump_velocity

    # Movement
    var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

    var current_speed := sprint_speed if Input.is_action_pressed("sprint") else speed

    if direction:
        velocity.x = direction.x * current_speed
        velocity.z = direction.z * current_speed
    else:
        velocity.x = move_toward(velocity.x, 0, speed)
        velocity.z = move_toward(velocity.z, 0, speed)

    move_and_slide()
```

## 3D Particles

### GPUParticles3D
```gdscript
extends GPUParticles3D

func _ready() -> void:
    var mat := process_material as ParticleProcessMaterial

    # Emission shape
    mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
    mat.emission_sphere_radius = 0.5

    # Direction
    mat.direction = Vector3(0, 1, 0)
    mat.spread = 30.0

    # Velocity
    mat.initial_velocity_min = 2.0
    mat.initial_velocity_max = 5.0

    # Gravity
    mat.gravity = Vector3(0, -9.8, 0)

    # Size
    mat.scale_min = 0.1
    mat.scale_max = 0.3

    # Color
    mat.color = Color(1, 0.5, 0, 1)

    # Lifetime
    lifetime = 2.0
    amount = 100
    one_shot = false
    explosiveness = 0.0
```

## Navigation (3D Pathfinding)

### Setup
```
1. Add NavigationRegion3D node
2. Create NavigationMesh resource
3. Bake navigation mesh (covers walkable area)
4. Add NavigationAgent3D to characters
```

### Navigation Agent Usage
```gdscript
extends CharacterBody3D

@onready var nav_agent := $NavigationAgent3D

func move_to(target_pos: Vector3) -> void:
    nav_agent.target_position = target_pos

func _physics_process(delta: float) -> void:
    if nav_agent.is_navigation_finished():
        return

    var next_pos := nav_agent.get_next_path_position()
    var direction := (next_pos - global_position).normalized()

    velocity = direction * speed
    move_and_slide()
```

## Verification Checklist
- [ ] Coordinate system understood (Y-up)
- [ ] 3D models imported correctly (.glb preferred)
- [ ] Materials configured (PBR workflow)
- [ ] Lighting set up (directional + point lights)
- [ ] WorldEnvironment configured (sky, fog, glow)
- [ ] Camera3D with proper controls
- [ ] CharacterBody3D with gravity and movement
- [ ] Navigation mesh baked for AI pathfinding
