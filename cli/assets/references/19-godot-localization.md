---
name: godot-localization
description: "Localize games with tr(), TranslationServer, .po/.csv import, pseudolocalization, and plural rules. Use when adding multi-language support, translating UI text, managing locales, or testing localization."
triggers:
  - "localization"
  - "i18n"
  - "translation"
  - "locale"
  - "tr"
  - "language"
  - "plural"
  - "pseudolocalization"
  - "po file"
  - "rtl"
---

# Godot Localization

Localize your game for global audiences with Godot's built-in internationalization system.

## Translation Basics

### The `tr()` Function

Godot provides `tr()` (translate) as a method on every `Object`. It looks up the current locale's translation for a given key.

```gdscript
# Basic usage — key is the lookup string
label.text = tr("KEY_GREETING")

# If no translation exists for the current locale, the key itself is returned
# So using English text as the key works as a fallback:
label.text = tr("Hello, World!")
```

> **Best Practice:** Use descriptive keys (e.g., `KEY_GREETING`) rather than English text as keys. English text keys break when you need to change the source string without breaking existing translations.

### Message Hashing

Godot hashes translation keys using MD5 internally. For `.po` files, the `msgctxt` field can differentiate identical keys in different contexts.

```gdscript
# Same key, different contexts
label_weapon.text = tr("Sword")  # weapon name
label_title.text = tr("Sword")  # chapter title
# In .po files, use msgctxt to disambiguate:
# msgctxt "weapon"
# msgid "Sword"
# msgstr "剑"
#
# msgctxt "chapter"
# msgid "Sword"
# msgstr "剑之章"
```

---

## TranslationServer API

`TranslationServer` is the singleton that manages all translations and locale information.

### Core Methods

```gdscript
# Set the current locale
TranslationServer.set_locale("zh_CN")

# Get the current locale
var current := TranslationServer.get_locale()  # "zh_CN"

# Get the display name of a locale
var name := TranslationServer.get_locale_name("ja_JP")  # "Japanese"

# Translate a key (same as tr() but callable without an Object)
var text := TranslationServer.translate("KEY_GREETING")

# Compare locales — returns how similar they are
var sim := TranslationServer.compare_locales("en_US", "en_GB")  # 10 (similar)
var sim2 := TranslationServer.compare_locales("en_US", "zh_CN")  # 0 (different)
```

### Adding Translations at Runtime

```gdscript
# Load and add a .po translation
var translation := load("res://locales/zh_CN.po") as Translation
TranslationServer.add_translation(translation)

# Remove a translation
TranslationServer.remove_translation(translation)

# Clear all translations (rarely needed)
TranslationServer.clear()
```

### Getting Available Locales

```gdscript
# List all locales that have loaded translations
var locales := TranslationServer.get_loaded_locales()
for locale in locales:
    print("%s: %s" % [locale, TranslationServer.get_locale_name(locale)])
```

---

## Importing Translations

### .po File Import

1. Create `.po` files for each locale (e.g., `zh_CN.po`, `ja_JP.po`)
2. Place them in the project (e.g., `res://locales/`)
3. Godot auto-imports `.po` files as `Translation` resources
4. Configure auto-loading in **Project → Project Settings → Internationalization → Locale → Translations**
5. Add `.po` resource paths to the `translations` array

### CSV Import Workflow

CSV files are useful for non-technical translators or spreadsheet-based workflows.

```csv
key,en,zh_CN,ja_JP
KEY_GREETING,Hello,你好,こんにちは
KEY_FAREWELL,Goodbye,再见,さようなら
KEY_SCORE,Score,分数,スコア
```

1. Create a CSV file with the format: `key,lang1,lang2,...`
2. Place it in the project (e.g., `res://locales/translations.csv`)
3. Godot imports the CSV and generates `Translation` resources for each language column
4. On re-import, all generated translations are updated

> **Note:** CSV round-trip with spreadsheets is supported. Edit in Excel/Google Sheets, export as CSV, and Godot re-imports on change.

### Auto-Load from Project Settings

```gdscript
# In Project Settings, configure:
# internationalization/locale/translations = [
#   "res://locales/zh_CN.po",
#   "res://locales/ja_JP.po"
# ]
# internationalization/locale/test = "en"  # fallback locale

# These are loaded automatically at startup — no code needed.
```

---

## Creating .po Files

### Recommended Tools

| Tool | Type | Notes |
|------|------|-------|
| **Poedit** | Desktop app | Free tier, visual editor, plural forms support |
| **Lokalise** | Cloud SaaS | Team collaboration, screenshots, API |
| **Crowdin** | Cloud SaaS | Community translation, GitHub integration |
| **Weblate** | Self-hosted | Open source, Git integration |
| **mo** | CLI tool | Python-based, extraction from GDScript |

