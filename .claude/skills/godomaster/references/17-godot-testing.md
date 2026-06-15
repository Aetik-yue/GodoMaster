---
name: godot-testing
description: "Configure and write unit, integration, and E2E tests for Godot 4.x. Use when setting up GdUnit4, writing tests for GDScript classes or scenes, automating gameplay tests, or configuring CI/CD testing pipelines."
triggers:
  - "testing"
  - "unit test"
  - "gdunit"
  - "gdunit4"
  - "integration test"
  - "assert"
  - "test suite"
  - "ci test"
---

# Godot Testing & Automation

Implement robust testing workflows for Godot 4.x games using unit testing, integration testing, and automated E2E setups.

## GdUnit4 Unit Testing

**GdUnit4** is the community-standard unit testing framework for Godot 4.x. It supports writing unit tests, scene tests, mocking, and command-line execution.

### Installation
1. Search for **GdUnit4** in the AssetLib tab inside the Godot editor, or download it from GitHub.
2. Enable the plugin under **Project Settings → Plugins**.
3. A new "GdUnit" dock will appear in the editor bottom panel.

### Basic Test Suite Structure
Test scripts must extend `GdUnitTestSuite` and are generally stored in a `test/` directory.

```gdscript
# test/unit/test_health_component.gd
# Note: Do not define a class_name for test suites to prevent naming collisions.
extends GdUnitTestSuite

const HealthComponentScene = preload("res://scenes/components/health_component.tscn")

var health_comp: HealthComponent

# Runs once before the suite starts
func before() -> void:
    pass

# Runs before each test case
func before_test() -> void:
    health_comp = HealthComponentScene.instantiate()
    add_child(health_comp)

# Runs after each test case
func after_test() -> void:
    if is_instance_valid(health_comp):
        health_comp.queue_free()

# Runs once after all tests in the suite finish
func after() -> void:
    pass

# Test cases must start with the prefix 'test_'
func test_initial_health() -> void:
    assert_int(health_comp.current_health).is_equal(100)

func test_take_damage() -> void:
    health_comp.take_damage(30)
    assert_int(health_comp.current_health).is_equal(70)
    assert_bool(health_comp.current_health < 100).is_true()

func test_take_fatal_damage_emits_died() -> void:
    # Monitor signals
    var monitor := monitor_signals(health_comp)
    
    health_comp.take_damage(100)
    
    # Assert signal was emitted
    await assert_signal(monitor).is_emitted("died")
    assert_int(health_comp.current_health).is_equal(0)
```

### Common Assertions in GdUnit4
```gdscript
# Booleans & Values
assert_bool(val).is_true()
assert_bool(val).is_false()
assert_bool(val).is_not_equal(other)

# Numbers
assert_int(health).is_greater(0)
assert_int(health).is_between(0, 100)
assert_float(pos_x).is_equal_approx(3.14, 0.01)

# Objects & Nodes
assert_object(player).is_not_null()
assert_object(player).is_instanceof(Player)

# Arrays & Dictionaries
assert_array(inventory).has_size(5)
assert_array(inventory).contains(["sword", "shield"])

# Files (4.4+ era GdUnit4)
assert_file("res://save.dat").exists()
assert_file("res://save.dat").is_empty()

# Fluent assertions
assert_that(health).is_between(0, 100)
```

### Parameterized Tests (4.4+ era GdUnit4)

Run the same test with different inputs for data-driven testing.

```gdscript
# Each set of parameters creates a separate test case
@test_params([
    [10, 20, 30],   # a=10, b=20, expected=30
    [0, 0, 0],
    [-5, 5, 0],
    [100, -50, 50]
])
func test_addition(a: int, b: int, expected: int) -> void:
    assert_int(a + b).is_equal(expected)
```

### Fuzz Testing

Generate random inputs to find edge cases.

```gdscript
func test_damage_with_fuzz() -> void:
    var fuzz_values := fuzz_int(0, 1000)  # Random ints 0-1000
    for damage in fuzz_values:
        health_comp.take_damage(damage)
        assert_int(health_comp.current_health).is_between(0, health_comp.max_health)
        health_comp.heal(health_comp.max_health)  # Reset for next iteration
```

### Spy vs Mock

```gdscript
# Spy: monitors real object, tracks method calls
var real_db := Database.new()
var spy_db := spy(real_db)
# Real methods still execute, but calls are recorded

# Mock: creates a fake object, no real logic
var mock_db := mock(Database)
# No real methods execute, you configure return values
do_return(true).on(mock_db).save(any_string(), any())
```

