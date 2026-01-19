# TPlLanguageEngineFactory

## Overview

`TPlLanguageEngineFactory` is a **centralized factory and registry** responsible for
creating instances of language persistence engines used by `TPlLanguage`.

Its purpose is to **decouple** the core localization logic from concrete persistence
implementations (INI, JSON, custom formats), allowing new engines to be added
*without modifying existing framework code*.

The factory is part of the **PlComponents localization infrastructure** and is
already integrated into the `TPlLanguage` creation flow.

---

## Design Goals

The factory is intentionally designed to:

1. Eliminate direct dependencies between `TPlLanguage` and concrete engine classes
2. Allow third-party or application-specific engines to be plugged in easily
3. Enforce interface correctness at registration time
4. Keep engine creation centralized, explicit, and predictable

It does **not**:

- manage engine configuration
- cache engine instances
- provide lifecycle or pooling logic

Each call produces a **new engine instance**.

---

## Architecture Role

```
TPlLanguage
   |
   +-- TPlLanguageEngineFactory
           |
           +-- lpIni      -> TPlLanguageIniEngine
           +-- lpIniFlat  -> TPlLanguageIniFlatEngine
           +-- lpJson     -> TPlLanguageJsonEngine
           +-- lpCustom   -> (user-defined)
```

The factory maps a `TPlLanguagePersistence` value to a class implementing
`IPlLanguageEngine`.

---

## Registration Model

### When to Register

Engines must be registered **before** they are requested.
Typical registration points:

- Application startup code
- `initialization` section of the engine unit
- Plugin initialization logic

### Example

```pascal
initialization
  TPlLanguageEngineFactory.Register(lpJson, TPlLanguageJsonEngine);
```

---

## Public API

### CreateEngine

```pascal
class function CreateEngine(
  const AnEngineType: TPlLanguagePersistence
): IPlLanguageEngine;
```

Creates a new engine instance for the specified persistence type.

**Behavior:**

- Returns a freshly instantiated engine
- No caching or reuse is performed
- Raises an exception if no engine is registered

**Exceptions:**

- `EPlLanguageException`  
  Raised if the engine type is not registered (`SEngineNotImplemented`)

---

### Register

```pascal
class procedure Register(
  const AnEngineType: TPlLanguagePersistence;
  AnEngineClass: TPlLanguageEngineClass
);
```

Registers an engine class for a persistence type.

**Behavior:**

- Performs a *defensive instantiation* to ensure the class implements
  `IPlLanguageEngine`
- Registration is idempotent: if the type is already registered,
  the call has no effect

**Exceptions:**

- `EPlLanguageException`  
  Raised if the class does not implement `IPlLanguageEngine`

---

### Unregister

```pascal
class procedure Unregister(
  const AnEngineType: TPlLanguagePersistence
);
```

Removes the engine associated with a persistence type.

**Notes:**

- Mainly intended for testing or dynamic plugin scenarios
- Rarely needed in standard applications

---

## Error Handling Philosophy

The factory enforces **early validation**:

- Incorrect engine classes fail at registration time
- Missing engines fail at creation time

This prevents silent misconfiguration and keeps errors explicit.

The factory does **not**:

- swallow exceptions
- provide fallback engines
- log errors internally

---

## Best Practices

- Register engines in the engine unit `initialization` section
- Use one persistence enum value per engine
- Keep engine constructors lightweight
- Avoid unregistering engines in production code

---

## When *Not* to Use the Factory

You should not bypass the factory unless:

- You are experimenting with internal framework code
- You are writing unit tests that inject mock engines manually

For all normal usage, the factory is the **only supported mechanism**
for engine instantiation.

---

## Summary

`TPlLanguageEngineFactory` is a **minimal, robust, and extensible** abstraction that:

- protects the framework from tight coupling
- enables third-party extensibility
- keeps engine creation explicit and safe

It is a foundational piece for long-term maintainability of the
PlComponents localization system.

---

## License

Released under the **MIT License**.
