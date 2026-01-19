# Implementing a Custom Language Engine

This document explains how to implement a custom language engine compatible with the **PlLanguage** infrastructure.
It is intended for developers who want to provide new persistence formats or custom translation strategies.

---

## 1. Purpose of a Language Engine

A language engine is responsible for:

- Loading translations from a persistence medium (file, database, service)
- Applying translations to components and objects
- Saving translatable strings for later translation
- Providing runtime string translation through a shared dictionary

The engine **does not** decide *when* or *where* translations are applied — this responsibility belongs to `TPlLanguage` and the application logic.

---

## 2. Base Class: `TPlLanguageEngine`

All engines must inherit from:

```
TPlLanguageEngine
```

This base class provides:

- RTTI context management
- Component and property filtering
- Translation dictionary (`FTranslationsDict`)
- Shared logic for:
  - Excluded classes
  - Excluded properties
  - Action-based exclusions
  - Runtime string translation

A custom engine should **reuse** this logic and avoid duplicating it.

---

## 3. Mandatory Methods to Override

A custom engine must override the following methods:

### 3.1 `LoadTranslation`

```
procedure LoadTranslation(
  ASource: TComponent;
  const AFile: string
); override;
```

**Responsibilities:**

- Load translation data from the chosen source
- Populate the runtime translation dictionary (if supported)
- Apply translations to components and sub-objects

---

### 3.2 `SaveTranslation`

```
procedure SaveTranslation(
  ASource: TComponent;
  const AFile: string
); override;
```

**Responsibilities:**

- Inspect components and properties using RTTI
- Persist all translatable strings
- Optionally save runtime strings for future translation

Saving *must be considered a defensive operation*:  
even if some properties may not be translated at runtime (e.g. Action-managed captions), they should still be persisted.

---

## 4. Property Filtering Model

The engine relies on a **two-level filtering model**:

### 4.1 Structural eligibility

Handled by:

```
IsTranslatableProperty(TRttiProperty)
```

This method verifies that a property:

- Is `published`
- Is readable and writable
- Is of type string or string-compatible
- Is not explicitly excluded

This check is **purely structural** and context-independent.

---

### 4.2 Contextual translation decision

Handled by:

```
ShouldTranslateProperty(TRttiProperty; TObject)
```

This method decides whether a property should be translated **in the current context**, considering:

- `ExcludeOnAction`
- Association with an `Action`
- Runtime conditions

This separation allows:

- Defensive saving
- Flexible runtime behavior
- Clear extension points for custom logic

---

## 5. Runtime String Translation

If supported, an engine may load a dictionary of generic strings (e.g. a `[Strings]` section or JSON object).

These strings are accessed through:

```
Translate(const AString: string): string
```

This allows translation of:

- Messages
- Labels created at runtime
- Non-component-bound text

---

## 6. Recursive vs Non-Recursive Engines

Engines may choose different traversal strategies:

- **Recursive engines** (e.g. JSON engine)
  - Traverse nested objects via RTTI
  - Suitable for structured formats

- **Non-recursive engines** (e.g. INI engine)
  - Work at component level only
  - Simpler, more predictable
  - Easier to edit manually

Both approaches are valid and supported.

---

## 7. Defensive Design Principles

When implementing a custom engine:

- Prefer **saving more data than strictly necessary**
- Avoid assumptions about runtime configuration
- Do not hard-code UI policies into the engine
- Let the programmer decide how to use or ignore translations

---

## 8. Minimal Skeleton Example

```
type
  TMyLanguageEngine = class(TPlLanguageEngine)
  public
    procedure LoadTranslation(
      ASource: TComponent;
      const AFile: string
    ); override;

    procedure SaveTranslation(
      ASource: TComponent;
      const AFile: string
    ); override;
  end;
```

---

## 9. Summary

A well-designed custom engine:

- Focuses only on persistence and translation mechanics
- Delegates policy decisions to the base engine
- Is defensive, predictable, and extensible
- Integrates seamlessly with `TPlLanguage`

---

*This document is part of the public PlLanguage documentation.*