### Key Extraction Pattern

```gdscript
# Extract all tr() keys from your project for .pot template generation:
# 1. Use grep or a script to find all tr("KEY") patterns
# 2. Generate a .pot (template) file
# 3. Create per-locale .po files from the template

# Example extraction script (shell):
# grep -roh 'tr("[^"]*")' src/ | sed 's/tr("//;s/")//' | sort -u > keys.txt
```

### .po File Structure

```po
# zh_CN.po
msgid ""
msgstr ""
"Language: zh_CN\n"
"Content-Type: text/plain; charset=UTF-8\n"

msgid "KEY_GREETING"
msgstr "你好"

msgid "KEY_FAREWELL"
msgstr "再见"

# With context
msgctxt "weapon"
msgid "Sword"
msgstr "剑"

# Plural form
msgid "1 enemy"
msgid_plural "%d enemies"
msgstr[0] "%d个敌人"
```

---

## Plural Rules

### `tr_n()` Function

Godot supports plural forms via `tr_n()`, which selects the correct plural form based on the locale's CLDR rules.

```gdscript
# tr_n(singular_key, plural_key, count)
# The count determines which plural form to use
var enemy_count := 3
label.text = tr_n("1 enemy", "%d enemies", enemy_count) % enemy_count

# For Chinese (no plural distinction):
#   "3个敌人" (same form regardless of count)

# For English:
#   count=1 → "1 enemy"
#   count=3 → "3 enemies"

# For Russian (3 plural forms):
#   count=1  → "1 враг"
#   count=3  → "3 врага"
#   count=11 → "11 врагов"
```

### CLDR Plural Categories

| Category | Description | Example Languages |
|----------|-------------|-------------------|
| **zero** | Count is 0 | Arabic, Latvian |
| **one** | Count is 1 | Most languages |
| **two** | Count is 2 | Arabic, Welsh |
| **few** | Small count (2–4, etc.) | Russian, Polish, Czech |
| **many** | Large count | Russian, Polish |
| **other** | Default / fallback | All languages |

### Custom Plural Rules

```gdscript
# Access the plural rule for a locale
var rule := TranslationServer.get_plural_condition("ru")
# Returns a string like: "(n%10==1 && n%100!=11 ? 0 : n%10>=2 && n%10<=4 && (n%100<12 || n%100>14) ? 1 : n%10==0 || (n%10>=5 && n%10<=9) || (n%100>=11 && n%100<=14) ? 2 : 3)"
```

---

## Pseudolocalization (Godot 4.3+)

Pseudolocalization replaces translatable text with fake characters to test UI layout without real translations. This reveals text overflow, truncated labels, and hard-coded strings.

### Project Settings

```
# In Project Settings → Internationalization → Pseudolocalization:
internationalization/pseudolocalization/prefix = "["
internationalization/pseudolocalization/suffix = "]"
internationalization/pseudolocalization/expand_ratio = 0.5  # 50% wider
internationalization/pseudolocalization/fake_bidi = false    # Right-to-left simulation
internationalization/pseudolocalization/override = false     # Override all text (not just tr())
internationalization/pseudolocalization/skip_placeholders = true  # Preserve %s, %d
```

### Enabling at Runtime

```gdscript
# Toggle pseudolocalization
func _on_pseudoloc_toggled(enabled: bool) -> void:
    TranslationServer.pseudolocalization_enabled = enabled

# In _ready() for testing:
TranslationServer.pseudolocalization_enabled = true
# All tr() calls now return pseudolocalized text like:
# "[Héllö Wörld!    ]" (expanded, accented, bracketed)
```

### What Pseudolocalization Catches

| Issue | How Pseudolocalization Reveals It |
|-------|----------------------------------|
| Text overflow | Expanded text clips or wraps incorrectly |
| Hard-coded strings | Untranslated text stays normal while tr() text is pseudolocalized |
| Missing tr() calls | Same as above — shows which labels aren't localized |
| RTL layout issues | `fake_bidi = true` simulates right-to-left text |
| Placeholder breakage | `skip_placeholders = true` ensures %s/%d still work |

---

## Locale Switching at Runtime

### Basic Pattern

```gdscript
# res://scripts/core/locale_manager.gd
extends Node

signal locale_changed(new_locale: String)

var available_locales := ["en", "zh_CN", "ja_JP", "ko_KR"]

func change_locale(locale: String) -> void:
    if locale not in available_locales:
        push_warning("Locale not available: %s" % locale)
        return
    TranslationServer.set_locale(locale)
    locale_changed.emit(locale)
    # Persist the choice
    Config.save_setting("locale", locale)
```

