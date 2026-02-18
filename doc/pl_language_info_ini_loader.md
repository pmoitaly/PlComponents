# TPlLanguageInfoIniLoader

## Overview

`TPlLanguageInfoIniLoader` is a concrete implementation of the `IPlLanguageInfoLoader` interface.

Its responsibility is to read language metadata from an INI file and return a populated [`TPlLanguageInfo`](pl_language_info.md) record.

This class is intentionally minimal and focused: it performs **metadata loading only**, without handling translation entries or component inspection.

---

## Class Hierarchy

```text
TInterfacedObject
  └── TPlLanguageInfoIniLoader
```

Implements:

* `IPlLanguageInfoLoader`

---

## Responsibility Scope

`TPlLanguageInfoIniLoader` is responsible for:

* Opening an INI file
* Reading language metadata from the `[Language]` section
* Populating a `TPlLanguageInfo` record
* Returning a fully initialized record

It does **not**:

* Validate file structure
* Raise custom exceptions
* Handle translation entries
* Modify application state

---

## Public API Reference

### `function LoadFromFile(const AFile: string): TPlLanguageInfo;`

Loads language metadata from the specified INI file.

### Parameters

* **AFile**: Path to the INI file containing the language definition.

### Returns

A `TPlLanguageInfo` record populated with the data read from the INI file.

---

## Behavior Details

1. The result record is zero-initialized using `FillChar`.
2. A `TIniFile` instance is created for the specified file.
3. The following keys are read from the `[Language]` section:

| Key             | Type    | Default | Description                |
| --------------- | ------- | ------- | -------------------------- |
| `Id`            | String  | `''`    | Unique language identifier |
| `Name`          | String  | `''`    | Display name               |
| `NativeName`    | String  | `''`    | Native language name       |
| `IsRightToLeft` | Boolean | `False` | Indicates RTL layout       |
| `UIFont`        | String  | `''`    | Preferred UI font          |
| `FallbackFont`  | String  | `''`    | Fallback font              |

4. The `TIniFile` instance is released in a `finally` block.

---

## Expected INI Structure

Example:

```ini
[Language]
Id=en
Name=English
NativeName=English
IsRightToLeft=False
UIFont=Segoe UI
FallbackFont=Arial
```

---

## Error Handling

* If the file does not exist, `TIniFile` may raise an exception.
* Missing keys are handled gracefully using default values.
* No custom validation is performed.

---

## Usage Context

This loader is typically instantiated by a concrete language engine (e.g. an INI-based persistence engine) via `CreateInfoLoader`.

It allows the engine to remain persistence-agnostic while delegating metadata extraction to a specialized implementation.

---

## Design Characteristics

* Single responsibility
* Interface-driven design
* Deterministic behavior
* No internal state retention
* Safe resource management via `try/finally`

---

## Extension Guidelines

To support a different persistence format (JSON, XML, database):

1. Implement `IPlLanguageInfoLoader`
2. Provide a new loader class (e.g. `TPlLanguageInfoJsonLoader`)
3. Override `CreateInfoLoader` in the corresponding language engine

This preserves architectural separation between:

* Metadata loading
* Translation persistence
* Runtime translation

---

