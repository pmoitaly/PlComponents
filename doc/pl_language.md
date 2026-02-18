# TPlLanguage

## Overview

`TPlLanguage` is a visual component responsible for managing application localization at runtime.

It acts as the **high-level façade** of the PlLanguage framework and coordinates:

* Language engine creation
* Language file resolution
* Load/Save operations
* Runtime translation access
* Event notifications
* Integration with the language server

Unlike [`TPlLanguageEngine`](pl_language_engine.md), which focuses on persistence mechanics, `TPlLanguage` manages the **application-facing workflow**.

---

## Class Hierarchy

```text
TComponent
  └── TPlLanguage
```

---

## Responsibilities

`TPlLanguage` is responsible for:

* Managing the selected language
* Resolving file paths and names
* Creating and configuring the appropriate persistence engine
* Triggering load/save operations
* Propagating configuration to the engine
* Handling non-fatal language errors
* Integrating with [`TPlLanguageServer`](pl_language_server.md)
* Providing runtime string translation

---

# Protected Members

## `procedure Loaded; override;`

Executed after the component has been fully loaded.

### Behavior

* Registers the component in `TPlLanguageServer` (if `RegisterOnStart` is `True`)
* Ensures the engine is created
* Synchronizes engine configuration
* Automatically loads the language file (if available and not in design mode)

---

# Public Members

## Constructor

### `constructor Create(AOwner: TComponent); override;`

Initializes the component.

### Initialization Steps

* Sets container to `AOwner`
* Enables `RegisterOnStart`
* Creates translation store
* Initializes exclusion lists
* Sets default persistence format (`lpIni`)
* Creates the language engine

---

## Destructor

### `destructor Destroy; override;`

Cleans up resources.

### Behavior

* Unregisters from `TPlLanguageServer`
* Releases engine reference
* Frees exclusion lists

---

## `property LanguageInfo: TPlLanguageInfo`

Holds metadata associated with the current language.

---

## Load Operations

### `procedure LoadLanguage; overload;`

Loads language using the default container and current file.

---

### `procedure LoadLanguage(AContainer: TComponent); overload;`

Loads language into the specified container using the current file.

---

### `procedure LoadLanguage(AContainer: TComponent; AFile: string); overload;`

Loads language from a specific file.

### Execution Flow

1. Ensures engine is ready
2. Fires `BeforeLoad` event
3. Clears translation store
4. Delegates to engine
5. Handles `EPlLanguageException`
6. Fires `AfterLoad` event

---

## Save Operations

### `procedure SaveLanguage; overload;`

Saves language using default container and file.

---

### `procedure SaveLanguage(AContainer: TComponent); overload;`

Saves language from specified container using current file.

---

### `procedure SaveLanguage(AContainer: TComponent; AFile: string); overload;`

Saves language to a specific file.

### Execution Flow

1. Validates file selection
2. Ensures engine readiness
3. Fires `BeforeSave` event
4. Delegates to engine
5. Handles `EPlLanguageException`
6. Fires `AfterSave` event

---

## Runtime Translation

### `function Translate(const AString: string): string;`

Translates a runtime string.

### Behavior

* Checks internal translation store
* Falls back to `TPlLanguageServer.Translate`
* Returns original string if no translation is found

---

# Published Properties

## Events

### `AfterLoad: TPlAfterLoadLanguageEvent`

Called after a language file has been loaded.

### `AfterSave: TPlAfterSaveLanguageEvent`

Called after a language file has been saved.

### `BeforeLoad: TPlBeforeLoadLanguageEvent`

Called before loading a language file. Allows cancellation.

### `BeforeSave: TPlBeforeSaveLanguageEvent`

Called before saving a language file. Allows cancellation.

### `OnLanguageError: TPlOnLanguageError`

Triggered when a non-fatal language error occurs.

---

## Configuration Properties

### `CreateIfMissing: Boolean`

If `True`, missing language files and directories are created automatically.

---

### `ExcludeClasses: TStrings`

List of component classes excluded from translation.

---

### `ExcludeOnAction: Boolean`

If `True`, components associated with Actions are excluded.

---

### `ExcludeProperties: TStrings`

List of property names excluded from translation.

---

### `FileFormat: TPlLanguagePersistence`

Defines the persistence format.

Changing this property recreates the engine and optionally reloads the language.

---

### `LangFile: string`

Full path to the active language file.

Setting this property:

* Updates `LangPath`
* Updates `Language`
* Automatically triggers loading (if not in design mode)

---

### `LangPath: string`

Base path where language folders are stored.

Changing this recalculates the language file.

---

### `Language: string`

Identifier of the current language.

* Cannot be empty
* Recalculates file name when changed

---

### `RegisterOnStart: Boolean`

If `True`, the component registers itself with `TPlLanguageServer` during loading.

---

# Internal Workflow Summary

1. Component initializes and creates engine
2. Language file path is calculated from:

   * `LangPath`
   * `Language`
   * Owner container name
   * Selected file format
3. Engine performs persistence operations
4. Translation store is populated
5. Runtime `Translate` resolves values via store or server

---

# Error Handling Strategy

* Fatal configuration errors raise `EPlLanguageException`
* Non-fatal errors trigger `OnLanguageError`
* Load/Save operations can be canceled via events

---

# Architectural Role

`TPlLanguage` is the **application entry point** of the localization framework.

It orchestrates:

* Persistence engines
* Translation storage
* Metadata loading
* Runtime translation server

The design ensures:

* Separation of concerns
* Engine abstraction
* Event-driven extensibility
* Safe automatic loading

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

## Design Notes

* `TPlLanguage` intentionally does **not** manage UI refresh logic.
* The component is safe to use with multiple forms and containers.
* The singleton server is by design and enables future synchronization features.

---

## Future Extensions

* XML persistence engine
* Registry-based engine
* Live language switching notifications
* Real-time translation via Web Services

---

## Contributing

Contributions are welcome.
Please open issues or submit pull requests on GitHub.

---

## License

Released under the **MIT License**. See the LICENSE file for details.

