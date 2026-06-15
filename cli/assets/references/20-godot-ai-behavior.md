---
name: godot-ai-behavior
description: "Implement game AI with behavior trees, utility AI, state machines, and navigation. Use when building enemy AI, NPC behavior, decision-making systems, companion AI, or AI debugging."
triggers:
  - "ai"
  - "behavior tree"
  - "utility ai"
  - "enemy ai"
  - "npc"
  - "state machine"
  - "decision"
  - "navigation agent"
  - "limboai"
  - "companion"
  - "goap"
---

# Godot AI & Behavior Systems

Build intelligent game AI using state machines, behavior trees, utility AI, and Godot's navigation system.

## State Machine Deep Dive

State machines are the foundation of game AI. Godot doesn't provide a built-in state machine node — you implement them with GDScript.

### Basic State Machine

```gdscript
# res://scripts/ai/state_machine.gd
class_name StateMachine
extends Node

@export var initial_state: State
var current_state: State
var states: Dictionary = {}

func _ready() -> void:
    for child in get_children():
        if child is State:
            states[child.name.to_lower()] = child
            child.state_machine = self
    if initial_state:
        current_state = initial_state
        current_state.enter()

func _physics_process(delta: float) -> void:
    if current_state:
        current_state.physics_update(delta)

func transition_to(target_state: StringName) -> void:
    var new_state := states.get(target_state.to_lower()) as State
    if not new_state:
        push_warning("State not found: %s" % target_state)
        return
    if current_state:
        current_state.exit()
    current_state = new_state
    current_state.enter()
```

### State Base Class

```gdscript
# res://scripts/ai/state.gd
class_name State
extends Node

var state_machine: StateMachine

func enter() -> void:
    pass

func exit() -> void:
    pass

func physics_update(_delta: float) -> void:
    pass

func update(_delta: float) -> void:
    pass
```

### Hierarchical State Machines (HSM)

For complex AI, nest state machines so each state can contain its own sub-state machine.

```gdscript
# CombatState contains its own sub-states: Melee, Ranged, Flee
# res://scripts/ai/states/combat_state.gd
class_name CombatState
extends State

var sub_machine: StateMachine

func enter() -> void:
    sub_machine = $CombatStateMachine
    sub_machine.transition_to(&"melee")

func physics_update(delta: float) -> void:
    # Delegate to the sub-state machine
    if sub_machine:
        sub_machine._physics_process(delta)

func exit() -> void:
    if sub_machine and sub_machine.current_state:
        sub_machine.current_state.exit()
```

### Pushdown Automata

Stack-based state machine that remembers previous states for natural "go back" behavior.

```gdscript
# res://scripts/ai/pushdown_state_machine.gd
class_name PushdownStateMachine
extends StateMachine

var _state_stack: Array[State] = []

func push_state(target_state: StringName) -> void:
    if current_state:
        current_state.exit()
        _state_stack.push_back(current_state)
    var new_state := states.get(target_state.to_lower()) as State
    current_state = new_state
    current_state.enter()

func pop_state() -> void:
    if current_state:
        current_state.exit()
    if _state_stack.size() > 0:
        current_state = _state_stack.pop_back()
        current_state.enter()
    else:
        current_state = null
```

---

## Behavior Tree Pattern

Behavior trees (BT) are a popular alternative to state machines for complex AI. They compose behaviors as a tree of nodes, evaluated top-down each "tick."

### Node Types

| Type | Role | Returns |
|------|------|---------|
| **Sequence** | Run children in order; fail fast if any child fails | SUCCESS if all succeed |
| **Selector** | Run children in order; succeed fast if any child succeeds | SUCCESS if any succeeds |
| **Decorator** | Modify one child's result (invert, repeat, until fail) | Depends on decorator |
| **Leaf** | Execute an action or check a condition | SUCCESS / FAILURE |
| **Parallel** | Run all children simultaneously | Policy-dependent |

### Behavior Tree Implementation

```gdscript
# res://scripts/ai/bt/bt_node.gd
class_name BTNode
extends RefCounted

enum Status { SUCCESS, FAILURE, RUNNING }

func tick(_actor: Node, _blackboard: Blackboard) -> Status:
    return Status.FAILURE
```

```gdscript
# res://scripts/ai/bt/bt_composite.gd
class_name BTComposite
extends BTNode

var children: Array[BTNode] = []

func add_child(child: BTNode) -> void:
    children.append(child)
```

```gdscript
# res://scripts/ai/bt/bt_sequence.gd
class_name BTSequence
extends BTComposite

func tick(actor: Node, blackboard: Blackboard) -> Status:
    for child in children:
        var result := child.tick(actor, blackboard)
        if result != Status.SUCCESS:
            return result  # FAILURE or RUNNING → stop
    return Status.SUCCESS
```

