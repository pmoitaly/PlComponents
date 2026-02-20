# Pl Language System

## Overview

The PlComponents library comes with a lightweight, extensible, and fully off-line, runtime‑oriented localization framework designed for VCL applications.  
It provides a modular architecture that separates:

- **storage** of translated strings  
- **loading** of language metadata  
- **encoding/decoding** of translation files  
- **runtime language switching**  
- **integration with UI controls**  

The system is built to be **simple**, **non‑intrusive**, and **easy to extend**, avoiding the complexity of traditional resource‑based localization.

It is ideal for applications that require:

- dynamic language switching  
- user‑editable translation files  
- JSON/INI‑based localization  
- custom translation engines  
- integration with non‑visual components  

---

## Architecture

The Translation System is composed of several units, each with a clear responsibility:

* [TPlLanguageServer](pl_language_server.md)
* [TPlLanguage](pl_language.md)
* [TPlLanguageEngineFactory](pl_language_engine_factory.md)
 [TPlLanguageEngine](pl_language_engine.md))
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

## Features

- **Runtime language switching**  
  No recompilation required.

- **Multiple file formats**  
  INI and JSON supported out of the box.

- **Extensible architecture**  
  Add custom engines or loaders easily.

- **Human‑editable translation files**  
  Ideal for non‑technical translators.

- **Non‑intrusive integration**  
  Works with any VCL application.

- **Unicode‑safe**  
  Full UTF‑8/UTF‑16 support.

---

## Example Usage

See Demo application.

---

## Integration Notes

- The system is **non‑visual** and can be dropped into any project.  
- Engines can be replaced or extended without modifying application code.  
- Translation files can be reloaded at runtime.  
- The system is designed to work well with other VCL components.

---

## Roadmap

- More translation engines (XML/YAML)    
- Editor for translation files  
- Real time on line translation using external services  

---

## License

Released under the MIT License.  
See the `LICENSE` file for details.
