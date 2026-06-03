---
name: godot-audio
description: "Implement game audio including music, SFX, spatial audio, audio buses, and dynamic audio systems. Use when adding sound effects, background music, ambient sounds, audio mixing, or procedural audio."
triggers:
  - "audio"
  - "sound"
  - "music"
  - "sfx"
  - "audio bus"
  - "spatial audio"
  - "audio player"
  - "volume"
  - "sound effect"
---

# Godot Audio

Implement complete audio systems for games.

## Audio Nodes

### AudioStreamPlayer (Non-positional)
- For: music, UI sounds, narration
- No spatial positioning
- Plays globally

### AudioStreamPlayer2D
- For: 2D positional sounds
- Volume/pan changes with distance
- Requires 2D scene tree

### AudioStreamPlayer3D
- For: 3D positional sounds
- Full spatial audio (distance, direction)
- Doppler effect support

## Basic Audio Playback

### AudioStreamPlayer
```gdscript
extends AudioStreamPlayer

func _ready() -> void:
    stream = preload("res://audio/music/theme.ogg")
    volume_db = -10.0
    bus = "Music"
    autoplay = false

func play_music() -> void:
    play()

func stop_music() -> void:
    stop()

func fade_in(duration: float = 1.0) -> void:
    volume_db = -80.0
    play()
    var tween := create_tween()
    tween.tween_property(self, "volume_db", 0.0, duration)

func fade_out(duration: float = 1.0) -> void:
    var tween := create_tween()
    tween.tween_property(self, "volume_db", -80.0, duration)
    await tween.finished
    stop()
```

### One-shot SFX
```gdscript
# Simple SFX player
func play_sfx(audio: AudioStream, volume: float = 0.0) -> void:
    var player := AudioStreamPlayer.new()
    player.stream = audio
    player.volume_db = volume
    player.bus = "SFX"
    player.finished.connect(player.queue_free)
    add_child(player)
    player.play()

# Usage
play_sfx(preload("res://audio/sfx/explosion.wav"))
play_sfx(preload("res://audio/sfx/pickup.wav"), -5.0)
```

### SFX with Variation
```gdscript
@export var sfx_variants: Array[AudioStream] = []
@export var pitch_range := Vector2(0.9, 1.1)

func play_random_sfx() -> void:
    if sfx_variants.is_empty():
        return

    var player := AudioStreamPlayer.new()
    player.stream = sfx_variants.pick_random()
    player.pitch_scale = randf_range(pitch_range.x, pitch_range.y)
    player.volume_db = randf_range(-2.0, 0.0)
    player.bus = "SFX"
    player.finished.connect(player.queue_free)
    add_child(player)
    player.play()
```

## Audio Buses

### Bus Architecture
```
Master
├── Music
│   └── Background music, menu music
├── SFX
│   └── Sound effects, UI sounds
├── Ambient
│   └── Environmental sounds, wind, rain
└── Voice
    └── Dialog, narration
```

### Audio Bus in Code
```gdscript
# Get bus index
var music_bus := AudioServer.get_bus_index("Music")

# Set volume (in dB)
AudioServer.set_bus_volume_db(music_bus, -10.0)

# Mute/unmute
AudioServer.set_bus_mute(music_bus, true)

# Get current volume
var vol := AudioServer.get_bus_volume_db(music_bus)

# Linear volume (0.0 to 1.0)
var linear_vol := db_to_linear(vol)
AudioServer.set_bus_volume_db(music_bus, linear_to_db(0.5))  # 50%
```

### Audio Bus Effects
```gdscript
# Add reverb to bus
var bus_idx := AudioServer.get_bus_index("Ambient")
var reverb := AudioEffectReverb.new()
reverb.room_size = 0.8
reverb.damping = 0.5
reverb.wet = 0.3
AudioServer.add_bus_effect(bus_idx, reverb)

# Add EQ
var eq := AudioEffectEQ10.new()
eq.set_band_gain_db(0, -5.0)  # reduce bass
AudioServer.add_bus_effect(bus_idx, eq)

# Add compressor
var compressor := AudioEffectCompressor.new()
compressor.threshold = -10.0
compressor.ratio = 4.0
AudioServer.add_bus_effect(bus_idx, compressor)
```

## Audio Manager (Autoload)

