# TPlTranslationStore  
**Version:** 0.8  
**Category:** Translation System – In-Memory Storage Implementation  
**Project:** PlComponents  

---

## Introduction
This document describes the `TPlTranslationStore` class, the default in-memory implementation of the [`IPlTranslationStore`](pl_itranslation_store.md) interface.  
Its purpose is to provide a fast, lightweight, and format-agnostic storage mechanism for translated strings during runtime.

`TPlTranslationStore` is used by translation engines, language managers to store and retrieve translations using normalized keys. It is intentionally simple and optimized for performance and predictability.

---

## Body

### 1. Overview
`TPlTranslationStore` implements the `IPlTranslationStore` interface using a `TDictionary<string,string>` as its internal storage.  
It supports:

- adding or replacing translations  
- retrieving translations  
- clearing the store  
- checking whether the store is empty  

The class automatically normalizes keys using `TPlLineEncoder.MakeKey` (see [`TPlLineEncoder`](pl_line_encoder.md)), ensuring consistency across all translation engines and components.

---

### 2. Architectural Role

`TPlTranslationStore` sits at the **lowest level** of the translation architecture:

```
TPlLanguage / TPlLanguageServer
          |
          v
   IPlLanguageEngine
          |
          v
   TPlTranslationStore (IPlTranslationStore)
```

Its responsibilities are strictly limited to **storage**, not logic.  
It does not:

- parse translation files  
- traverse components  
- apply fallback rules  
- generate keys  
- encode or decode values  

This separation ensures modularity and testability.

---

### 3. Responsibilities

`TPlTranslationStore` is responsible for:

- storing translations indexed by normalized keys  
- retrieving values without raising exceptions  
- clearing all stored entries  
- providing an efficient in-memory lookup mechanism  

It is **not** responsible for:

- key generation (delegated to [`TPlLineEncoder`](pl_line_encoder.md))  
- persistence (delegated to [`IPlLanguageEngine`](pl_language_engine.md))  
- UI traversal ([`TPlLanguage`](pl_language.md))
- global coordination ([`TPlLanguageServer`](pl_language_server.md))  

---

### 4. Class Definition

```pascal
TPlTranslationStore = class(TInterfacedObject, IPlTranslationStore)
private
  FItems: TDictionary<string, string>;
public
  constructor Create;
  destructor Destroy; override;

  procedure Clear;
  procedure AddOrSet(const AKey, AValue: string);
  procedure AddOrSetEncoded(const AEncodedKey, AValue: string);
  function TryGetValue(const AKey: string; out AValue: string): Boolean;
  function IsEmpty: Boolean;
end;
```

---

### 5. Method Reference

#### 5.1 Constructor `Create`
Creates an empty translation store and initializes the internal dictionary.

---

#### 5.2 Destructor `Destroy`
Releases the internal dictionary and frees all associated resources.

---

#### 5.3 `Clear`
Removes all stored translations.

Typical use cases:

- reloading a language file  
- switching active language  
- resetting engine state  

---

#### 5.4 `AddOrSet`
```pascal
procedure AddOrSet(const AKey, AValue: string);
```

Adds or replaces a translation value using the **logical key**.  
The key is automatically normalized using:

```
TPlLineEncoder.MakeKey(AKey)
```

This ensures consistent hashing across the entire system.

---

#### 5.5 `AddOrSetEncoded`
```pascal
procedure AddOrSetEncoded(const AEncodedKey, AValue: string);
```

Adds or replaces a translation using a **pre‑encoded key**.

Use cases:

- engines that already computed the normalized key  
- importing data from external sources  

---

#### 5.6 `TryGetValue`
```pascal
function TryGetValue(const AKey: string; out AValue: string): Boolean;
```

Attempts to retrieve a translation using the logical key. If the logical key exists, its Value is stored in AValue. 
The method:

- normalizes the key internally  
- returns `True` if the key exists  
- returns `False` otherwise  
- never raises exceptions  

This behavior supports layered fallback strategies.

---

#### 5.7 `IsEmpty`
Returns `True` if the store contains no translations.

Useful for:

- detecting uninitialized stores  
- validating engine loading results  

---

### 6. Key Handling

All keys are normalized using:

```
TPlLineEncoder.MakeKey
```

This ensures:

- deterministic key generation  
- compatibility across engines  
- consistent lookup behavior  

The store never transforms or validates values.

---

### 7. Usage Contexts

#### 7.1 Local Translation (`TPlLanguage`)
Each form or datamodule typically uses its own store instance.

#### 7.2 Global Translation (`TPlLanguageServer`)
A single global store provides fallback translations for all local stores.

Both contexts rely on the same implementation, ensuring uniform behavior.

---

## Conclusion
`TPlTranslationStore` provides a simple, efficient, and reliable in-memory implementation of the `IPlTranslationStore` interface.  
By focusing exclusively on storage and delegating all logic to higher-level components, it contributes to a clean and modular translation architecture.

Its deterministic key handling, predictable behavior, and minimal overhead make it suitable for both local and global translation scenarios.

---

## References
- [`IPlTanslationStore`](pl_itranslation_store.md) interface specification  
- [`TPlLineEncoder`](pl_line_encoder.md) key generation utilities  
- [Pl Translation System](pl_translation.sysyem.md) Architecture  
- [`IPlLanguageEngine`](pl_ilanguage_engine.md) persistence engines  

---

## Appendix

### A. Example Usage

```pascal
var
  Store: IPlTranslationStore;
  Value: string;
begin
  Store := TPlTranslationStore.Create;

  Store.AddOrSet('MainForm.Title', 'Hello World');

  if Store.TryGetValue('MainForm.Title', Value) then
    ShowMessage(Value);
end;
```