```gdscript
# res://scripts/ai/bt/bt_selector.gd
class_name BTSelector
extends BTComposite

func tick(actor: Node, blackboard) -> Status:
    for child in children:
        var result := child.tick(actor, blackboard)
        if result != Status.FAILURE:
            return result  # SUCCESS or RUNNING → stop
    return Status.FAILURE
```

### Blackboard (Data Sharing)

A blackboard is a shared data store that all behavior tree nodes can read and write.

```gdscript
# res://scripts/ai/bt/blackboard.gd
class_name Blackboard
extends RefCounted

var _data: Dictionary = {}

func set_value(key: StringName, value: Variant) -> void:
    _data[key] = value

func get_value(key: StringName, default: Variant = null) -> Variant:
    return _data.get(key, default)

func has_value(key: StringName) -> bool:
    return _data.has(key)

func clear() -> void:
    _data.clear()
```

### Decorators

```gdscript
# Inverter — flip SUCCESS ↔ FAILURE
class_name BTInverter
extends BTNode

var child: BTNode

func tick(actor: Node, blackboard: Blackboard) -> Status:
    var result := child.tick(actor, blackboard)
    if result == Status.SUCCESS:
        return Status.FAILURE
    if result == Status.FAILURE:
        return Status.SUCCESS
    return Status.RUNNING

# Repeater — repeat child N times or until it fails
class_name BTRepeater
extends BTNode

var child: BTNode
var max_repeats: int = -1  # -1 = infinite
var _count: int = 0

func tick(actor: Node, blackboard: Blackboard) -> Status:
    var result := child.tick(actor, blackboard)
    if result == Status.FAILURE:
        return Status.FAILURE
    _count += 1
    if max_repeats > 0 and _count >= max_repeats:
        _count = 0
        return Status.SUCCESS
    return Status.RUNNING
```

### Example: Enemy Patrol/Chase/Attack Tree

```gdscript
# Build the tree:
var root := BTSelector.new()

# Sub-tree 1: Combat (if player in range)
var combat := BTSequence.new()
combat.add_child(BTCondition.new(&"player_in_attack_range"))
combat.add_child(BTAction.new(&"attack_player"))

# Sub-tree 2: Chase (if player detected)
var chase := BTSequence.new()
chase.add_child(BTCondition.new(&"player_detected"))
chase.add_child(BTAction.new(&"move_toward_player"))

# Sub-tree 3: Patrol (fallback)
var patrol := BTSequence.new()
patrol.add_child(BTAction.new(&"move_to_patrol_point"))
patrol.add_child(BTAction.new(&"wait_at_point"))

root.add_child(combat)
root.add_child(chase)
root.add_child(patrol)

# In the enemy's physics process:
func _physics_process(delta: float) -> void:
    var status := root.tick(self, blackboard)
```

---

## Utility AI

Utility AI scores each possible action and picks the one with the highest score. Great for strategic decision-making.

### Scoring Function Pattern

```gdscript
# res://scripts/ai/utility/consideration.gd
class_name Consideration
extends RefCounted

@export var name: StringName
var curve: Curve  # Optional: remap raw score to final score

func score(_actor: Node) -> float:
    return 0.0  # Override in subclass

func evaluated_score(actor: Node) -> float:
    var raw := score(actor)
    if curve:
        return curve.sample(raw)
    return raw
```

### Example Considerations

```gdscript
class_name HealthConsideration
extends Consideration

func score(actor: Node) -> float:
    var health_component := actor.get_node_or_null("HealthComponent") as HealthComponent
    if not health_component:
        return 0.0
    return float(health_component.current) / float(health_component.maximum)

class_name EnemyProximityConsideration
extends Consideration

func score(actor: Node) -> float:
    var target := actor.get_node_or_null("DetectionArea").get_nearest_enemy()
    if not target:
        return 0.0
    var dist := actor.global_position.distance_to(target.global_position)
    # Closer = higher score (inverse distance)
    return clampf(1.0 - dist / 500.0, 0.0, 1.0)
```

### Reasoner (Action Selector)

```gdscript
# res://scripts/ai/utility/reasoner.gd
class_name Reasoner
extends RefCounted

var actions: Array[UtilityAction] = []

func best_action(actor: Node) -> UtilityAction:
    var best_score := -1.0
    var best_action: UtilityAction = null
    for action in actions:
        var total := action.evaluate(actor)
        if total > best_score:
            best_score = total
            best_action = action
    return best_action

# res://scripts/ai/utility/utility_action.gd
class_name UtilityAction
extends RefCounted

var considerations: Array[Consideration] = []
var action_name: StringName

func evaluate(actor: Node) -> float:
    if considerations.is_empty():
        return 0.0
    var total := 1.0
    for c in considerations:
        total *= c.evaluated_score(actor)
    # Compensation formula to avoid multiplicative collapse
    var count := considerations.size()
    var modification := 1.0 - (1.0 / count)
    var makeup := (1.0 - total) * modification
    return total + makeup * total
```

