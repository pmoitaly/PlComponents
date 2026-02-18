# IPlTranslationStore

## Overview

`IPlTranslationStore` defines a **format-agnostic storage abstraction** for translated strings.

Its responsibility is **only** to store and retrieve translations by key, without any knowledge of:

* VCL / FMX components
* Forms or DataModules
* DFM traversal
* Language switching logic
* File formats (INI, JSON, …)

This interface is intentionally minimal and sits at the **lowest architectural level** of the localization system.

---

## Architectural Role

`IPlTranslationStore` is introduced to clearly separate **translation data storage** from:

* UI traversal (`TPlLanguage`)
* Global coordination (`TPlLanguageServer`)
* Persistence formats (`IPlLanguageEngine`)

High-level relationship:

```
TPlLanguage / TPlLanguageServer
          |
          v
   IPlLanguageEngine
          |
          v
   IPlTranslationStore
```

Key design goals:

* Single responsibility
* Reusability across local and global translation scopes
* Ability to share the same store between multiple consumers
* Independence from persistence format and UI logic

---

## Responsibilities

`IPlTranslationStore` is responsible for:

* Storing translated strings indexed by **normalized keys**
* Returning a translated value or signaling absence
* Clearing or resetting its content

It is **not** responsible for:

* Generating translation keys
* Deciding fallback policies
* Loading or saving files
* Encoding / decoding strings

---

## Key Semantics

All keys used by `IPlTranslationStore` are assumed to be:

* **Stable**
* **Deterministic**
* **Pre-normalized**

In the current architecture:

* Keys are generated externally using `TPlLineEncoder.MakeKey`
* The store does not validate or transform keys

This guarantees that:

* Global translations
* Local (form/datamodule) translations

can safely coexist using the same key generation strategy.

---

## Interface Contract

### Clear

Removes all stored translations.

Typical use cases:

* Reloading a language file
* Switching language
* Resetting engine state

---

### HasKey

Checks whether a translation exists for the given key.

This method is intentionally separated from `TryGetValue` to allow:

* Explicit fallback logic
* Non-allocating existence checks

---

### TryGetValue

Attempts to retrieve a translation for a given key.

* Returns `True` if the key exists
* Returns `False` if the key is not present
* Does not raise exceptions for missing keys

This behavior is critical to support **layered fallback strategies**.

---

### SetValue

Adds or replaces a translation value for the given key.

Behavioral notes:

* Overwriting an existing key is allowed
* No merging or versioning logic is applied

---

## Typical Implementations

Concrete implementations are expected to be simple and efficient, for example:

* In-memory dictionary-based store
* Case-sensitive key storage
* No persistence responsibilities

Persistence engines are responsible for:

* Creating a store instance
* Populating it while loading
* Reading from it while saving

---

## Usage Contexts

### Local translations (`TPlLanguage`)

Each `TPlLanguage` instance typically works with its own store instance, populated from a container-specific language file.

### Global translations (`TPlLanguageServer`)

`TPlLanguageServer` owns a **single global store**, populated from one global language file and used as a fallback.

Both contexts rely on the **same interface**, ensuring architectural consistency.

---

## Design Rationale

Introducing `IPlTranslationStore` solves multiple architectural issues:

* Eliminates duplicated in-memory storage logic across engines
* Enables global and local translations to share infrastructure
* Simplifies language engines by reducing their responsibilities
* Makes fallback logic explicit and testable

This interface is intentionally small to avoid premature abstraction leakage.

---

## Non-Goals

`IPlTranslationStore` explicitly does **not** address:

* Thread safety
* Localization of non-string resources
* Pluralization rules
* Parameterized translations

These concerns are left to higher-level layers or future extensions.

---

## Future Extensions

Possible, non-breaking future additions include:

* Enumeration of keys
* Read-only store variants
* Store chaining or overlay mechanisms

Such extensions should preserve the core principle: **storage, not logic**.

---

## Summary

`IPlTranslationStore` is the foundational abstraction that enables a clean, layered localization architecture.

By isolating translation storage from UI traversal and persistence logic, it provides the flexibility required to support:

* Multiple file formats
* Global and local translation scopes
* Predictable fallback behavior

without increasing complexity in higher-level components.
