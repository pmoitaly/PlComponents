# TPlLanguageServer

## Overview

`TPlLanguageServer` is a **centralized, static coordination service** for language management in Delphi VCL applications that adopt a **single active UI language** at runtime.

It is part of the **PlComponents** localization system and is designed to *optionally* complement `TPlLanguage` components, not to replace them.

The server exists to simplify **global language coherence**, **single-point language control**, and **runtime string translation**, while deliberately avoiding ownership of client logic or error policies.

---

## Design Goals

The server is intentionally designed to provide:

1. **Global language coherence** across forms and data modules
2. **A single point of access** for changing language and language folder
3. **Runtime translation** of generic strings not bound to components

At the same time, it explicitly avoids becoming a monolithic or intrusive controller.

---

## Intended Usage Scenario

`TPlLanguageServer` is intended for applications with:

- A **monolingual UI at any given time**
- Multiple forms or data modules using `TPlLanguage`
- The need to change language globally with minimal wiring

Each `TPlLanguage` component:

- Remains fully autonomous
- Manages its own persistence engine
- Handles its own errors and events

Using the server is **optional**. Applications may use `TPlLanguage` components independently if desired.

---

## Architecture

```
TPlLanguageServer (static singleton)
   |
   +-- Registered TPlLanguage clients
   |
   +-- Runtime translation dictionary
```

The server:

- Stores the currently selected language and language folder
- Synchronizes registered clients when those values change
- Loads runtime translation files (e.g. `runtime.lng`)

---

## Public API

### Properties

#### Language

```pascal
class property Language: string;
```

The currently active language identifier (e.g. `"en"`, `"it"`).

Setting this property:

- Updates the internal runtime translation dictionary
- Synchronizes all registered clients
- Triggers `OnLanguageChanged`

---

#### LanguagesFolder

```pascal
class property LanguagesFolder: string;
```

Root folder containing language subdirectories.

Example structure:

```
Languages\
  English\
  Italiano\
```

Changing this property has the same effects as changing `Language`.

---

#### OnLanguageChanged

```pascal
class property OnLanguageChanged: TLanguageChangedEvent;
```

Global notification event fired after language or folder changes.

Intended for:

- Modules that are not `TPlLanguage` clients
- UI refresh logic
- Logging or diagnostics

---

## Public Methods

### RegisterClient

```pascal
class procedure RegisterClient(AClient: TPlLanguage);
```

Registers a `TPlLanguage` instance for synchronization.

- Safe against duplicates
- Immediately synchronizes the client if possible

---

### UnregisterClient

```pascal
class procedure UnregisterClient(AClient: TPlLanguage);
```

Removes a previously registered client.

Should be called in the client destructor.

---

### TranslateString

```pascal
class function TranslateString(const AString: string): string;
```

Translates a generic runtime string using the current runtime dictionary.

- Uses normalized keys
- Returns the original string if no translation is found
- Never raises exceptions

This method is intentionally *best-effort*.

---

## Runtime Translation Files

The server optionally loads runtime translations from a file named:

```
runtime.<ext>
```

located at:

```
<LanguagesFolder>\<Language>\
```

Example:

```
Languages\English\runtime.lng
```

Currently supported formats:

- INI (`lpIni`, `lpIniFlat`)
- JSON support planned

---

## Intentional Design Limits

The following limitations are **by design**, not omissions.

### 1. The server is *not* a language engine

- Does not inspect components
- Does not serialize properties
- Does not apply exclusions

All translation logic remains inside `TPlLanguage` and its engines.

---

### 2. The server does not manage client errors

- Does not intercept exceptions from clients
- Does not apply error policies

Each `TPlLanguage` instance remains responsible for its own error handling.

---

### 3. No support for simultaneous multiple UI languages

The server maintains **a single global language state**.

Applications requiring multiple concurrent UI languages must not use the server and should manage `TPlLanguage` instances independently.

---

### 4. Synchronization is cooperative, not enforced

Clients may:

- Reject a language change
- Fail independently
- Use different persistence engines

The server does not verify or enforce full alignment.

---

### 5. Runtime translation is best-effort

- Missing keys are silently ignored
- The original string is returned

This prevents runtime translation from breaking application flow.

---

### 6. No UI refresh responsibility

The server:

- Signals language changes
- Does not repaint or invalidate UI

UI refresh logic belongs to the application.

---

### 7. Thread safety without thread context

- Internal structures are protected
- No per-thread language context exists

The server is thread-safe but intentionally global in scope.

---

## When *Not* to Use TPlLanguageServer

Do **not** use the server if:

- Your application requires multiple languages simultaneously
- You need per-form or per-module language isolation
- You want centralized error handling across all clients

In these cases, use `TPlLanguage` directly.

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

