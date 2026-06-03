---
name: godot-shaders
description: "Write Godot shaders for visual effects including 2D shaders, 3D materials, post-processing, and shader animations. Use when creating custom visual effects, dissolve effects, outlines, water, distortion, or custom lighting."
triggers:
  - "shader"
  - "glsl"
  - "visual effect"
  - "dissolve"
  - "outline"
  - "water"
  - "distortion"
  - "custom material"
  - "shader code"
---

# Godot Shaders

Write shaders for 2D and 3D visual effects.

## Shader Types

### CanvasItem Shader (2D)
```
shader_type canvas_item;

// Applied to Sprite2D, ColorRect, etc.
// UV: (0,0) top-left to (1,1) bottom-right
// VERTEX: screen position
// FRAGMENT: pixel color output
```

### Spatial Shader (3D)
```
shader_type spatial;

// Applied to MeshInstance3D
// UV: mesh UV coordinates
// VERTEX: 3D vertex position
// NORMAL: surface normal
// FRAGMENT: material properties (albedo, metallic, roughness)
// LIGHT: custom lighting calculations
```

### Particle Shader
```
shader_type particles;

// Applied to GPUParticles2D/3D
// Controls particle position, velocity, color over lifetime
```

### Sky Shader
```
shader_type sky;

// Applied to Sky resource
// Custom sky rendering
```

## CanvasItem (2D) Shaders

### Color Tint
```glsl
shader_type canvas_item;

uniform vec4 tint_color : source_color = vec4(1.0, 0.5, 0.0, 1.0);
uniform float mix_amount : hint_range(0.0, 1.0) = 0.5;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    COLOR = mix(tex_color, tint_color, mix_amount);
}
```

### Dissolve Effect
```glsl
shader_type canvas_item;

uniform sampler2D noise_texture;
uniform float dissolve_amount : hint_range(0.0, 1.0) = 0.0;
uniform vec4 edge_color : source_color = vec4(1.0, 0.5, 0.0, 1.0);
uniform float edge_width : hint_range(0.0, 0.1) = 0.02;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    float noise = texture(noise_texture, UV).r;

    // Dissolve threshold
    if (noise < dissolve_amount) {
        discard;
    }

    // Edge glow
    float edge = smoothstep(dissolve_amount, dissolve_amount + edge_width, noise);
    vec4 final_color = mix(edge_color, tex_color, edge);

    COLOR = final_color;
}
```

### Outline
```glsl
shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float outline_width : hint_range(0.0, 10.0) = 2.0;

void fragment() {
    vec2 pixel_size = TEXTURE_PIXEL_SIZE;
    vec4 tex = texture(TEXTURE, UV);

    // Sample neighboring pixels
    float a = texture(TEXTURE, UV + vec2(pixel_size.x * outline_width, 0.0)).a;
    a += texture(TEXTURE, UV - vec2(pixel_size.x * outline_width, 0.0)).a;
    a += texture(TEXTURE, UV + vec2(0.0, pixel_size.y * outline_width)).a;
    a += texture(TEXTURE, UV - vec2(0.0, pixel_size.y * outline_width)).a;

    // If near an edge but not on the sprite itself
    if (tex.a < 0.1 && a > 0.0) {
        COLOR = outline_color;
    } else {
        COLOR = tex;
    }
}
```

### Flash/Hit Effect
```glsl
shader_type canvas_item;

uniform float flash_amount : hint_range(0.0, 1.0) = 0.0;
uniform vec4 flash_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    COLOR = mix(tex_color, flash_color, flash_amount);
}
```

### Water Ripple
```glsl
shader_type canvas_item;

uniform float time_factor : hint_range(0.0, 10.0) = 1.0;
uniform float wave_amplitude : hint_range(0.0, 0.1) = 0.01;
uniform float wave_frequency : hint_range(0.0, 50.0) = 10.0;

void fragment() {
    vec2 uv = UV;
    uv.x += sin(uv.y * wave_frequency + TIME * time_factor) * wave_amplitude;
    uv.y += cos(uv.x * wave_frequency + TIME * time_factor) * wave_amplitude;
    COLOR = texture(TEXTURE, uv);
}
```

### Grayscale
```glsl
shader_type canvas_item;

uniform float grayscale_amount : hint_range(0.0, 1.0) = 1.0;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    float gray = dot(tex.rgb, vec3(0.299, 0.587, 0.114));
    COLOR = mix(tex, vec4(vec3(gray), tex.a), grayscale_amount);
}
```

### Pixelation
```glsl
shader_type canvas_item;

uniform float pixel_size : hint_range(1.0, 64.0) = 8.0;

void fragment() {
    vec2 pixelated_uv = floor(UV * pixel_size) / pixel_size;
    COLOR = texture(TEXTURE, pixelated_uv);
}
```

## Spatial (3D) Shaders

### Custom Albedo
```glsl
shader_type spatial;

uniform vec4 albedo_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform sampler2D albedo_texture;

void fragment() {
    vec4 tex = texture(albedo_texture, UV);
    ALBEDO = albedo_color.rgb * tex.rgb;
    ALPHA = albedo_color.a * tex.a;
}
```

