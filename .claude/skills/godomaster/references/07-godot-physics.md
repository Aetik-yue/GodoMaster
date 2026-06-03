---
name: godot-physics
description: "Implement 2D and 3D physics including collisions, rigid bodies, joints, raycasting, and physics-based interactions. Use when building physics-driven gameplay, collision detection, projectile systems, or vehicle mechanics."
triggers:
  - "physics"
  - "collision"
  - "rigid body"
  - "raycast"
  - "area"
  - "joint"
  - "gravity"
  - "velocity"
  - "force"
  - "impulse"
  - "physics layer"
  - "collision mask"
---

# Godot Physics

Implement physics systems for 2D and 3D games.

## Physics Body Types

### CharacterBody2D/3D
- **Use for**: Player, NPCs, enemies
- **Movement**: `move_and_slide()` — you control velocity
- **No physics forces**: doesn't respond to gravity automatically
- **Collision**: detects and responds to collisions

### RigidBody2D/3D
- **Use for**: Destructibles, physics objects, projectiles
- **Movement**: physics engine controls (gravity, forces, impulses)
- **Modes**: Rigid, Static, Character, Kinematic
- **Collision**: full physics simulation

### StaticBody2D/3D
- **Use for**: Walls, floors, immovable objects
- **Movement**: never moves
- **Collision**: other bodies collide with it

### AnimatableBody2D/3D
- **Use for**: Moving platforms, doors
- **Movement**: moves with animation, carries riders
- **Collision**: acts like static but with movement

## Collision Layers & Masks

### How They Work
```
Layer: "I am on layer X" (what I am)
Mask:  "I detect layer X" (what I interact with)

Example:
Player:
  Layer: 1 (player)
  Mask: 2 (environment), 3 (enemies), 4 (pickups)

Enemy:
  Layer: 3 (enemy)
  Mask: 1 (player), 2 (environment)

Pickup:
  Layer: 4 (pickup)
  Mask: 1 (player)
```

### Recommended Layer Setup
```
Layer 1: Player
Layer 2: Environment (walls, floor)
Layer 3: Enemies
Layer 4: Pickups / Items
Layer 5: Projectiles (player)
Layer 6: Projectiles (enemy)
Layer 7: Interactables
Layer 8: Triggers (Area2D only)
```

## Area2D/3D (Detection Zones)

### Common Uses
- Hitboxes and hurtboxes
- Pickup detection
- Trigger zones (doors, checkpoints)
- Damage areas

### Area2D Setup
```gdscript
extends Area2D

func _ready() -> void:
    # Signals
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)
    area_entered.connect(_on_area_entered)
    area_exited.connect(_on_area_exited)

func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("player"):
        body.pick_up(item)

func _on_area_entered(area: Area2D) -> void:
    if area is Hitbox:
        take_damage(area.damage)
```

### Hitbox/Hurtbox System
```gdscript
# hitbox.gd
class_name Hitbox
extends Area2D

@export var damage := 10
@export var knockback_force := 200.0

# hurtbox.gd
class_name Hurtbox
extends Area2D

signal hurt(damage: int, knockback: Vector2)

func _ready() -> void:
    area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
    if area is Hitbox:
        var knockback_dir := (global_position - area.global_position).normalized()
        hurt.emit(area.damage, knockback_dir * area.knockback_force)
```

## Raycasting

### RayCast2D/3D Node
```gdscript
extends Node2D

@onready var raycast := $RayCast2D

func _physics_process(delta: float) -> void:
    if raycast.is_colliding():
        var collider := raycast.get_collider()
        var point := raycast.get_collision_point()
        var normal := raycast.get_collision_normal()

        if collider is Player:
            attack()
```

### Direct Raycast Query (2D)
```gdscript
func check_line_of_sight(from: Vector2, to: Vector2) -> Node2D:
    var space_state := get_world_2d().direct_space_state
    var query := PhysicsRayQueryParameters2D.create(from, to)
    query.collision_mask = 0b00000010  # layer 2 only
    query.collide_with_areas = false

    var result := space_state.intersect_ray(query)
    if result:
        return result.collider
    return null
```

### Direct Raycast Query (3D)
```gdscript
func shoot_ray(origin: Vector3, direction: Vector3, max_dist: float = 100.0) -> Dictionary:
    var space_state := get_world_3d().direct_space_state
    var end := origin + direction * max_dist

    var query := PhysicsRayQueryParameters3D.create(origin, end)
    query.collision_mask = 0b00000100  # layer 3 (enemies)

    var result := space_state.intersect_ray(query)
    return result  # { "position", "normal", "collider", "rid" }
```

