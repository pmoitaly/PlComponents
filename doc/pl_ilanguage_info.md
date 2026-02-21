# IPlLanguageInfoLoader  
**Version:** 0.8  
**Category:** Translation System – Metadata Loader Interface  
**Project:** PlComponents  

---

## Introduction
This document describes the `IPlLanguageInfoLoader` interface, which defines the contract for all components responsible for loading **language metadata** within the Pl Translation System.  
Metadata loaders provide essential information about available languages—such as name, locale, and additional attributes—without loading actual translation strings.

This interface ensures consistency across different loader implementations (INI, JSON, or custom formats) and allows the translation system to remain modular and extensible.

---

## Body

### 1. Purpose of the Interface
`IPlLanguageInfoLoader` abstracts the process of reading language metadata from external files.  
Implementations of this interface are responsible for:

- Parsing a metadata file  
- Extracting language information  
- Returning a fully populated `TPlLanguageInfo` record  

This separation allows the translation system to support multiple metadata formats without modifying the core logic.

---

### 2. Interface Definition

```pascal
IPlLanguageInfoLoader = interface
  ['{D8D84FDF-FC25-4231-8B51-88C1F42D8681}']

  /// <summary>
  /// Loads language metadata from the specified file and returns a populated
  /// <c>TPlLanguageInfo</c> instance.
  /// </summary>
  /// <param name="AFile">
  /// Path to the file containing the language definition.
  /// </param>
  /// <returns>
  /// A <c>TPlLanguageInfo</c> record filled with the data read from the file.
  /// </returns>
  function LoadFromFile(const AFile: string): TPlLanguageInfo;
end;
```

---

### 3. Responsibilities

Implementations of `IPlLanguageInfoLoader` must:

- Validate the input file path  
- Parse the file according to the expected format  
- Populate all required fields of `TPlLanguageInfo`  
- Handle missing or malformed fields gracefully  
- Raise meaningful exceptions when necessary  

The interface does **not** impose how metadata should be stored internally; this is left to the concrete loader.

---

### 4. Typical Implementations

Two standard implementations are provided in the Pl Translation System:

#### 4.1 PlLanguageInfoIniLoader
- Reads metadata from INI files  
- Suitable for simple or legacy applications  
- Human‑editable format  

#### 4.2 PlLanguageInfoJsonLoader
- Reads metadata from JSON files  
- Supports structured and extensible metadata  
- Ideal for modern applications or complex language definitions  

Developers may implement additional loaders (XML, YAML, database sources) by adhering to this interface.

---

### 5. Example Usage

```pascal
var
  Loader: IPlLanguageInfoLoader;
  Info: TPlLanguageInfo;
begin
  Loader := TPlLanguageInfoJsonLoader.Create;
  Info := Loader.LoadFromFile('languages/en.json');

  ShowMessage('Loaded language: ' + Info.DisplayName);
end;
```

This example demonstrates how an application can load language metadata without knowing the underlying file format.

---

### 6. Integration in the Translation System

`IPlLanguageInfoLoader` is typically used by:

- **PlLanguageServer**, to enumerate available languages  
- **UI components**, to display language names in menus  
- **Engine factories**, to associate metadata with translation files  

By decoupling metadata loading from translation loading, the system remains flexible and maintainable.

---

## Conclusion
The `IPlLanguageInfoLoader` interface defines a clean and extensible contract for loading language metadata in the Pl Translation System.  
Its design supports multiple file formats, encourages modularity, and ensures that applications can easily adapt to new metadata sources without modifying core logic.

Future enhancements may include:
- Additional loader implementations (XML, YAML)  
- Validation schemas for metadata files  
- Integration with remote or database‑based metadata sources  

---

## References
- [Pl Translation System](pl_language_system.md) Architecture  
- [`TPlLanguageInfo`](pl_language_info.md) record definition  
- Delphi interface and COM‑style GUID documentation  

---

## Appendix

### A. Suggested Metadata Structure (JSON Example)

```json
{
  "id": "en",
  "displayName": "English",
  "locale": "en-US",
  "direction": "LTR",
  "author": "Project Team",
  "version": "1.0"
}
```

### B. Suggested Metadata Structure (INI Example)

```
[Language]
Id=en
DisplayName=English
Locale=en-US
Direction=LTR
