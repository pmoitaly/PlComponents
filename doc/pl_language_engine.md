# TPlLanguageEngine

## Overview

`TPlLanguageEngine` is the **abstract base class** for all persistence engines used by `TPlLanguage`.

It encapsulates the common logic required to:

- Inspect components via RTTI
- Decide *what* can be translated
- Decide *when* a property should be translated
- Delegate actual persistence to concrete implementations (INI, JSON, …)

The class is designed for **inheritance**, not for direct use.

---

## Role in the Architecture

```
TPlLanguage
   |
   +--> IPlLanguageEngine
            |
            +--> TPlLanguageEngine   (abstract base)
                    |
                    +--> TPlIniLanguageEngine
                    +--> TPlJsonLanguageEngine
                    +--> ...
```

`TPlLanguageEngine` provides:

- A **stable contract** for all engines
- Shared filtering and translation logic
- A clear separation between *inspection*, *decision*, and *persistence*

Concrete engines are responsible **only** for reading and writing data.

---

## Design Principles

1. **Separation of concerns**
   - The engine decides *which* properties are eligible
   - Concrete engines decide *how* data is persisted

2. **Two-level filtering**
   - Structural eligibility (`IsTranslatableProperty`)
   - Contextual decision (`ShouldTranslateProperty`)

3. **Non-intrusive behavior**
   - No UI refresh
   - No exception policy
   - No global state

4. **Fail-safe loading**
   - Missing files can be created if explicitly allowed
   - Otherwise, operations are silently skipped

---

## Property Filtering Model

Translation is governed by **two distinct checks**.

### 1. IsTranslatableProperty

Structural check:

- Property must be `published`
- Property must be readable and writable
- Property type must be string-compatible
- Property name must not be excluded

This check answers:

> *“Can this property ever be translated?”*

---

### 2. ShouldTranslateProperty

Contextual check:

- Evaluates the specific component instance
- Applies runtime rules (e.g. `ExcludeOnAction`)

This check answers:

> *“Should this property be translated **now**, on this component?”*

---

### ExcludeOnAction Rule

When `ExcludeOnAction = True`:

- If a component has an associated `Action`
- Then text properties managed by the action (`Caption`, `Hint`) are **not translated**

Rationale:

> Actions are assumed to already contain localized text and must take precedence.

---

## Lifecycle of LoadLanguage

1. Verify language file existence
2. Optionally create directories/files (`CreateIfMissing`)
3. Call `LoadTranslation` (implemented by concrete engine)
4. Apply translated values via RTTI

The base class does **not** parse files directly.

---

## Lifecycle of SaveLanguage

1. Ensure target directory exists (optional)
2. Inspect components and properties
3. Extract translatable values
4. Call `SaveTranslation` (implemented by concrete engine)

Purpose:

> Generate a language file for the *current language*, even if translations are incomplete.

---

## Public API Summary

### LoadLanguage

```pascal
procedure LoadLanguage(ASource: TComponent; const AFile: string);
```

- Loads translations from a persistence medium
- Does nothing if the file does not exist and creation is disabled

---

### SaveLanguage

```pascal
procedure SaveLanguage(ASource: TComponent; const AFile: string);
```

- Saves current component strings
- Can create missing directories/files

---

### Translate

```pascal
function Translate(const AString: string): string;
```

- Translates a single runtime string
- Uses normalized keys
- Falls back to the original string

---

## Extending TPlLanguageEngine

To implement a new engine, you must:

1. Inherit from `TPlLanguageEngine`
2. Implement:

```pascal
procedure LoadTranslation(ASource: TComponent; const AFile: string); override;
procedure SaveTranslation(ASource: TComponent; const AFile: string); override;
```

You should **not**:

- Reimplement filtering logic
- Access UI refresh logic
- Change exception policies

---

## Intentional Limitations

These are **by design**:

- No UI repainting
- No centralized error handling
- No multi-language concurrency
- No dependency on `TPlLanguageServer`

The engine is reusable **with or without** the server.

---

## Common Pitfalls

### Assuming all string properties are translated

Only properties that pass **both** filtering stages are processed.

---

### Translating Action-bound captions manually

When `ExcludeOnAction` is enabled, captions and hints are skipped intentionally.

---

### Creating engines that bypass base logic

Doing so breaks consistency and future compatibility.

Always delegate common behavior to the base class.

---

## Summary

`TPlLanguageEngine` is the **contractual heart** of the localization system.

It ensures:

- Predictable behavior
- Consistent filtering
- Safe extensibility

Concrete engines remain focused, simple, and replaceable.

---

## License

Released under the **MIT License**.

