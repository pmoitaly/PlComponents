# TPlLanguage

## Overview

`TPlLanguage` is a VCL component designed to manage **runtime language localization** of Delphi applications.\
It provides a structured, engine-based approach to loading and saving translations for forms and components, with support for multiple persistence formats.

The component is part of the **PlComponents** library and is intended for applications that need:

* Runtime language switching
* Centralized translation management
* Extensible persistence engines (INI, JSON, future XML, registry, etc.)

---

## Key Features

* Runtime loading and saving of translations
* Pluggable persistence engines via `IPlLanguageEngine`
* Automatic language file path and name calculation
* Fine-grained exclusion of components and properties
* Event hooks before and after load/save operations
* Optional automatic file and directory creation

---

## Architecture

`TPlLanguage` acts as a **facade component** that delegates the actual translation logic to a persistence engine implementing `IPlLanguageEngine`.

```
TPlLanguage
   |
   +--> IPlLanguageEngine (INI / JSON / ...)
   |
   +--> TPlLanguageServer (singleton coordinator)
```

The singleton server is intentionally used to coordinate multiple `TPlLanguage` instances within the same application.

---

## Language File Structure

Language files are organized as:

```
<LangPath>\<Language>\<ContainerName>.<ext>
```

Example:

```
Languages\English\MainForm.lng
Languages\Italiano\MainForm.json
Languages\Français\MainDatamodule.lng
```

Where:

* `LangPath` is the root language directory
* `Language` is the current language (e.g. English, Español, Italiano...)
* `ContainerName` is usually the form or datamodule name
* `<ext>` depends on `FileFormat`

---

## Published Properties

### Language Control

* **Language**
  Current language identifier. Cannot be empty.

* **LangPath**
  Root directory containing all language subfolders.

* **LangFile**
  Full path of the active language file. Automatically calculated when possible.

* **FileFormat**
  Persistence format used by the engine (`lpIni`, `lpJson`, ...). At present only .ini and .json format are supported.

---

### Behavior

* **CreateIfMissing**  
  Automatically creates missing directories and/or language files.

* **ExcludeOnAction**  
  Skips properties bound to actions.

* **ExcludeClasses**  
  List of component class names to ignore during translation.

* **ExcludeProperties**  
  List of property names that should never be translated.

* **RegisterOnStart**  
  Controls whether the component automatically registers itself in
  `TPlLanguageServer`.

  * Default value: `True`
  * Registration occurs **once**, during the component `Loaded` phase.
  * Changing this property at runtime has **no effect**.

  When `RegisterOnStart` is `True`, the component participates in
  server-managed language synchronization (monolingual application model).

  When `False`, the component operates in **standalone mode** and remains
  fully independent from `TPlLanguageServer`.


---

### Events

* **BeforeLoad / AfterLoad**
  Triggered before and after loading translations.

* **BeforeSave / AfterSave**
  Triggered before and after saving translations.

* **OnLanguageError**
  Optional notification hook for *language-related* errors (functional/domain errors).
  System and programming exceptions are intentionally propagated.
  OnLanguageError is a notification hook, not a global exception handler.
---

## Public Methods

> **Error handling note**: only language-related (domain) errors trigger `OnLanguageError`. System or programming errors are not intercepted and will propagate normally.

### LoadLanguage

```pascal
procedure LoadLanguage;
procedure LoadLanguage(AContainer: TComponent);
procedure LoadLanguage(AContainer: TComponent; AFile: string);
```

Loads translations into the specified container.
Default values are Owner as AContainer and LangFile as AFile.

* If the language engine is not ready, the call is ignored
* Language-related errors trigger `OnLanguageError`
* If EnsureReady is False, the procedure exits silently
* If the engine is not instanced an exceeption is raised
* If the BeforeLoad event sets allow to False, the call is ignored

---

### SaveLanguage

```pascal
procedure SaveLanguage;
procedure SaveLanguage(AContainer: TComponent);
procedure SaveLanguage(AContainer: TComponent; AFile: string);
```

Persists the current translations of the container.
Default values are Owner as AContainer and LangFile as AFile.

* If the engine is not ready, the call is ignored
* Language-related errors trigger `OnLanguageError`
* If EnsureReady is False, the procedure exits silently
* If the engine is not instanced an exceeption is raised
* If the BeforeSave event sets allow to False, the call is ignored

---

### Translate

```pascal
function Translate(const AString: string): string;
```

Translates a single string using the active language engine.

---

## Typical Usage

```pascal
PlLanguage1.LangPath := 'Languages';
PlLanguage1.Language := 'en';
PlLanguage1.FileFormat := lpIni;
PlLanguage1.LoadLanguage;
```

---

## Common Pitfalls

