# IPlTranslationStore  
**Version:** 0.8  
**Category:** Translation System – Storage Abstraction  
**Project:** PlComponents  

---

## Introduction
This document describes the `IPlTranslationStore` interface, the foundational abstraction responsible for storing translated strings within the Pl Translation System.  
Its purpose is to provide a **minimal, format‑agnostic, and UI‑independent** storage layer that can be used consistently across local and global translation scopes.

`IPlTranslationStore` is intentionally simple: it stores key/value pairs representing translations, without performing any logic related to UI traversal, file formats, or language switching.

---

## Body

### 1. Overview
`IPlTranslationStore` defines the lowest architectural layer of the localization system.  
It focuses exclusively on:

- storing translations  
- retrieving translations  
- clearing stored data  

It does **not** deal with:

- how translations are loaded  
- how keys are generated  
- how fallback logic works  
- how UI components are updated  

This strict separation ensures a clean, maintainable architecture.

---

### 2. Architectural Role

The interface sits beneath all higher‑level translation components:

```
TPlLanguage / TPlLanguageServer
          |
          v
   IPlLanguageEngine
          |
          v
   IPlTranslationStore
```

Its introduction enables:

- clear separation of concerns  
- reuse of the same storage mechanism across multiple layers  
- independence from persistence formats (INI, JSON, …)  
- independence from UI logic (VCL, FMX, forms, DFM traversal)  

---

### 3. Responsibilities

`IPlTranslationStore` **is responsible for**:

- storing translated strings indexed by normalized keys  
- retrieving values without raising exceptions  
- checking whether a key exists  
- clearing all stored translations  

`IPlTranslationStore` **is not responsible for**:

- generating translation keys  
- applying fallback rules  
- loading or saving translation files  
- encoding or decoding text  
- interacting with UI components  

This ensures that the store remains a pure data container.

---

### 4. Key Semantics

All keys passed to the store are assumed to be:

- **stable**  
- **deterministic**  
- **pre‑normalized**  

In the current architecture:

- keys are generated externally using `TPlLineEncoder.MakeKey`  
- the store does not transform or validate keys  

This allows:

- global translations  
- local (form/datamodule) translations  

to coexist safely using the same key generation strategy.

---

### 5. Interface Contract

#### 5.1 `Clear`
Removes all stored translations.

Typical use cases:

- reloading a language file  
- switching active language  
- resetting engine state  

---

#### 5.2 `HasKey`
Checks whether a translation exists for a given key.

Reasons for a dedicated method:

- avoids unnecessary allocations  
- allows explicit fallback logic  
- separates existence checks from retrieval  

---

#### 5.3 `TryGetValue`
Attempts to retrieve a translation.

Behavior:

- returns `True` if the key exists  
- returns `False` if the key is missing  
- never raises exceptions for missing keys  

This is essential for layered fallback strategies.

---

#### 5.4 `SetValue`
Adds or replaces a translation value.

Notes:

- overwriting existing keys is allowed  
- no merging or versioning logic is applied  
- the store remains a simple key/value container  

---

### 6. Typical Implementations

Concrete implementations are expected to be:

- in‑memory  
- dictionary‑based  
- case‑sensitive  
- free of persistence responsibilities  

Persistence engines (`IPlLanguageEngine`) are responsible for:

- creating a store instance  
- populating it during loading  
- reading from it during saving  

---

### 7. Usage Contexts

#### 7.1 Local translations (`TPlLanguage`)
Each `TPlLanguage` instance typically uses its own store, populated from a form‑specific or module‑specific translation file.

#### 7.2 Global translations (`TPlLanguageServer`)
`TPlLanguageServer` maintains a **single global store**, used as a fallback for all local stores.

Both contexts rely on the same interface, ensuring architectural consistency.

---

### 8. Design Rationale

Introducing `IPlTranslationStore` solves several architectural issues:

- eliminates duplicated storage logic across engines  
- enables shared infrastructure for global and local translations  
- simplifies engine implementations  
- makes fallback logic explicit and testable  
- avoids mixing storage concerns with UI or persistence logic  

The interface is intentionally minimal to prevent abstraction leakage.

---

### 9. Non‑Goals

`IPlTranslationStore` does **not** address:

- thread safety  
- pluralization rules  
- parameterized translations  
- localization of non‑string resources  
- advanced merging or overlay logic  

These concerns belong to higher‑level components or future extensions.

---

### 10. Future Extensions

Possible non‑breaking additions include:

- enumeration of stored keys  
- read‑only store variants  
- store chaining or overlay mechanisms  

Any extension must preserve the core principle:  
**the store handles storage, not logic.**

---

## Conclusion
`IPlTranslationStore` is the foundational storage abstraction of the Pl Translation System.  
By isolating translation storage from UI traversal and persistence logic, it enables a clean, layered architecture that supports:

- multiple file formats  
- global and local translation scopes  
- predictable fallback behavior  

while keeping higher‑level components simple and focused.

---

## References
- Pl Translation System Architecture  
- [`TPlLineEncoder`](pl_line_encoder.md) key generation  
- [`IPlLanguageEngine`](pl_ilanguage_engine.md) persistence interfaces  
- [`TPlLanguage`](pl_language.md) and [`TPlLanguageServer`](pl_language_server.md) usage patterns  

---

## Appendix

### A. Example Usage Pattern

```pascal
var
  Store: IPlTranslationStore;
  Value: string;
begin
  Store.Clear;
  Store.SetValue('A1B2C3D4', 'Hello World');

  if Store.TryGetValue('A1B2C3D4', Value) then
    ShowMessage(Value);
end;
```
