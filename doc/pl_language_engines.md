# PlLanguage Translation System

## Overview
The PlLanguage framework provides a pluggable persistence architecture for UI language management in Delphi applications. Language engines are responsible for **saving**, **loading**, and **applying** translatable strings to components at runtime.

All engines share a common base class, `TPlLanguageEngine`, and differ only in how translations are persisted (JSON, INI, etc.).

This document describes the public behavior, responsibilities, and design rationale of the available engines.

---

## Common Design Principles

All PlLanguage engines:

- Operate on **monolingual applications** (one active language at a time)
- Use **RTTI** to discover translatable properties
- Respect developer-defined filters:
  - Eligible classes
  - Eligible properties
  - Action-driven components
- Support **runtime translation of generic strings**
- Allow defensive persistence (saving strings even if not currently translated)

---

## Base Class: `TPlLanguageEngine`

### Role

`TPlLanguageEngine` defines:

- The **public API** used by `TPlLanguage`
- The **filtering rules** for components and properties
- The **runtime translation dictionary**
- The contract for persistence engines

Concrete engines **must not override** the filtering semantics, only persistence logic.

### Filtering Model

The engine uses **two distinct filtering levels**:

#### 1. Structural filter – `IsTranslatableProperty`

Determines whether a property:

- Is readable and writable
- Is of a string-compatible type
- Is `published`
- Is not explicitly excluded by name

This filter answers:

> *Can this property ever be translated?*

#### 2. Contextual filter – `ShouldTranslateProperty`

Determines whether a property **should be translated now**, based on:

- `ExcludeOnAction`
- Association with a `TAction`

This filter answers:

> *Should this property be translated in this context?*

This separation allows **defensive persistence**: properties may be saved even if they are not currently applied.

---

## JSON Engine: `TPlLanguageJsonEngine`

### Purpose

Provides a structured, hierarchical JSON representation of UI translations.

### Key Characteristics

- Recursive serialization of components and nested objects
- Explicit support for `TStrings`
- Runtime translation dictionary loaded from a dedicated `Strings` JSON section

### Serialization Model

```json
{
  "FormMain": {
    "Caption": "Main window",
    "Button1": {
      "Caption": "OK"
    }
  },
  "Strings": {
    "HELLO": "Hello",
    "GOODBYE": "Goodbye"
  }
}
```

### Main Responsibilities

- **`ComponentToJson`**  
  Walks the component tree and delegates object serialization.

- **`SerializeObject`**  
  Recursively serializes an object using RTTI.

- **`TranslateObject`**  
  Applies JSON values back to components and nested objects.

### Design Notes

- Caption and Hint values are **always saved**, even when `ExcludeOnAction=True`.
- Translation application respects `ShouldTranslateProperty`.

This ensures forward compatibility if `ExcludeOnAction` changes in the future.

---

## INI Engines

### Base Class: `TPlLanguageCustomIniEngine`

Provides shared logic for INI-based persistence.

### Responsibilities

- Qualified component name resolution (`Parent.Child.Component`)
- Section-based serialization
- Runtime translation dictionary loading

### Engines

#### `TPlLanguageIniEngine`

- One INI section per component
- Hierarchical structure

#### `TPlLanguageIniFlatEngine`

- Single section (`UIElements`)
- Flat key/value layout

### Example (Hierarchical)

```ini
[FormMain]
Caption=Main window

[FormMain.Button1]
Caption=OK
```

### Example (Flat)

```ini
[UIElements]
FormMain.Caption=Main window
FormMain.Button1.Caption=OK
```

### Design Notes

- Uses the same filtering model as the JSON engine
- Supports defensive persistence
- Fully compatible with runtime string translation

---

## Runtime String Translation

All engines support translation of generic strings via:

```pascal
Engine.Translate('Hello world')
```

This uses the runtime dictionary loaded from the persistence source.

---

## Intentional Limitations

- No automatic language switching
- No multilingual UI state
- No implicit Action translation
- No automatic resource-string integration

These constraints keep the framework predictable and easy to reason about.

---

## Summary

| Engine | Format | Structure | Recursive | Runtime Strings |
|------|-------|-----------|-----------|-----------------|
| JSON | JSON | Hierarchical | Yes | Yes |
| INI | INI | Hierarchical | No | Yes |
| INI Flat | INI | Flat | No | Yes |

---

## Implementing a new custom engine

To implment a new custom engine, see [our guide](Implementig_Custom_Language_Engine.md).
