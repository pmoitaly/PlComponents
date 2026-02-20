# Pl Translation System  
**Version:** 0.8  
**Category:** Runtime Localization Framework  
**Project:** PlComponents  

---

## Introduction
This document provides an overview of the **Pl Translation System**, the runtime localization framework included in the `plVCLNonVisualComponents` package.  
Its purpose is to describe the architecture, components, and workflow of the system, ensuring a consistent understanding for developers integrating localization features into VCL applications.

---

## Body

### 1. Overview of the Translation System
The Pl Translation System is a **lightweight, extensible, runtime‑oriented localization framework** for Delphi VCL applications.  
It enables applications to load, manage, and switch languages dynamically, using human‑readable formats such as **INI** and **JSON**.

The system is designed to be:
- **Modular** — each responsibility is isolated in its own unit  
- **Extensible** — developers can add custom engines or loaders  
- **Non‑intrusive** — no need for resource DLLs or recompilation  
- **Runtime‑driven** — languages can be changed while the application is running  

---

### 2. Architecture Overview

The Translation System is composed of several units, each with a clear responsibility:

* [TPlLanguageServer](pl_language_server.md)
* [TPlLanguage](pl_language.md)
* [TPlLanguageEngineFactory](pl_language_engine_factory.md)
* [TPlLanguageEngine](pl_language_engine.md)
* | +-- lpIni      -> [TPlLanguageIniEngine](pl_language_ini_engine.md)
* | +-- lpIniFlat  -> [TPlLanguageIniEngine](pl_language_ini_engine.md)
* | +-- lpJson     -> [TPlLanguageJsonEngine](pl_language_json_engine.md)
* | +-- lpCustom   -> [user-defined](implementing_custom_language_engine.md)
* [IPlLanguageLoader](pl_language.md)
* | +-- lpIni      -> [TPlLanguageIniEngine](pl_language_ini_loader.md)
* | +-- lpIniFlat  -> [TPlLanguageIniEngine](pl_language_ini_loader.md)
* | +-- lpJson     -> [TPlLanguageJsonEngine](pl_language_json_loader.md)

* [TPlLanguageEncoder](pl_language_encoder.md)
* [TPlTanslationStore](pl_translation_store.md)

---

### 3. Workflow

A typical workflow for using the Translation System is:

1. **Register translation engines**  
   Register TPlLanguage instances into TPlLanguageServer.
2. **Activate a language**  
   The language server sets the active language.
3. **Load translation files**  
   The engine populates the translation store.
4. **Translate UI elements**  
   Components query the server or store.
5. **Switch language at runtime**  
   The server notifies subscribed components.
   
---

### 4. Example Usage

See Demo project.

---

### 5. Integration Notes
- The system is fully **non‑visual** and can be used in any VCL project.  
- Translation files are **human‑editable**, ideal for non‑technical translators.  
- Engines and loaders can be replaced or extended.  
- Works seamlessly with other PlComponents.  
- Supports full **Unicode** and UTF‑8/UTF‑16 workflows.

---

## Conclusion
The Pl Translation System provides a clean, modular, and extensible foundation for runtime localization in Delphi VCL applications.  
By separating responsibilities across well‑defined units, it ensures maintainability and flexibility while remaining easy to integrate.

Future enhancements may include:
- More translation engines (like XML/YAML)    
- Editor for translation files  
- Real-time, online translation using external services  

---

## References
- Delphi VCL Documentation  
- JSON and INI format specifications  
- Internal PlComponents architecture notes  

---

## Appendix
Additional examples, advanced usage patterns, and engine implementation details may be added in future revisions of this document.
