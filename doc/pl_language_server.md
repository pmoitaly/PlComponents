# TPlLanguageServer

## Overview

`TPlLanguageServer` is a centralized, static language manager responsible for coordinating **global language state** across an application.

It provides:

* A single source of truth for the current language and language folder
* Automatic synchronization of all registered `TPlLanguage` clients
* Runtime translation lookup via a shared dictionary
* Global notifications when the language changes

`TPlLanguageServer` is designed for applications that operate with **one active language at a time**.

---

## Architectural Role

`TPlLanguageServer` sits at the top of the localization stack:

```
Application
 ├─ TPlLanguageServer   (global coordinator)
 │   ├─ Runtime translation store
 │   ├─ Language metadata
 │   └─ Client synchronization
 └─ TPlLanguage         (per-container language handler)
     └─ TPlLanguageEngine (persistence)
```

It is intentionally implemented as a **static class** (class variables + class methods).

---

## Responsibilities

`TPlLanguageServer` is responsible for:

* Storing the active language identifier
* Storing the root languages folder
* Managing the persistence format
* Loading global runtime translations
* Loading language metadata (`TPlLanguageInfo`)
* Synchronizing all registered clients
* Providing a global `Translate` function
* Emitting global language-change notifications

---

## Lifecycle

### `class constructor Create;`

Automatically executed once.

* Creates the internal client list
* Creates the shared translation store

---

### `class destructor Destroy;`

Automatically executed once at shutdown.

* Clears the client list in a thread-safe manner
* Releases server resources

---

## Private / Internal Members

### `class function CanSync: Boolean;`

Determines whether the server is in a valid state to synchronize data.

### Conditions

* `LanguagesFolder` is set and exists
* `Language` is set
* Language-specific subfolder exists

---

### `class procedure EnsureEngine;`

Lazily creates the persistence engine based on `FileFormat`.

---

### `class procedure UpdateData;`

Central update pipeline invoked whenever:

* `Language` changes
* `LanguagesFolder` changes
* `FileFormat` changes

### Execution Order

1. Import runtime translations
2. Synchronize all clients
3. Import language metadata
4. Synchronize client metadata
5. Fire `OnLanguageChanged` event

---

## Public Properties

### `class property FileFormat: TPlLanguagePersistence`

Defines the persistence format used for language files.

Changing this property:

* Clears the current engine
* Clears runtime translations
* Reloads all language data

---

### `class property Language: string`

Identifier of the active language (e.g. `"en"`, `"it"`).

Changing this property triggers a full synchronization cycle.

---

### `class property LanguagesFolder: string`

Root folder containing language subfolders.

Changing this property triggers a full synchronization cycle.

---

### `class property LanguageInfo: TPlLanguageInfo`

Holds metadata associated with the active language.

This property is updated automatically when language data is reloaded.

---

### `class property OnLanguageChanged: TLanguageChangedEvent`

Global event fired after a language change has been fully applied.

Useful for modules that are not `TPlLanguage` clients.

---

## Client Management

### `class procedure RegisterClient(AClient: TPlLanguage);`

Registers a `TPlLanguage` component to receive language updates.

### Behavior

* Ignores `nil` clients
* Prevents duplicate registration
* Immediately synchronizes the client if possible
* Thread-safe

---

### `class procedure UnregisterClient(AClient: TPlLanguage);`

Removes a previously registered client.

### Behavior

* Safe against `nil`
* Thread-safe
* Should be called in the client destructor

---

## Runtime Translation

### `class function Translate(const AString: string): string;`

Translates a string using the global runtime dictionary.

### Behavior

* Empty input returns empty string
* Looks up the string in the global store
* Returns the original string if no translation is found

---

## Synchronization Internals

### Client Synchronization

Each registered client receives:

* `Language`
* `LanguagesFolder`
* `FileFormat`

via `SynchronizeClient`.

Clients are responsible for handling their own load/save events.

---

### Runtime Translation Import

Runtime translations are loaded from:

```
<LanguagesFolder>/<Language>/global.<ext>
```

Where `<ext>` depends on `FileFormat`.

These translations are stored in a shared `IPlTranslationStore`.

---

### Language Metadata Import

Language metadata is loaded from:

```
<LanguagesFolder>/<Language>/lang.<ext>
```

and propagated to all registered clients.

---

## Thread Safety

* Client list access is protected via `TMonitor`
* Translation store access is encapsulated
* Engine creation is lazy and centralized

---

## Usage Guidelines

### When to Use

* Applications with a single active language
* Centralized localization management
* Mixed UI and non-UI translation needs

### When *Not* to Use

* Applications requiring multiple simultaneous languages
* Per-module isolated localization contexts

---

## Design Characteristics

* Static, centralized design
* Event-driven synchronization
* Engine-agnostic persistence
* Deterministic update pipeline
* Clear separation of concerns

---

## Summary

`TPlLanguageServer` is a **lightweight coordination layer**, not a controller.

It exists to:

- Reduce boilerplate
- Improve consistency
- Preserve flexibility

Its intentional limits protect both the architecture and the developer.

---

## License

Released under the **MIT License**.