### Example: Flee / Heal / Attack Decision

```gdscript
# Set up actions for an enemy:
var flee_action := UtilityAction.new()
flee_action.action_name = &"flee"
flee_action.considerations = [HealthConsideration.new()]  # Low health → high flee score

var heal_action := UtilityAction.new()
heal_action.action_name = &"heal"
heal_action.considerations = [HealthConsideration.new(), HasPotionConsideration.new()]

var attack_action := UtilityAction.new()
attack_action.action_name = &"attack"
attack_action.considerations = [EnemyProximityConsideration.new()]

var reasoner := Reasoner.new()
reasoner.actions = [flee_action, heal_action, attack_action]

# Each tick:
func _physics_process(_delta: float) -> void:
    var chosen := reasoner.best_action(self)
    execute_action(chosen.action_name)
```

---

## NavigationAgent for AI

### NavigationAgent2D

```gdscript
# res://scripts/ai/enemy_navigation_2d.gd
extends CharacterBody2D

@onready var nav_agent := $NavigationAgent2D

var movement_speed := 200.0

func _ready() -> void:
    # Connect the velocity computed signal for avoidance
    nav_agent.velocity_computed.connect(_on_velocity_computed)

    # Configure avoidance (4.4+)
    nav_agent.avoidance_enabled = true
    nav_agent.radius = 16.0
    nav_agent.neighbor_distance = 200.0
    nav_agent.max_neighbors = 5
    nav_agent.time_horizon = 0.5

func set_target(position: Vector2) -> void:
    nav_agent.target_position = position

func _physics_process(_delta: float) -> void:
    if nav_agent.is_navigation_finished():
        return

    var next_pos := nav_agent.get_next_path_position()
    var direction := global_position.direction_to(next_pos)
    var desired_velocity := direction * movement_speed

    if nav_agent.avoidance_enabled:
        nav_agent.set_velocity(desired_velocity)
    else:
        velocity = desired_velocity
        move_and_slide()

func _on_velocity_computed(safe_velocity: Vector2) -> void:
    velocity = safe_velocity
    move_and_slide()
```

### NavigationAgent3D

```gdscript
# res://scripts/ai/enemy_navigation_3d.gd
extends CharacterBody3D

@onready var nav_agent := $NavigationAgent3D

var movement_speed := 5.0

func _ready() -> void:
    nav_agent.velocity_computed.connect(_on_velocity_computed)
    nav_agent.avoidance_enabled = true
    nav_agent.radius = 0.5
    nav_agent.path_desired_distance = 0.5
    nav_agent.target_desired_distance = 1.0

func set_target(position: Vector3) -> void:
    nav_agent.target_position = position

func _physics_process(_delta: float) -> void:
    if nav_agent.is_navigation_finished():
        return

    var next_pos := nav_agent.get_next_path_position()
    var direction := global_position.direction_to(next_pos)
    # Keep on the floor
    direction.y = 0.0
    direction = direction.normalized()

    var desired_velocity := direction * movement_speed

    if nav_agent.avoidance_enabled:
        nav_agent.set_velocity(desired_velocity)
    else:
        velocity = desired_velocity
        move_and_slide()

func _on_velocity_computed(safe_velocity: Vector3) -> void:
    velocity = safe_velocity
    move_and_slide()
```

### Runtime Navigation Mesh Rebaking (4.3+)

```gdscript
# Re-bake navigation mesh at runtime when the level changes
func rebake_nav_mesh() -> void:
    var region := %NavigationRegion3D as NavigationRegion3D
    # Use the baked navigation mesh resource
    var nav_mesh := region.navigation_mesh
    # Clear and re-bake
    NavigationServer3D.region_set_map(region.get_rid(), NavigationServer3D.map_get_rid(region))
    region.bake_navigation_mesh()
```

---

## GOAP Overview

Goal-Oriented Action Planning (GOAP) is a planning-based AI approach. The AI defines goals and available actions with preconditions/effects, then a planner finds a sequence of actions to achieve the goal.

### When to Use GOAP vs Behavior Trees

| Aspect | Behavior Tree | GOAP |
|--------|--------------|------|
| **Complexity** | Medium — tree structure | High — planner + world state |
| **Emergent behavior** | Limited to tree paths | Highly emergent |
| **Authoring** | Manual tree construction | Define actions + goals |
| **Debugging** | Trace tree execution | Trace plan steps |
| **Best for** | Predictable enemy patterns | Open-ended NPC behavior |