### Refreshing UI on Locale Change

```gdscript
# Option 1: Re-apply all tr() calls when locale changes
# Every UI node listens for the signal:
func _ready() -> void:
    LocaleManager.locale_changed.connect(_on_locale_changed)
    _apply_locale()

func _on_locale_changed(_new_locale: String) -> void:
    _apply_locale()

func _apply_locale() -> void:
    title_label.text = tr("KEY_TITLE")
    start_button.text = tr("KEY_START")
    settings_button.text = tr("KEY_SETTINGS")

# Option 2: Use a notification pattern
# Extend Label to auto-refresh:
class_name LocalizedLabel
extends Label

@export var tr_key: String = ""

func _ready() -> void:
    LocaleManager.locale_changed.connect(_refresh)
    _refresh()

func _refresh() -> void:
    if tr_key != "":
        text = tr(tr_key)
```

### Persisting Locale Preference

```gdscript
# On startup, restore saved locale
func _ready() -> void:
    var saved := Config.get_setting("locale", "") as String
    if saved != "" and saved in available_locales:
        TranslationServer.set_locale(saved)
```

---

## Right-to-Left (RTL) Languages

### BiDi Support

Godot supports bidirectional text (Arabic, Hebrew, Persian) through ICU's BiDi algorithm.

```gdscript
# RTL text is automatically handled by Label/RichTextLabel
# No special code needed — just set the text
arabic_label.text = tr("KEY_ARABIC_TEXT")

# For mixed LTR/RTL text, Godot handles layout automatically
```

### Layout Considerations

```gdscript
# Mirror UI layout for RTL locales
func _on_locale_changed(locale: String) -> void:
    var is_rtl := locale.begins_with("ar") or locale.begins_with("he") or locale.begins_with("fa")
    # Flip horizontal anchors or use layout_direction
    if is_rtl:
        container.layout_direction = Control.LAYOUT_DIRECTION_RTL
    else:
        container.layout_direction = Control.LAYOUT_DIRECTION_LTR

# Or use the auto-detect mode (default):
    container.layout_direction = Control.LAYOUT_DIRECTION_INHERITED
    # This inherits from the parent, and the root uses LOCALE direction
```

### Control Layout Direction

```gdscript
# Per-control override
control.layout_direction = Control.LAYOUT_DIRECTION_LTR  # Force LTR
control.layout_direction = Control.LAYOUT_DIRECTION_RTL  # Force RTL
control.layout_direction = Control.LAYOUT_DIRECTION_LOCALE  # Auto from locale
control.layout_direction = Control.LAYOUT_DIRECTION_INHERITED  # From parent

# Text direction for individual labels
label.text_direction = Control.TEXT_DIRECTION_LTR
label.text_direction = Control.TEXT_DIRECTION_RTL
label.text_direction = Control.TEXT_DIRECTION_AUTO  # Detect from content
```

---

## Best Practices

1. **Use keys, not source strings** — `tr("KEY_GREETING")` not `tr("Hello")`. Changing English shouldn't break translations.
2. **Use `tr()` from day one** — Even if you only support one language, wrapping text in `tr()` makes future localization trivial.
3. **Test with pseudolocalization** — Enable it regularly to catch overflow and missing `tr()` calls.
4. **Provide context comments** — In `.po` files, use translator comments to disambiguate identical keys.
5. **Handle plural forms** — Always use `tr_n()` for countable items, never hard-code "1 item" / "2 items".
6. **Persist locale choice** — Save the player's language preference and restore it on startup.
7. **Test RTL early** — If targeting Arabic/Hebrew/Farsi, test layout direction early, not at the end.
8. **Keep fonts complete** — Ensure your font includes glyphs for all target languages. Use `DynamicFont` with Unicode-capable fonts (Noto Sans, etc.).
9. **Externalize dialogue** — Use Resource-based dialogue data so translators never touch GDScript.
10. **Automate extraction** — Use a script to extract `tr()` keys and generate `.pot` templates.

---

## Verification Checklist

- [ ] All user-facing text uses `tr()` or `tr_n()`
- [ ] Translation files (.po or .csv) are configured in Project Settings
- [ ] Pseudolocalization tested to catch overflow and missing `tr()` calls
- [ ] Plural forms use `tr_n()` with correct CLDR rules
- [ ] Locale switching refreshes all visible UI
- [ ] Player locale preference is persisted and restored
- [ ] Fonts support all required character sets
- [ ] RTL layout tested for Arabic/Hebrew/Farsi (if applicable)
- [ ] Context comments provided in .po files for ambiguous keys