```gdscript
# audio_manager.gd — Autoload singleton
extends Node

@onready var music_player := AudioStreamPlayer.new()
@onready var ambient_player := AudioStreamPlayer.new()

var sfx_pool: Array[AudioStreamPlayer] = []
var pool_size := 10

func _ready() -> void:
    music_player.bus = "Music"
    music_player.process_mode = Node.PROCESS_MODE_ALWAYS
    add_child(music_player)

    ambient_player.bus = "Ambient"
    add_child(ambient_player)

    # Create SFX pool
    for i in pool_size:
        var player := AudioStreamPlayer.new()
        player.bus = "SFX"
        player.finished.connect(_on_sfx_finished.bind(player))
        add_child(player)
        sfx_pool.append(player)

# --- Music ---
func play_music(stream: AudioStream, fade_time: float = 1.0) -> void:
    if music_player.stream == stream and music_player.playing:
        return

    if music_player.playing:
        await fade_out(music_player, fade_time)

    music_player.stream = stream
    music_player.volume_db = -80.0
    music_player.play()
    await fade_in(music_player, fade_time)

func stop_music(fade_time: float = 1.0) -> void:
    await fade_out(music_player, fade_time)
    music_player.stop()

# --- SFX ---
func play_sfx(stream: AudioStream, volume_db: float = 0.0, pitch: float = 1.0) -> void:
    for player in sfx_pool:
        if not player.playing:
            player.stream = stream
            player.volume_db = volume_db
            player.pitch_scale = pitch
            player.play()
            return

    # All busy, create temporary
    var temp := AudioStreamPlayer.new()
    temp.bus = "SFX"
    temp.stream = stream
    temp.volume_db = volume_db
    temp.pitch_scale = pitch
    temp.finished.connect(temp.queue_free)
    add_child(temp)
    temp.play()

func _on_sfx_finished(player: AudioStreamPlayer) -> void:
    player.stream = null

# --- Ambient ---
func play_ambient(stream: AudioStream, fade_time: float = 2.0) -> void:
    if ambient_player.stream == stream and ambient_player.playing:
        return
    if ambient_player.playing:
        await fade_out(ambient_player, fade_time)
    ambient_player.stream = stream
    ambient_player.volume_db = -80.0
    ambient_player.play()
    await fade_in(ambient_player, fade_time)

# --- Utilities ---
func fade_in(player: AudioStreamPlayer, duration: float) -> void:
    var tween := create_tween()
    tween.tween_property(player, "volume_db", 0.0, duration)

func fade_out(player: AudioStreamPlayer, duration: float) -> void:
    var tween := create_tween()
    tween.tween_property(player, "volume_db", -80.0, duration)
    await tween.finished

# --- Volume Control ---
func set_master_volume(linear: float) -> void:
    var bus := AudioServer.get_bus_index("Master")
    AudioServer.set_bus_volume_db(bus, linear_to_db(clampf(linear, 0.0, 1.0)))

func set_music_volume(linear: float) -> void:
    var bus := AudioServer.get_bus_index("Music")
    AudioServer.set_bus_volume_db(bus, linear_to_db(clampf(linear, 0.0, 1.0)))

func set_sfx_volume(linear: float) -> void:
    var bus := AudioServer.get_bus_index("SFX")
    AudioServer.set_bus_volume_db(bus, linear_to_db(clampf(linear, 0.0, 1.0)))
```

## Spatial Audio (2D)

### AudioStreamPlayer2D
```gdscript
extends AudioStreamPlayer2D

@export var max_distance := 500.0
@export var attenuation := 2.0

func _ready() -> void:
    stream = preload("res://audio/sfx/door_open.wav")
    bus = "SFX"

    # Distance settings
    max_distance = max_distance
    attenuation = attenuation  # higher = faster falloff

    # Area mask (which listeners can hear this)
    area_mask = 1

func play_sound() -> void:
    play()
```

### Area-based Audio (Reverb Zones)
```gdscript
extends Area2D

@export var reverb_preset: AudioEffectReverb

func _ready() -> void:
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
    if body is Player:
        # Enable reverb on SFX bus
        var bus := AudioServer.get_bus_index("SFX")
        var reverb := AudioEffectReverb.new()
        reverb.room_size = 0.9
        reverb.wet = 0.4
        AudioServer.add_bus_effect(bus, reverb)

func _on_body_exited(body: Node2D) -> void:
    if body is Player:
        var bus := AudioServer.get_bus_index("SFX")
        AudioServer.remove_bus_effect(bus, AudioServer.get_bus_effect_count(bus) - 1)
```

## Spatial Audio (3D)

### AudioStreamPlayer3D
```gdscript
extends AudioStreamPlayer3D

func _ready() -> void:
    stream = preload("res://audio/sfx/waterfall.wav")
    bus = "Ambient"

    # Distance model
    attenuation_model = ATTENUATION_INVERSE_DISTANCE
    max_distance = 20.0
    unit_size = 10.0

    # Doppler
    doppler_tracking = DOPPLER_TRACKING_PHYSICS_STEP

    # Area mask
    area_mask = 1

    autoplay = true
```

## Music System

### Dynamic Music Layers
```gdscript
extends Node

@export var base_layer: AudioStream
@export var action_layer: AudioStream
@export var ambient_layer: AudioStream

@onready var base_player := $BaseLayer
@onready var action_player := $ActionLayer
@onready var ambient_player := $AmbientLayer

func _ready() -> void:
    base_player.stream = base_layer
    action_player.stream = action_layer
    ambient_player.stream = ambient_layer

    # Start all synced
    base_player.play()
    action_player.play()
    ambient_player.play()

    # Mute layers initially
    action_player.volume_db = -80.0
    ambient_player.volume_db = -80.0

func set_intensity(intensity: float) -> void:
    # intensity: 0.0 (calm) to 1.0 (action)
    var tween := create_tween().set_parallel(true)

    # Crossfade between layers
    tween.tween_property(base_player, "volume_db",
        linear_to_db(1.0 - intensity * 0.5), 1.0)
    tween.tween_property(action_player, "volume_db",
        linear_to_db(intensity), 1.0)
    tween.tween_property(ambient_player, "volume_db",
        linear_to_db(0.5 - intensity * 0.3), 1.0)
```

## Audio Best Practices

1. **Use OGG for music** — smaller file size, streaming support
2. **Use WAV for SFX** — instant playback, no decode latency
3. **Pool SFX players** — don't create/destroy constantly
4. **Use audio buses** — separate Music, SFX, Ambient, Voice
5. **Add variation** — pitch randomization, multiple variants
6. **Fade transitions** — never hard-cut music
7. **Spatial audio for immersion** — 2D/3D players for positional sounds
8. **Volume settings** — expose Master, Music, SFX sliders
9. **Process mode = ALWAYS** — for music that plays during pause
10. **Test with headphones** — spatial audio sounds different

## Verification Checklist
- [ ] Audio buses configured (Master, Music, SFX, Ambient)
- [ ] Music player with fade in/out
- [ ] SFX pool for one-shot sounds
- [ ] Volume settings UI connected to bus volumes
- [ ] Spatial audio for positional sounds
- [ ] Audio plays during pause (process_mode = ALWAYS)
- [ ] Sound variation (pitch, volume randomization)