### Community Implementations

- **LimboAI** — The community-standard BT/GOAP addon for Godot 4.x, with an editor-based BT designer. Available via AssetLib and GitHub.
- **Godot-Goap** — A GOAP implementation for Godot 4, available on GitHub.

> **Recommendation:** For most indie games, start with state machines or behavior trees. Only reach for GOAP if you need highly dynamic, emergent NPC behavior.

---

## LimboAI

[LimboAI](https://github.com/limbonaut/limboai) is the community-standard behavior tree and GOAP addon for Godot 4.x.

### Features
- Visual BT editor integrated into the Godot editor
- Blackboard system with variable scopes
- Task library with common AI tasks (move to, wait, check condition, etc.)
- GOAP planner built in
- HSM (Hierarchical State Machine) support

### Integration

```gdscript
# After installing LimboAI via AssetLib:
# 1. Create a BTPlan resource in the editor
# 2. Design your tree visually
# 3. Attach to a BTPlayer node

# Basic usage with BTPlayer:
@onready var bt_player := $BTPlayer

func _physics_process(delta: float) -> void:
    bt_player.update(delta)

# Access the blackboard:
var target := bt_player.blackboard.get_var("target_position")
```

---

## AI Debugging

### Navigation Debug Drawing

```gdscript
# Enable navigation debug in Project Settings:
# Debug > Navigation > Visible Navigation = On

# Or programmatically:
NavigationServer2D.set_debug_enabled(true)
NavigationServer3D.set_debug_enabled(true)
```

### Custom Debug Gizmos for Behavior State

```gdscript
# Visualize current state in the editor and during debug runs
@tool
extends Node2D

@export var debug_color: Color = Color.GREEN:
    set(value):
        debug_color = value
        queue_redraw()

var current_state_name: String = "idle"

func _draw() -> void:
    if Engine.is_editor_hint() or OS.is_debug_build():
        # Draw a colored circle showing AI state
        var color := _state_color()
        draw_circle(Vector2.ZERO, 24.0, color)
        draw_string(ThemeDB.fallback_font, Vector2(-20, 40), current_state_name, HORIZONTAL_ALIGNMENT_CENTER, -1, 14, color)

func _state_color() -> Color:
    match current_state_name:
        "idle": return Color.GREEN
        "chase": return Color.YELLOW
        "attack": return Color.RED
        "flee": return Color.BLUE
        _: return Color.GRAY
```

### Logging AI Tick Results

```gdscript
# Verbose BT debug logging (disable in production!)
var debug_ai := false

func tick(actor: Node, blackboard: Blackboard) -> Status:
    var result := _execute(actor, blackboard)
    if debug_ai:
        print("[%s] %s → %s" % [actor.name, _node_name(), BTNode.Status.keys()[result]])
    return result
```

### Drawing Debug Paths

```gdscript
# Draw the navigation path for debugging
func _draw_nav_path() -> void:
    if not debug_ai:
        return
    var path := nav_agent.get_current_navigation_path()
    for i in range(path.size() - 1):
        DebugDraw2D.line(path[i], path[i + 1], Color.CYAN, 2.0)
```

---

## Best Practices

1. **Start with state machines** — They're simple, debuggable, and sufficient for 80% of enemy AI.
2. **Graduate to behavior trees** — When your state machine has 10+ states with complex transitions, a BT is cleaner.
3. **Use Utility AI for strategic decisions** — When the AI needs to weigh multiple competing priorities.
4. **Profile AI tick time** — AI should not consume more than 1–2ms per frame. Use `Performance.get_monitor()`.
5. **Decouple AI from presentation** — AI logic should not directly play animations; it should emit signals or set state that the animation system reads.
6. **Use the blackboard pattern** — Shared data between AI nodes prevents tight coupling.
7. **Test avoidance in crowded scenes** — Navigation avoidance can cause jitter with many agents; tune `time_horizon` and `max_neighbors`.
8. **Avoid per-frame path recalculation** — Use `target_desired_distance` and `path_desired_distance` to prevent unnecessary updates.
9. **Consider LimboAI for production** — Its visual editor drastically speeds up BT iteration compared to hand-coded trees.

---

## Verification Checklist

- [ ] State machine transitions are explicit and logged in debug mode
- [ ] Behavior tree returns correct status (SUCCESS/FAILURE/RUNNING) for all nodes
- [ ] Blackboard data is initialized before the first tick
- [ ] NavigationAgent avoidance enabled for multi-agent scenes
- [ ] Navigation paths recalculated only when target changes significantly
- [ ] AI tick time is profiled and under budget
- [ ] Debug drawing available for navigation paths and behavior states
- [ ] GOAP considered only if BT/state machine is insufficient
