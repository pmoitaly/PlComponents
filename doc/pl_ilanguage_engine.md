# IPlLanguageEngine  
**Version:** 0.8  
**Category:** Translation System – Persistence and Processing Engine  
**Project:** PlComponents  

---

## Introduction
This document describes the `IPlLanguageEngine` interface, which defines the contract for all translation engines used within the Pl Translation System.  
A language engine is responsible for **loading**, **saving**, and **processing** translations for a specific file format (e.g., INI, JSON), as well as providing runtime translation services.

The interface abstracts the persistence and processing logic, allowing the system to support multiple formats while maintaining a consistent workflow.

---

## Body

### 1. Overview
`IPlLanguageEngine` represents the **format‑specific translation engine** used to:

- load translations from a file  
- save translations back to a file  
- read language metadata  
- translate strings at runtime  
- apply filtering rules during traversal  

It operates between the UI traversal layer (`TPlLanguage`) and the storage layer (`IPlTranslationStore`), ensuring a clean separation of responsibilities.

---

### 2. Architectural Role

The engine sits at the center of the translation workflow:

```
TPlLanguage / TPlLanguageServer
          |
          v
   IPlLanguageEngine
          |
          v
   IPlTranslationStore
```

Its responsibilities include:

- parsing translation files  
- populating a translation store  
- traversing components to extract or apply translations  
- writing updated translations back to disk  

It does **not** decide fallback logic, nor does it manage global/local language coordination.

---

### 3. Responsibilities

`IPlLanguageEngine` is responsible for:

- **Loading translations** from a file into a store  
- **Saving translations** extracted from components  
- **Reading language metadata**  
- **Translating strings** using the active store  
- **Filtering components and properties** during traversal  
- **Optionally creating missing entries** during extraction  

It is **not** responsible for:

- generating translation keys  
- managing global or local fallback  
- storing translations (delegated to `IPlTranslationStore`)  
- UI-level language switching  

---

### 4. Interface Contract

#### 4.1 `LoadLanguage`
```pascal
procedure LoadLanguage(ASource: TComponent; const AFile: string;
  AStore: IPlTranslationStore = nil);
```

Loads translations from a file and optionally populates a provided store.

Responsibilities:

- parse the file  
- populate the store  
- apply translations to `ASource` (form/datamodule)  
- create a new store if none is provided  

---

#### 4.2 `ReadLanguageInfo`
```pascal
function ReadLanguageInfo(const AFile: string): TPlLanguageInfo;
```

Reads **metadata only**, without loading translations.

Typical metadata:

- language ID  
- display name  
- locale  
- direction (LTR/RTL)  

---

#### 4.3 `SaveLanguage`
```pascal
procedure SaveLanguage(ASource: TComponent; const AFile: string);
```

Extracts translatable strings from a component tree and writes them to a file.

Responsibilities:

- traverse `ASource`  
- apply filtering rules  
- generate translation keys  
- write key/value pairs to disk  

---

#### 4.4 `Translate`
```pascal
function Translate(const AString: string): string;
```

Translates a single string using the currently loaded store.

Behavior:

- returns the translated value if available  
- returns the original string if missing  
- does not raise exceptions  

---

### 5. Engine Configuration Properties

#### 5.1 `CreateIfMissing`
```pascal
property CreateIfMissing: Boolean;
```

Controls whether missing translation entries should be automatically created during extraction.

Use cases:

- building initial translation files  
- debugging missing keys  

---

#### 5.2 `ExcludeClasses`
```pascal
property ExcludeClasses: TStrings;
```

List of class names to exclude during traversal.

Examples:

- `TAction`  
- `TTimer`  
- custom non-visual components  

---

#### 5.3 `ExcludeOnAction`
```pascal
property ExcludeOnAction: Boolean;
```

If `True`, components linked to an `Action` are excluded from traversal.

Useful when:

- actions already provide centralized text  
- avoiding duplicate entries  

---

#### 5.4 `ExcludeProperties`
```pascal
property ExcludeProperties: TStrings;
```

List of property names to skip during traversal.

Examples:

- `Name`  
- `Tag`  
- `HelpKeyword`  

---

### 6. Typical Implementations

Concrete engines include:

- **PlLanguageIniEngine**  
  - simple, human-editable INI format  

- **PlLanguageJsonEngine**  
  - structured JSON format with nested objects  

Custom engines may support:

- XML  
- YAML  
- database‑backed translations  

All engines must adhere strictly to the interface contract.

---

### 7. Usage Contexts

#### 7.1 Local Translation (`TPlLanguage`)
Used to load and apply translations to a specific form or datamodule.

#### 7.2 Global Translation (`TPlLanguageServer`)
Used to load global translations and provide fallback for all local engines.

Both contexts rely on the same interface, ensuring consistency.

---

## Conclusion
`IPlLanguageEngine` defines the core contract for translation engines in the Pl Translation System.  
By separating persistence logic, traversal rules, and translation processing from storage and UI layers, it enables:

- support for multiple file formats  
- consistent translation workflows  
- extensibility through custom engines  
- predictable and testable behavior  

Its design ensures that the localization system remains modular, maintainable, and adaptable to future needs.

---

## References
- [Pl Translation System](pl_language_system.md) Architecture
- [`TPlLanguageEngine`](pl_language_engine.md) IPlLanguageEngine implementation
- [`IPlTranslationStore`](pl_itranslation_store.md) storage abstraction  
- [`TPlLanguage`](pl_language.md) and [`TPlLanguageServer`](pl_language_server.md) traversal and coordination  
- [`TPlLineEncoder`](pl_line_encoder.md) key generation utilities  

---

## Appendix

### A. Example Workflow

```pascal
var
  Engine: IPlLanguageEngine;
  Info: TPlLanguageInfo;
begin
  Engine := TPlLanguageJsonEngine.Create;

  Info := Engine.ReadLanguageInfo('lang/en.json');

  Engine.LoadLanguage(Form1, 'lang/en.json');

end;
```
