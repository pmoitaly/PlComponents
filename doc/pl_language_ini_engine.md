# PlLanguage INI Engines

This document describes the **public API** and behavior of the INI-based language engines
provided by the *PlLanguage* framework.

It is intended for **library users**, not engine implementers.

---

## Overview

The INI engines allow translations to be **loaded from** and **saved to**
INI files stored locally.

Two concrete engines are available:

- `TPlLanguageIniEngine`
- `TPlLanguageIniFlatEngine`

Both engines are built on top of a shared abstract base class:

- `TPlLanguageCustomIniEngine`

All INI engines inherit from `TPlLanguageEngine` and fully respect its
filtering and translation rules.

---

## Supported Features

- Component-based translation
- RTTI-driven property detection
- Action-aware exclusion rules
- Multiline string encoding
- Runtime translation dictionary
- Flat or hierarchical INI layout

---

## Engine Classes

### `TPlLanguageIniEngine`

Standard INI engine using **one section per component**.

#### File Structure

```ini
[Form1]
Caption=Main window

[Form1.Button1]
Caption=OK
Hint=Confirm action
```

#### Characteristics

- Hierarchical layout
- Qualified component names
- Best readability for complex forms

#### Constructor

```pascal
constructor Create; override;
```

Initializes the engine with:

```pascal
FFileStyle := lpIni;
```

---

### `TPlLanguageIniFlatEngine`

Flat INI engine using **a single shared section**.

#### File Structure

```ini
[UIElements]
Form1.Caption=Main window
Form1.Button1.Caption=OK
```

#### Characteristics

- Single section (`UIElements`)
- Easier to parse by external tools
- Less human-readable for large UIs

#### Constructor

```pascal
constructor Create; override;
```

Initializes the engine with:

```pascal
FFileStyle := lpIniFlat;
```

---

## Common Public API

Both engines expose the same public methods inherited from
`TPlLanguageEngine`.

### `LoadTranslation`

```pascal
procedure LoadTranslation(
  ASource: TComponent;
  const AFile: string
); override;
```

#### Description

Loads translations from an INI file and applies them to the component tree
rooted at `ASource`.

#### Behavior

- Reads all INI sections
- Resolves components by qualified name
- Applies properties using RTTI
- Skips ineligible components
- Honors `ExcludeOnAction`
- Populates the runtime translation dictionary

#### Notes

- Missing components or properties are silently ignored
- Multiline values are automatically restored

---

### `SaveTranslation`

```pascal
procedure SaveTranslation(
  ASource: TComponent;
  const AFile: string
); override;
```

#### Description

Extracts translatable properties from the component tree and saves them
to an INI file.

#### Behavior

- Traverses all owned components
- Serializes only eligible properties
- Saves Action-controlled values defensively
- Applies multiline encoding
- Overwrites existing files

#### Notes

- Components without a valid name are skipped
- Menu separators (`'-'`) are excluded automatically

---

## Translation Dictionary

Both engines support runtime translation through the internal dictionary:

```pascal
FTranslationsDict
```

This dictionary is populated from the `[Strings]` INI section, if present:

```ini
[Strings]
IDS_OK=OK
IDS_CANCEL=Cancel
```

This enables runtime translation via:

```pascal
TranslateString('IDS_OK');
```

---

## Action-Aware Behavior

If `ExcludeOnAction = True`:

- Properties controlled by `TAction` are **not applied**
- Their values are still **saved**

This defensive strategy ensures that translation files remain valid
if Action bindings change in the future.

---

## Limitations

Current INI engines:

- Are **not recursive on object properties**
- Operate at **component level only**
- Do not serialize nested object graphs

This is a **deliberate design choice** and may change in future revisions.

---

## When to Use INI Engines

INI engines are ideal when:

- Translations must be human-editable
- No external dependencies are allowed
- Backward compatibility is required
- Simplicity is preferred over structure

For more complex scenarios, consider the JSON engine.

---

## Summary

| Feature | INI Engine |
|------|-----------|
| Human-readable | ✔ |
| External tool friendly | ✔ |
| Recursive serialization | ✘ |
| Runtime translation | ✔ |
| Action-aware | ✔ |

The INI engines provide a stable, predictable, and backward-compatible
solution for UI localization.

---
