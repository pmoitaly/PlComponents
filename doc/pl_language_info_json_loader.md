# TPlLanguageInfoJsonLoader

## Overview

`TPlLanguageInfoJsonLoader` is a concrete implementation of the `IPlLanguageInfoLoader` interface.

Its responsibility is to read language metadata from a JSON file and return a populated [`TPlLanguageInfo`](pl_language_info.md) record.

This loader mirrors the behavior of the INI-based implementation but adapts it to structured JSON input.

The class focuses strictly on **metadata extraction**, not on translation entries or runtime language application.

---

## Class Hierarchy

```text
TInterfacedObject
  └── TPlLanguageInfoJsonLoader
```

Implements:

* `IPlLanguageInfoLoader`

---

## Responsibility Scope

`TPlLanguageInfoJsonLoader` is responsible for:

* Reading a JSON file from disk
* Parsing the JSON structure
* Extracting language metadata from a `language` object
* Populating and returning a `TPlLanguageInfo` record

It does **not**:

* Validate full schema correctness
* Handle translation key/value entries
* Modify application state
* Maintain internal state between calls

---

## Public API Reference

### `function LoadFromFile(const AFile: string): TPlLanguageInfo;`

Loads language metadata from the specified JSON file.

### Parameters

* **AFile**: Path to the JSON file containing the language definition.

### Returns

A `TPlLanguageInfo` record populated with the data read from the JSON file.

---

## Behavior Details

1. The result record is zero-initialized using `FillChar`.
2. The file is read entirely using `TFile.ReadAllText`.
3. The JSON content is parsed into a `TJSONObject`.
4. The method searches for a root object named `language`.
5. If the `language` object is not found, the method exits and returns a zeroed record.
6. The following properties are read:

| JSON Property   | Type    | Default | Description                |
| --------------- | ------- | ------- | -------------------------- |
| `id`            | String  | `''`    | Unique language identifier |
| `name`          | String  | `''`    | Display name               |
| `nativeName`    | String  | `''`    | Native language name       |
| `isRightToLeft` | Boolean | `False` | Indicates RTL layout       |
| `uiFont`        | String  | `''`    | Preferred UI font          |
| `fallbackFont`  | String  | `''`    | Fallback font              |

7. The `TJSONObject` instance is released in a `finally` block.

---

## Expected JSON Structure

Example:

```json
{
  "language": {
    "id": "en",
    "name": "English",
    "nativeName": "English",
    "isRightToLeft": false,
    "uiFont": "Segoe UI",
    "fallbackFont": "Arial"
  }
}
```

---

## Error Handling

* If the file does not exist, `TFile.ReadAllText` raises an exception.
* If JSON parsing fails, `ParseJSONValue` may return `nil` or raise an exception.
* If the `language` object is missing, the function exits gracefully.
* Missing individual properties are handled using default values.

No custom exception wrapping is performed.

---

## Usage Context

This loader is typically instantiated by a JSON-based language engine via `CreateInfoLoader`.

It allows the persistence engine to remain format-specific while keeping metadata loading isolated and testable.

---

## Design Characteristics

* Single responsibility
* Interface-based abstraction
* Stateless implementation
* Deterministic field mapping
* Safe resource cleanup via `try/finally`

---

## Extension Guidelines

To support alternative metadata schemas:

* Modify the JSON structure mapping inside `LoadFromFile`
* Or provide a new implementation of `IPlLanguageInfoLoader`

Maintaining the interface contract ensures compatibility with existing language engines.