### Shape Cast
```gdscript
# Check area with a shape (sweep test)
func check_area_cast(from: Vector3, to: Vector3, shape: Shape3D) -> Array:
    var space_state := get_world_3d().direct_space_state
    var query := PhysicsShapeQueryParameters3D.new()
    query.shape = shape
    query.transform = Transform3D(Basis.IDENTITY, from)

    var results := space_state.intersect_shape(query)
    return results
```

## Rigid Bodies

### RigidBody2D
```gdscript
extends RigidBody2D

@export var launch_force := 500.0

func _ready() -> void:
    # Mode
    mode = RigidBody2D.RIGID  # default physics
    # mode = RigidBody2D.STATIC  # immovable
    # mode = RigidBody2D.CHARACTER  # no rotation, physics forces

    # Mass and friction
    mass = 1.0
    gravity_scale = 1.0
    linear_damp = 0.0
    angular_damp = 0.0
    friction = 0.2
    bounciness = 0.5

func launch(direction: Vector2) -> void:
    apply_central_impulse(direction * launch_force)

func _physics_process(delta: float) -> void:
    # Apply continuous force
    apply_central_force(Vector2(100, 0))  # push right

    # Apply torque
    apply_torque(50.0)  # spin
```

### RigidBody3D
```gdscript
extends RigidBody3D

@export var throw_force := 10.0

func throw(direction: Vector3) -> void:
    apply_impulse(direction * throw_force)

func _physics_process(delta: float) -> void:
    # Apply force at offset (creates rotation)
    var offset := Vector3(0.5, 0, 0)  # push from the side
    apply_force(Vector3(0, 0, -100), offset)
```

## Joints

### PinJoint2D
- Connects two bodies at a point
- Bodies can rotate around the pin
- Use for: chains, pendulums, hinges

### GrooveJoint2D
- One body slides along a line on the other
- Use for: sliders, pistons

### DampedSpringJoint2D
- Two bodies connected by a spring
- Use for: elastic connections, suspension

```gdscript
# Joint setup (usually in editor, but can be code)
var joint := PinJoint2D.new()
joint.node_a = body_a.get_path()
joint.node_b = body_b.get_path()
joint.global_position = connection_point
add_child(joint)
```

## Projectiles

### Bullet Pattern (2D)
```gdscript
extends Area2D

@export var speed := 600.0
@export var damage := 10
@export var direction := Vector2.RIGHT

func _ready() -> void:
    body_entered.connect(_on_body_entered)
    area_entered.connect(_on_area_entered)
    rotation = direction.angle()

func _physics_process(delta: float) -> void:
    position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
    if body.has_method("take_damage"):
        body.take_damage(damage)
    queue_free()

func _on_area_entered(area: Area2D) -> void:
    if area is Hurtbox:
        area.hurt.emit(damage, direction * 100)
    queue_free()
```

### Object Pool for Bullets
```gdscript
class_name BulletPool
extends Node

@export var bullet_scene: PackedScene
@export var pool_size := 50

var pool: Array[Node2D] = []

func _ready() -> void:
    for i in pool_size:
        var bullet := bullet_scene.instantiate() as Node2D
        bullet.visible = false
        bullet.process_mode = Node.PROCESS_MODE_DISABLED
        add_child(bullet)
        pool.append(bullet)

func fire(pos: Vector2, dir: Vector2) -> void:
    for bullet in pool:
        if not bullet.visible:
            bullet.global_position = pos
            bullet.direction = dir
            bullet.visible = true
            bullet.process_mode = Node.PROCESS_MODE_INHERIT
            return
```

## Physics Best Practices

1. **Use the right body type** — CharacterBody for controlled movement, RigidBody for physics objects
2. **Set collision layers early** — changing later breaks existing setups
3. **Prefer `move_and_slide()`** — handles slope, stairs, and floor detection
4. **Use Area2D for detection** — don't use physics bodies just for triggers
5. **Raycast for line-of-sight** — cheaper than casting shapes
6. **Pool projectiles** — don't instantiate/destroy bullets constantly
7. **Disable physics when offscreen** — use `process_mode = DISABLED`
8. **Use `physics_process` not `process`** — consistent timestep for physics
9. **Avoid moving StaticBody** — use AnimatableBody instead
10. **Test collision layers** — use the editor's "Visible Collision Shapes" debug option

## Verification Checklist
- [ ] Collision layers and masks configured correctly
- [ ] Player uses CharacterBody2D/3D with move_and_slide
- [ ] Hitbox/Hurtbox system for combat
- [ ] Raycast for line-of-sight checks
- [ ] Projectiles use object pooling
- [ ] Physics bodies have correct mass/friction
- [ ] Area2D used for triggers and detection
- [ ] "Visible Collision Shapes" enabled for debugging
