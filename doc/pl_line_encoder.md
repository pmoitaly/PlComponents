# TPlLineEncoder

## Overview

`TPlLineEncoder` is a utility record that provides static helper functions for:

* Encoding and decoding strings for persistence
* Generating CRC32-based keys
* Normalizing values for INI storage
* Handling multiline text serialization
* Escaping special characters in file paths and INI keys

The record is completely stateless and exposes only `class function` members. It is designed to support language persistence engines and translation stores.

---

## Design Goals

* Deterministic key generation
* Safe storage of multiline and special-character strings
* INI-compatible normalization
* Unicode-safe CRC calculation
* Zero instance allocation (record with static methods)

---

## Public API Reference

### `class function CRC32OfString(const S: string): Cardinal; static;`

Computes the CRC32 checksum of a string.

### Behavior

* Iterates through each UTF-16 character
* Processes both low-byte and high-byte
* Uses `CRC32Table` lookup
* Applies standard CRC32 final XOR (`$FFFFFFFF`)

### Notes

* Fully Unicode-aware
* Deterministic across platforms
* Used as the base for key generation

---

### `class function MakeKey(const S: string): string; static;`

Generates an 8-character hexadecimal key derived from the CRC32 checksum.

### Behavior

* Calls `CRC32OfString`
* Converts result to uppercase hexadecimal
* Pads to 8 characters

### Example Output

```
A1B2C3D4
```

### Usage

Used to create compact, stable identifiers for translation entries.

---

### `class function Encode(const S: string): string; static;`

Encodes a string by replacing special characters with tokens.

### Replacements

* `§` → `[§]`
* CRLF (`#13#10`) → `[CRLF]`

### Purpose

Allows safe storage in text-based formats where special characters may break structure.

---

### `class function Decode(const S: string): string; static;`

Decodes previously encoded tokens back to their original characters.

### Replacements

* `[CRLF]` → line break
* `[§]` → `§`

### Purpose

Restores original content after loading from persistence.

---

### `class function JoinMultiline(const S: string): string; static;`

Converts multiline text into a single line.

### Behavior

* Replaces `sLineBreak` with `~~`

### Purpose

Useful when storing multiline values in formats that require single-line entries.

---

### `class function RestoreMultiline(const S: string): string; static;`

Restores multiline formatting from placeholder tokens.

### Behavior

* Replaces `~~` with `sLineBreak`

### Purpose

Inverse operation of `JoinMultiline`.

---

### `class function NormalizeIniKey(const S: string): string; static;`

Escapes special characters to make a string safe as an INI key.

### Replacements

* `'` → `''` (escaped apostrophe)
* `;` → `[SEMICOLON]`
* `=` → `[EQUAL]`

### Purpose

Prevents INI parsing errors caused by reserved characters.

---

### `class function DenormalizeIniKey(const S: string): string; static;`

Restores a normalized INI key to its original form.

### Replacements

* `[EQUAL]` → `=`
* `[SEMICOLON]` → `;`
* `''` → `'`

### Purpose

Inverse operation of `NormalizeIniKey`.

---

### `class function NomalizePath(const S: string): string; static;`

Normalizes a file path by escaping backslashes.

### Behavior

* `\` becomes `\\`

### Purpose

Ensures path strings remain valid when stored in text-based formats.

---

## Internal Dependencies

* `CRC32Table` (from `PlLanguageTypes`)
* `SysUtils` for string helpers and `IntToHex`

---

## Usage Context

`TPlLineEncoder` is typically used by:

* Language persistence engines
* Translation stores
* Runtime translation pipelines

It ensures consistency between:

* Stored translation entries
* Runtime dictionary keys
* Persisted INI/JSON/XML values

---

## Architectural Notes

* Stateless design
* Fully static API
* No side effects
* Safe for concurrent use