This section highlights frequent misuses of the API and clarifies the intended behavior of `TPlLanguage`.
They are not bugs in the component, but incorrect assumptions or usage patterns that can lead to unexpected behavior.

### 1. Assuming `LangPath` or `Language` alone is sufficient

`LangPath` and `Language` contribute **equally** to the automatic calculation of `LangFile`.

The language file path is computed **only when both properties are set**:

```
<LangPath>\<Language>\<ContainerName>.<ext>
```

Setting only one of them is insufficient and will not result in a valid language file path.

**Correct usage:**

```pascal
PlLanguage1.LangPath := 'Languages';
PlLanguage1.Language := 'English';
PlLanguage1.LoadLanguage;
```

---

### 2. Expecting `LoadLanguage` or `SaveLanguage` to raise all errors

`LoadLanguage` and `SaveLanguage` distinguish between **language-domain errors** and **system or programming errors**.

* Language-related errors (for example: missing language file, invalid language configuration) trigger the `OnLanguageError` event if assigned.
* System errors (I/O failures, access violations, programming mistakes) are **not intercepted** and will propagate as exceptions.

This design keeps domain-level error handling explicit while preserving normal exception semantics for critical failures.

---

### 3. Modifying exclusion lists without considering the active engine

`ExcludeClasses` and `ExcludeProperties` are copied into the active language engine.

Changes to these lists **after** the engine has been created are propagated, but replacing the engine (for example by changing `FileFormat`) will recreate it and reapply the current lists.

Best practice is to configure exclusions **before** calling `LoadLanguage` or `SaveLanguage`.

---

### 4. Relying on `LangFile` while also changing `LangPath` or `Language`

`LangFile` may be set explicitly, but doing so implicitly updates both `LangPath` and `Language`.

Conversely, changing `LangPath` or `Language` may recalculate `LangFile` automatically.

Mixing manual `LangFile` assignment with frequent changes to `LangPath` or `Language` can lead to unintended file paths.

**Recommendation:**

* Either manage `LangFile` explicitly
* Or let it be fully derived from `LangPath` and `Language`

Avoid mixing both approaches unless strictly necessary.

---

### 5. Expecting automatic UI refresh or repainting

`TPlLanguage` is responsible only for loading and saving translated values.

It does **not** force UI repainting, layout recalculation, or visual refresh. Components that require manual updates must be refreshed explicitly by the application after language loading.

---

### 2. Expecting `OnLanguageError` to catch all exceptions

**Wrong assumption**

> “If I assign `OnLanguageError`, no exception will ever be raised.”

**Reality**

* `OnLanguageError` is notified **only for language-related (domain) errors**
* System, programming, or unexpected exceptions are **intentionally propagated**

This design keeps real bugs visible while still allowing graceful handling of localization errors.

---

### 3. Mixing `LangFile` with automatic path calculation

**Problem**

```pascal
PlLanguage1.LangPath := 'Languages';
PlLanguage1.Language := 'en';
PlLanguage1.LangFile := 'Custom.lng';
```

When `LangFile` is explicitly assigned:

* automatic file name calculation is bypassed
* `LangPath` and `Language` are no longer authoritative

Rule of thumb

* Use **either** `LangFile`
or LangPath + Language

Not both.

---

### 4. Calling `LoadLanguage` too early in the lifecycle

Calling `LoadLanguage` before the container is fully initialized may result in:

* partially translated UI
* missing component properties

This typically happens when calling `LoadLanguage` too early in `FormCreate` or `DataModuleCreate`.

**Recommendation**

* Call `LoadLanguage` after all visual components are fully created
* Or explicitly target a container when calling `LoadLanguage(AContainer)`

---

### 5. Assuming `Translate()` updates the UI automatically

**Common misunderstanding**

> “If I call `Translate()`, the UI should refresh.”

**Clarification**

* `Translate()` is a **pure string translation helper**
* It does not notify, repaint, or refresh any control

UI updates must be explicitly triggered by the application.

---

### 6. Assuming the engine always exists

If the persistence engine cannot be created (for example due to configuration errors):

* `EnsureReady` may fail
* load/save operations are silently skipped

Always ensure that:

* `FileFormat` is valid
* the corresponding engine is available

---

---

## Design Notes

* `TPlLanguage` intentionally does **not** manage UI refresh logic.
* The component is safe to use with multiple forms and containers.
* The singleton server is by design and enables future synchronization features.

---

## Future Extensions

* XML persistence engine
* Registry-based engine
* Live language switching notifications
* IDE-time language preview

---

## Contributing

Contributions are welcome.
Please open issues or submit pull requests on GitHub.

---

## License

Released under the **MIT License**. See the LICENSE file for details.

