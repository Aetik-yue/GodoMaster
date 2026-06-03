---
name: godot-networking
description: "Implement multiplayer networking including peer-to-peer, client-server, RPC calls, state synchronization, and lobby systems. Use when building multiplayer games, online features, leaderboards, or networked interactions."
triggers:
  - "network"
  - "multiplayer"
  - "online"
  - "rpc"
  - "server"
  - "client"
  - "peer"
  - "lobby"
  - "sync"
  - "multiplayer sync"
---

# Godot Networking

Build multiplayer games with Godot's networking system.

## Network Architecture

### Client-Server Model
```
Server (authoritative)
├── Game state
├── Physics simulation
├── Validation
└── Broadcasts to clients

Client 1 ──→ Server ──→ Client 2
Client 3 ──→ Server ──→ Client 1
```

### Peer-to-Peer (ENet)
```
Host (also a client)
├── Game state authority
├── Accepts connections
└── Relays to other peers

Client connects to Host
All communicate through Host
```

## MultiplayerAPI

### Basic Setup
```gdscript
extends Node

var peer := ENetMultiplayerPeer.new()
const PORT := 9999
const MAX_PLAYERS := 4

func _ready() -> void:
    multiplayer.peer_connected.connect(_on_peer_connected)
    multiplayer.peer_disconnected.connect(_on_peer_disconnected)
    multiplayer.connected_to_server.connect(_on_connected_to_server)
    multiplayer.connection_failed.connect(_on_connection_failed)

# --- Host ---
func host_game() -> void:
    var error := peer.create_server(PORT, MAX_PLAYERS)
    if error != OK:
        push_error("Failed to create server: " + str(error))
        return

    multiplayer.multiplayer_peer = peer
    print("Server started on port %d" % PORT)

# --- Join ---
func join_game(address: String) -> void:
    var error := peer.create_client(address, PORT)
    if error != OK:
        push_error("Failed to connect: " + str(error))
        return

    multiplayer.multiplayer_peer = peer
    print("Connecting to %s:%d" % [address, PORT])

# --- Callbacks ---
func _on_peer_connected(id: int) -> void:
    print("Peer connected: %d" % id)

func _on_peer_disconnected(id: int) -> void:
    print("Peer disconnected: %d" % id)

func _on_connected_to_server() -> void:
    print("Connected to server!")

func _on_connection_failed() -> void:
    print("Connection failed!")
```

## RPC (Remote Procedure Calls)

### RPC Syntax
```gdscript
# Define RPC method
@rpc("any_peer", "reliable")
func send_message(message: String) -> void:
    var sender := multiplayer.get_remote_sender_id()
    print("Player %d: %s" % [sender, message])
    # Process message

# Call RPC
@rpc("any_peer", "reliable")
func player_action(action: String) -> void:
    if multiplayer.is_server():
        # Server processes the action
        process_action(multiplayer.get_remote_sender_id(), action)

# Calling RPC
send_message.rpc("Hello everyone!")  # calls on all peers
send_message.rpc_id(1, "Hello host!")  # calls on specific peer
```

### RPC Modes
```
# Authority modes:
"any_peer"     — any peer can call this
"authority"    — only server/host can call

# Transfer modes:
"reliable"     — guaranteed delivery (TCP-like)
"unreliable"   — may be lost (UDP-like, faster)

# Combined:
@rpc("authority", "reliable")    — server sends reliably
@rpc("any_peer", "unreliable")   — anyone sends fast
```

### Common RPC Pattern
```gdscript
# Server-authoritative movement
extends CharacterBody2D

@export var speed := 200.0
var input_direction := Vector2.ZERO

func _physics_process(delta: float) -> void:
    if is_multiplayer_authority():
        # Server: apply movement
        velocity = input_direction * speed
        move_and_slide()
    else:
        # Client: send input to server
        send_input.rpc_id(1, input_direction)

@rpc("any_peer", "unreliable")
func send_input(direction: Vector2) -> void:
    var sender := multiplayer.get_remote_sender_id()
    # Validate and apply
    input_direction = direction
```

## MultiplayerSpawner & MultiplayerSynchronizer

### MultiplayerSpawner
```
# Automatically spawns/despawns nodes across peers

MultiplayerSpawner
├── Spawnable Scenes: [player.tscn, enemy.tscn]
└── Spawn Path: /root/Game/Players

# Spawn a player
func spawn_player(id: int) -> void:
    var player := player_scene.instantiate()
    player.name = str(id)
    player.set_multiplayer_authority(id)
    $Players.add_child(player, true)
```

### MultiplayerSynchronizer
```
# Automatically syncs properties across peers

MultiplayerSynchronizer
├── Root Path: .. (parent node)
├── Synced Properties:
│   - position
│   - velocity
│   - health
│   - current_animation
├── Sync Mode: Always (or On Change)
└── Visibility: All Peers (or specific)
```

### Full Player Setup
```gdscript
extends CharacterBody2D

@onready var synchronizer := $MultiplayerSynchronizer
@onready var sprite := $Sprite2D

@export var speed := 200.0

func _ready() -> void:
    # Set authority
    set_multiplayer_authority(name.to_int())

    if is_multiplayer_authority():
        # This is our player
        sprite.modulate = Color.GREEN
    else:
        # Remote player
        sprite.modulate = Color.RED

func _physics_process(delta: float) -> void:
    if not is_multiplayer_authority():
        return

    var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
    velocity = direction * speed
    move_and_slide()

    # Synchronizer automatically syncs position and velocity
```

