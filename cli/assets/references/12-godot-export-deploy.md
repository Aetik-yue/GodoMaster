---
name: godot-export-deploy
description: "Export and deploy Godot games to multiple platforms. Use when configuring export presets, building for Windows/Mac/Linux/Web/Mobile, optimizing builds, setting up CI/CD, or handling platform-specific requirements."
triggers:
  - "export"
  - "build"
  - "deploy"
  - "publish"
  - "release"
  - "platform"
  - "web build"
  - "android"
  - "ios"
  - "steam"
  - "itch.io"
---

# Godot Export & Deploy

Export games to all supported platforms.

## Export Presets Setup

### Creating Export Presets
```
1. Project → Export
2. Add preset → choose platform
3. Configure settings for each platform
4. Export Project (or Export PCK/ZIP)
```

### Required Export Templates
```
# Download from: https://godotengine.org/download
# Or via editor: Editor → Manage Export Templates

Templates needed per platform:
- Windows Desktop (x86_64)
- macOS Universal
- Linux/X11 (x86_64)
- Web (HTML5)
- Android
- iOS
```

## Platform: Windows

### Export Settings
```
Custom Template → Debug: windows_debug_x86_64.exe
Custom Template → Release: windows_release_x86_64.exe

Options:
- Embed PCK: true (single .exe file)
- Console Wrapper: false (hide console for release)
- Icon: game_icon.ico
- Code Signing: configure for distribution
- Application → Modify Resources: true
```

### Windows Export Checklist
- [ ] Icon set (.ico format, 256x256)
- [ ] Console disabled for release
- [ ] PCK embedded for single-file distribution
- [ ] Tested on clean Windows install
- [ ] Antivirus false positive check

## Platform: macOS

### Export Settings
```
Custom Template → Debug: macos_debug
Custom Template → Release: macos_release

Options:
- Bundle Identifier: com.company.gamename
- Icon: game_icon.icns
- Code Signing: Apple Developer ID
- Notarization: required for distribution
```

### macOS Export Checklist
- [ ] Bundle ID set
- [ ] Icon (.icns format)
- [ ] Code signing configured
- [ ] Notarized for Gatekeeper
- [ ] Tested on macOS without dev tools

## Platform: Linux

### Export Settings
```
Custom Template → Debug: linux_debug.x86_64
Custom Template → Release: linux_release.x86_64

Options:
- Binary Format: Executable
- Icon: PNG/SVG
```

### Linux Export Checklist
- [ ] Executable permissions set
- [ ] Dependencies documented (if any)
- [ ] Tested on Ubuntu/Fedora
- [ ] .desktop file for integration

## Platform: Web (HTML5)

### Export Settings
```
Custom Template → Debug: web_debug.zip
Custom Template → Release: web_release.zip

Options:
- HTML Shell: default or custom
- Head Include: custom meta tags
- Canvas Resize Policy: Project
- Focus Canvas on Start: true
- Experimental Virtual Keyboard: true (for mobile web)
```

### Web Export Checklist
- [ ] Tested in Chrome, Firefox, Safari
- [ ] Mobile browser tested
- [ ] Loading screen configured
- [ ] SharedArrayBuffer headers (for threads)
- [ ] File size optimized (< 50MB ideal)

### Web Hosting
```
# itch.io
1. Export as HTML5
2. Zip the output
3. Upload to itch.io project page
4. Set viewport size in embed options

# GitHub Pages
1. Export HTML5
2. Push to gh-pages branch
3. Enable GitHub Pages in repo settings

# Custom server
1. Export HTML5
2. Upload to web server
3. Ensure correct MIME types:
   .wasm → application/wasm
   .pck → application/octet-stream
```

## Platform: Android

### Prerequisites
- Android SDK installed
- JDK 17 installed
- Godot Android build template
- keystore for signing