### Hologram
```glsl
shader_type spatial;

uniform vec4 holo_color : source_color = vec4(0.0, 1.0, 1.0, 1.0);
uniform float scan_speed : hint_range(0.0, 10.0) = 2.0;
uniform float scan_lines : hint_range(0.0, 100.0) = 30.0;

void fragment() {
    float scan = sin(VERTEX.y * scan_lines + TIME * scan_speed) * 0.5 + 0.5;
    ALBEDO = holo_color.rgb;
    ALPHA = scan * 0.5;
    EMISSION = holo_color.rgb * scan;
}

// Enable transparency:
// Render: blend_mode = ADD, cull_mode = DISABLED, depth_draw = NEVER
```

### Force Field / Shield
```glsl
shader_type spatial;

uniform vec4 shield_color : source_color = vec4(0.0, 0.5, 1.0, 0.5);
uniform float fresnel_power : hint_range(0.0, 5.0) = 2.0;
uniform float pulse_speed : hint_range(0.0, 10.0) = 3.0;

void fragment() {
    // Fresnel effect (edges glow)
    float fresnel = pow(1.0 - abs(dot(NORMAL, VIEW)), fresnel_power);

    // Pulse
    float pulse = sin(TIME * pulse_speed) * 0.2 + 0.8;

    ALBEDO = shield_color.rgb;
    ALPHA = fresnel * pulse * shield_color.a;
    EMISSION = shield_color.rgb * fresnel * pulse;
}
```

### Dissolve 3D
```glsl
shader_type spatial;

uniform sampler2D noise_texture;
uniform float dissolve_amount : hint_range(0.0, 1.0) = 0.0;
uniform vec4 edge_color : source_color = vec4(1.0, 0.3, 0.0, 1.0);
uniform float edge_width : hint_range(0.0, 0.2) = 0.05;

void fragment() {
    vec4 albedo_tex = texture(albedo_texture, UV);
    float noise = texture(noise_texture, UV).r;

    if (noise < dissolve_amount) {
        discard;
    }

    float edge = smoothstep(dissolve_amount, dissolve_amount + edge_width, noise);
    ALBEDO = mix(edge_color.rgb, albedo_tex.rgb, edge);
    EMISSION = edge_color.rgb * (1.0 - edge) * 2.0;
}
```

### Triplanar Mapping
```glsl
shader_type spatial;

uniform sampler2D top_texture;
uniform sampler2D side_texture;
uniform float blend_sharpness : hint_range(0.1, 8.0) = 2.0;

void fragment() {
    vec3 blend = pow(abs(NORMAL), vec3(blend_sharpness));
    blend /= dot(blend, vec3(1.0));

    vec2 uv_x = VERTEX.zy * 0.5;
    vec2 uv_y = VERTEX.xz * 0.5;
    vec2 uv_z = VERTEX.xy * 0.5;

    vec4 tex_x = texture(side_texture, uv_x);
    vec4 tex_y = texture(top_texture, uv_y);
    vec4 tex_z = texture(side_texture, uv_z);

    ALBEDO = tex_x.rgb * blend.x + tex_y.rgb * blend.y + tex_z.rgb * blend.z;
}
```

## Post-Processing

### Screen-Space Shader (via CanvasLayer)
```glsl
// Apply to a ColorRect covering the screen
shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

// Vignette
uniform float vignette_intensity : hint_range(0.0, 1.0) = 0.5;

void fragment() {
    vec4 color = texture(screen_texture, SCREEN_UV);

    // Vignette
    vec2 center = UV - 0.5;
    float dist = length(center);
    float vignette = smoothstep(0.5, 0.2, dist);
    color.rgb *= mix(1.0, vignette, vignette_intensity);

    COLOR = color;
}
```

### Screen Shake (Shader-based)
```glsl
shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture;
uniform float shake_amount : hint_range(0.0, 0.05) = 0.0;
uniform float shake_speed : hint_range(0.0, 50.0) = 20.0;

void fragment() {
    vec2 uv = SCREEN_UV;
    uv.x += sin(TIME * shake_speed) * shake_amount;
    uv.y += cos(TIME * shake_speed * 1.3) * shake_amount;
    COLOR = texture(screen_texture, uv);
}
```

## Shader Parameters from GDScript

```gdscript
# Set shader parameters
@onready var sprite := $Sprite2D
var material: ShaderMaterial

func _ready() -> void:
    material = sprite.material as ShaderMaterial

func set_dissolve(amount: float) -> void:
    material.set_shader_parameter("dissolve_amount", amount)

func set_flash(amount: float) -> void:
    material.set_shader_parameter("flash_amount", amount)

# Animate dissolve
func dissolve_animation(duration: float = 1.0) -> void:
    var tween := create_tween()
    tween.tween_method(set_dissolve, 0.0, 1.0, duration)
```

## Shader Best Practices

1. **Start simple** — basic effect first, add complexity
2. **Use uniforms** — expose parameters for tweaking
3. **Hint ranges** — `hint_range(min, max)` for sliders in editor
4. **Source color** — `source_color` for color pickers
5. **Avoid branches** — `if/else` is slow on GPU, use `mix/step/smoothstep`
6. **Texture lookups are expensive** — minimize samples
7. **Use built-in variables** — TIME, UV, NORMAL, VERTEX
8. **Test on target hardware** — mobile GPUs are weaker
9. **Comment complex math** — shaders are hard to read
10. **Use visual shader** for prototyping — convert to code later

## Verification Checklist
- [ ] Shader type correct (canvas_item for 2D, spatial for 3D)
- [ ] Uniforms exposed with proper hints
- [ ] Tested on target platform performance
- [ ] Shader parameters settable from GDScript
- [ ] Visual effects match design intent
- [ ] No visual artifacts at edges/corners