## Lobby System

### Lobby Manager
```gdscript
# lobby_manager.gd — Autoload
extends Node

signal player_joined(player_info: Dictionary)
signal player_left(player_id: int)
signal game_starting

var players: Dictionary = {}  # { peer_id: { name, color, ready } }
var is_host := false

func _ready() -> void:
    multiplayer.peer_connected.connect(_on_peer_connected)
    multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func host_lobby(player_name: String) -> void:
    is_host = true
    var peer := ENetMultiplayerPeer.new()
    peer.create_server(9999, 4)
    multiplayer.multiplayer_peer = peer

    players[1] = {"name": player_name, "color": Color.WHITE, "ready": true}
    player_joined.emit(players[1])

func join_lobby(address: String, player_name: String) -> void:
    is_host = false
    var peer := ENetMultiplayerPeer.new()
    peer.create_client(address, 9999)
    multiplayer.multiplayer_peer = peer

@rpc("any_peer", "reliable")
func register_player(player_info: Dictionary) -> void:
    var id := multiplayer.get_remote_sender_id()
    players[id] = player_info
    player_joined.emit(player_info)

@rpc("any_peer", "reliable")
func set_ready(ready: bool) -> void:
    var id := multiplayer.get_remote_sender_id()
    if players.has(id):
        players[id].ready = ready

func _on_peer_connected(id: int) -> void:
    # Send our info to the new peer
    register_player.rpc_id(id, players[1])

func _on_peer_disconnected(id: int) -> void:
    players.erase(id)
    player_left.emit(id)

func can_start_game() -> bool:
    if not is_host:
        return false
    for player in players.values():
        if not player.ready:
            return false
    return players.size() >= 1  # minimum players

@rpc("authority", "reliable")
func start_game() -> void:
    game_starting.emit()
    get_tree().change_scene_to_file("res://scenes/world/game_level.tscn")
```

## State Synchronization

### Manual Sync
```gdscript
# Sync game state manually
extends Node

@rpc("authority", "reliable")
func sync_game_state(state: Dictionary) -> void:
    # Apply state to all nodes
    apply_state(state)

@rpc("authority", "unreliable")
func sync_entity_state(entity_id: String, position: Vector2, velocity: Vector2) -> void:
    var entity := get_node_or_null(entity_id)
    if entity:
        # Interpolate for smooth movement
        entity.target_position = position
        entity.velocity = velocity

# Server sends state periodically
func _on_sync_timer_timeout() -> void:
    if not multiplayer.is_server():
        return

    var state := collect_game_state()
    sync_game_state.rpc(state)

    for entity in get_tree().get_nodes_in_group("synced"):
        sync_entity_state.rpc(
            entity.get_path(),
            entity.global_position,
            entity.velocity
        )
```

### Interpolation
```gdscript
extends CharacterBody2D

var target_position := Vector2.ZERO
var interpolation_speed := 10.0

func _physics_process(delta: float) -> void:
    if not is_multiplayer_authority():
        # Interpolate to target
        global_position = global_position.lerp(target_position, interpolation_speed * delta)
```

## Lag Compensation

### Client-Side Prediction
```gdscript
extends CharacterBody2D

var input_history: Array[Dictionary] = []
var server_position := Vector2.ZERO

func _physics_process(delta: float) -> void:
    if is_multiplayer_authority():
        var direction := Input.get_vector("left", "right", "up", "down")
        velocity = direction * speed
        move_and_slide()

        # Store input for reconciliation
        input_history.append({
            "direction": direction,
            "position": global_position,
            "frame": Engine.get_physics_frames()
        })

@rpc("authority", "reliable")
func reconcile(server_pos: Vector2, server_frame: int) -> void:
    # Find the input that matches the server frame
    var input_index := -1
    for i in input_history.size():
        if input_history[i].frame == server_frame:
            input_index = i
            break

    if input_index < 0:
        return

    # Check if we need correction
    var error := global_position.distance_to(server_pos)
    if error > 5.0:  # threshold
        # Correct position and replay inputs
        global_position = server_pos
        for i in range(input_index + 1, input_history.size()):
            var input := input_history[i]
            velocity = input.direction * speed
            move_and_slide()

    # Clear old history
    input_history = input_history.slice(max(0, input_index - 10))
```

## Network Best Practices

1. **Server-authoritative** — server validates all actions
2. **Use RPC for events** — actions, chat, game events
3. **Use Synchronizer for state** — position, health, animation
4. **Interpolate remote entities** — smooth movement
5. **Validate on server** — prevent cheating
6. **Use unreliable for frequent updates** — position, velocity
7. **Use reliable for important events** — damage, death, score
8. **Minimize bandwidth** — only sync what changes
9. **Test with simulated lag** — add artificial latency
10. **Handle disconnections gracefully** — cleanup, reconnect

## Verification Checklist
- [ ] MultiplayerAPI configured
- [ ] Server/client connection working
- [ ] RPCs defined with correct authority
- [ ] MultiplayerSpawner for dynamic objects
- [ ] MultiplayerSynchronizer for state
- [ ] Lobby system functional
- [ ] Input sent from client, processed on server
- [ ] Remote entities interpolated
- [ ] Disconnection handling