### Export Settings
```
Options:
- Keystore: path to debug/release keystore
- Package → Unique Name: com.company.gamename
- Package → Version: 1.0.0
- Graphics → OpenGL: ES 3.0 or ES 2.0
- Screen → Orientation: Portrait or Landscape
- Screen → Immersive Mode: true
```

### Android Export Checklist
- [ ] SDK and JDK configured in Editor Settings
- [ ] Keystore created (debug + release)
- [ ] Package name unique
- [ ] Permissions declared
- [ ] Tested on physical device
- [ ] APK/AAB size optimized

## Platform: iOS

### Prerequisites
- macOS with Xcode
- Apple Developer account
- Provisioning profiles and certificates

### Export Settings
```
Options:
- Bundle Identifier: com.company.gamename
- Team ID: Apple Developer Team ID
- Icon: all required sizes
- Launch Screen: configured
```

## Build Optimization

### PCK Size Reduction
```
# Project Settings
rendering/textures/vram_compression/import_etc2_astc → true (Android)
rendering/textures/vram_compression/import_s3tc_bptc → true (Desktop)

# Import settings per texture:
- Compress mode: VRAM (lossy) for most textures
- Size limit: reduce max texture size
- Mipmaps: disable for 2D pixel art
```

### Removing Unused Resources
```
1. Editor → Project → Tools → Orphan Resources Explorer
2. Delete unused resources
3. Clean .godot/imported folder
4. Re-export
```

### Debug vs Release Builds
```
# Debug builds:
- Include debug symbols
- Larger file size
- Console output visible
- Profiler works

# Release builds:
- Stripped debug symbols
- Smaller file size
- No console
- Better performance
```

## CI/CD Pipeline

### GitHub Actions for Godot
```yaml
# .github/workflows/build.yml
name: Build and Export

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  export:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Godot Export
        uses: firebelley/godot-export@v5.0.0
        with:
          godot_executable_download_url: https://github.com/godotengine/godot/releases/download/4.3-stable/Godot_v4.3-stable_linux.x86_64.zip
          export_debug: false
          relative_project_path: ./
          cache: true

      - name: Upload Artifacts
        uses: actions/upload-artifact@v4
        with:
          name: builds
          path: builds/
```

## Distribution Platforms

### Steam
```
1. Create Steamworks account
2. Set up app on Steamworks
3. Export for Windows/Mac/Linux
4. Upload via SteamPipe
5. Configure depot structure
6. Set release date/price
7. Steam Deck verification (optional)
```

### itch.io
```
1. Create itch.io account
2. Create new project
3. Upload builds for each platform
4. Set pricing (free or paid)
5. Configure embed settings (for HTML5)
6. Add screenshots and description
```

### Google Play
```
1. Google Play Console account
2. Export AAB (Android App Bundle)
3. Upload to internal testing track
4. Fill store listing
5. Content rating questionnaire
6. Set pricing and distribution
7. Submit for review
```

### App Store
```
1. Apple Developer account
2. Export via Xcode
3. App Store Connect
4. Upload build
5. Store listing and screenshots
6. Submit for review
```

## Export Best Practices

1. **Test exports early** — don't wait until the end
2. **Separate debug/release configs** — different settings for each
3. **Optimize textures** — VRAM compression for target platform
4. **Remove unused resources** — smaller builds
5. **Platform-specific input** — touch for mobile, gamepad for console
6. **Version your builds** — use semantic versioning
7. **Automate with CI/CD** — GitHub Actions or similar
8. **Test on target hardware** — not just the development machine
9. **Check file sizes** — mobile users care about download size
10. **Read platform guidelines** — each store has requirements

## Verification Checklist
- [ ] Export templates installed
- [ ] Export presets configured for target platforms
- [ ] Icons set for all platforms
- [ ] Tested export on each target platform
- [ ] Build size optimized
- [ ] CI/CD pipeline configured (optional)
- [ ] Store listing prepared (screenshots, description)
- [ ] Version number set
