# `TPlLanguageInfo`

`TPlLanguageInfo` is a record representing a language supported by the application, including identifiers, display names, writing direction, and optional UI font recommendations.

## Fields

| Field | Type | Description |
|-------|------|-------------|
| **Id** | `string` | BCP-47 language identifier (e.g., `"it-IT"`, `"ar-SA"`). |
| **Name** | `string` | Language name in English, used for consistent display across locales. |
| **NativeName** | `string` | Language name as written in its own script by native speakers. |
| **IsRightToLeft** | `Boolean` | Indicates whether the language uses a right‑to‑left writing direction (e.g., Arabic, Hebrew). |
| **UIFont** | `string` | Optional suggested UI font for rendering text in this language. May be empty if no specific font is required. |
| **FallbackFont** | `string` | Optional fallback font used when the primary UI font is unavailable or lacks glyph coverage. |

## Usage Notes

- The record is typically used to assist in configuring and rendering UI, determining best fonts and layout direction.
- `UIFont` and `FallbackFont` are especially useful for languages requiring extended Unicode coverage or specialized typographic support.
- `IsRightToLeft` should be used to adjust layout mirroring, text alignment, and control ordering when necessary.