---

## Scene & Integration Testing

Testing scene interactions, physics, and complex nodes requires running tests in the scene tree.

### Spawning Scenes and Simulating Time
When testing scenes that use timers, animation, or physics, use `auto_free()` and physics/process frames simulation.

```gdscript
# test/integration/test_player_movement.gd
extends GdUnitTestSuite

const PlayerScene = preload("res://scenes/actors/player.tscn")

func test_gravity_falls_player() -> void:
    # auto_free ensures the instanced node is freed after the test finishes
    var player: Player = auto_free(PlayerScene.instantiate())
    add_child(player)
    
    # Set starting position high in the air
    player.global_position = Vector2(100, 0)
    
    var initial_y = player.global_position.y
    
    # Wait for 10 physics frames to let gravity take effect
    await await_physics_frames(10)
    
    # Verify player fell downward
    assert_float(player.global_position.y).is_greater(initial_y)
```

### Mocking and Double Objects
Mocking lets you isolate components from their dependencies (e.g., mock a network request or database call).

```gdscript
func test_player_save_database() -> void:
    # Create a mock of a Database resource class
    var mock_db: Database = mock(Database)
    
    # Configure mock behavior
    do_return(true).on(mock_db).save_user_data(any_string(), any_int())
    
    # Pass mock into test class (Dependency Injection)
    var player_saver = PlayerSaver.new(mock_db)
    var success = player_saver.save("Player1", 100)
    
    # Assert return and verify call happened
    assert_bool(success).is_true()
    verify(mock_db, 1).save_user_data("Player1", 100)
```

---

## E2E Testing & PlayGodot Automation

For complex user flows (menus, dialogue trees, boss fights), End-to-End (E2E) testing simulates real user inputs.

### PlayGodot Automation
**PlayGodot** (by Randroids Dojo) allows external scripts or internal automation loops to run the game and simulate inputs via the `RemoteDebugger` protocol.

#### Basic Input Simulation Pattern
If using custom runners or built-in input simulation:
```gdscript
# Simulating input actions dynamically in code
func simulate_key_press(action_name: String) -> void:
    var event := InputEventAction.new()
    event.action = action_name
    event.pressed = true
    Input.parse_input_event(event)
    
    # Wait for a frame to process the input event
    await get_tree().process_frame
    
    event.pressed = false
    Input.parse_input_event(event)
```

For advanced E2E automation, you can boot Godot with a custom flag (e.g., `--remote-debug`) and interact with the game state using TCP connections to inspect the Scene Tree remotely.

---

## Headless CLI and CI/CD Pipelines

To prevent regressions, run your GdUnit4 test suite in your CI/CD workflow.

### Running Tests Headlessly via Command Line
Execute the command from your project root:
```bash
# Godot 4.x headless execution
godot --headless --path . -s addons/gdUnit4/bin/GdUnitCmdTool.gd --run-tests
```
You can append arguments to generate JUnit reports:
```bash
godot --headless --path . -s addons/gdUnit4/bin/GdUnitCmdTool.gd --run-tests --report-format junit --report-path ./reports
```

### GitHub Actions Workflow Configuration
Create `.github/workflows/test.yml` to automatically run tests on every push:

```yaml
name: Run GdUnit4 Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Cache Godot Templates
        uses: actions/cache@v4
        with:
          path: ~/.local/share/godot
          key: godot-templates-${{ runner.os }}

      - name: Setup Godot (Linux Headless)
        run: |
          wget https://github.com/godotengine/godot/releases/download/4.4.1-stable/Godot_v4.4.1-stable_linux.x86_64.zip
          unzip Godot_v4.4.1-stable_linux.x86_64.zip
          sudo mv Godot_v4.4.1-stable_linux.x86_64 /usr/local/bin/godot
          chmod +x /usr/local/bin/godot

      - name: Run Tests
        run: |
          godot --headless --path . -s addons/gdUnit4/bin/GdUnitCmdTool.gd --run-tests
```

---

## Verification Checklist
- [ ] GdUnit4 plugin is installed and active in settings
- [ ] Test files follow `test_*.gd` naming convention
- [ ] Test methods start with `test_`
- [ ] Instantiated nodes are disposed of using `auto_free()` or `queue_free()` in `after_test()`
- [ ] Signals are monitored and asserted correctly
- [ ] Headless test command succeeds in the terminal
- [ ] GdUnit4 version matches Godot 4.x version
- [ ] Parameterized tests used for data-driven scenarios
- [ ] CI pipeline uses latest stable Godot for testing
