# PlDirectoryWatcher

## Overview

`PlDirectoryWatcher` provides a **thread-based directory monitoring service**
for Delphi applications, built directly on top of the Windows API
`ReadDirectoryChangesW`. It enables applications to react to file system changes in 
real time.

It is designed as a **low-level infrastructure component**, reusable and
self-contained, offering:

- Reliable file system change notifications
- Built-in debounce to suppress duplicate events
- Pause / resume support
- Runtime folder switching
- Thread-safe delivery of notifications to the main thread

The core implementation is the class:

- `TDirectoryWatcherThread`

---

## Design Goals

It’s designed for robust, efficient file system monitoring in Delphi.
The component is intentionally designed to:

1. Monitor **a single directory at a time**
2. Optionally include **subdirectory monitoring**
3. Deliver **stable and debounced change events**
4. Remain **independent from UI logic**
5. Be safe to start, pause, resume and destroy at runtime

It deliberately avoids high-level abstractions or policy decisions.

---

## Architecture

```

TDirectoryWatcherThread (TThread)
├─ ReadDirectoryChangesW (WinAPI)
├─ Debounce logic
├─ Pause / Resume control
├─ Runtime folder switching
└─ Main-thread notification dispatch (TThread.Queue)

````

All notifications are dispatched on the **main thread**, making the component
safe to use in VCL applications.

---

## Public Types

### TPlFileChangeAction

Represents the type of file system change detected.

```pascal
TPlFileChangeAction = (
  fcaAdded,
  fcaRemoved,
  fcaModified,
  fcaRenamedOld,
  fcaRenamedNew,
  fcaUnknown
);
````

This enumeration is a normalized abstraction over
`FILE_NOTIFY_INFORMATION.Action`.

---

### TPlOnFolderChange

Event fired for each detected file system change.

```pascal
procedure(Sender: TObject;
          const AFolderName: string;
          AAction: TPlFileChangeAction) of object;
```

* `AFolderName` is the full path of the changed file or folder
* Fired on the **main thread**
* Suitable for UI updates

---

### TPlOnFolderRenamed

Event fired when a rename operation occurs.

```pascal
procedure(Sender: TObject;
          const AOldName, ANewName: string) of object;
```

> Currently reserved for future extensions.

---

## TDirectoryWatcherThread

###Public & Published Members

| **Member**               | **Category**  | **Type**                  | **Description**                                                                 |
|---------------------------|---------------|---------------------------|---------------------------------------------------------------------------------|
| **Constructor Create**    | Public        | Method                    | Creates a watcher thread for a given folder, with options for subtree monitoring, change callback, and start state. |
| **Destructor Destroy**    | Public        | Method override           | Terminates the thread, cancels pending I/O, and releases resources.             |
| **AfterConstruction**     | Public        | Method override           | Starts the thread after construction.                                           |
| **ChangeFolder**          | Public        | Method                    | Switches the watched folder at runtime.                                         |
| **IsDirectory**           | Public        | Method                    | Checks if a given path is a directory.                                          |
| **PauseWatching**         | Public        | Method                    | Pauses monitoring without destroying the thread.                                |
| **ResumeWatching**        | Public        | Method                    | Resumes monitoring after a pause.                                               |
| **Active**                | Published     | Boolean                   | Indicates whether the watcher is active or paused.                              |
| **OnFolderChange**        | Published     | Event (TPlOnFolderChange) | Triggered when a file changes inside the watched folder.                        |
| **OnFolderRenamed**       | Published     | Event (TPlOnFolderRenamed)| Triggered when a folder rename occurs.                                          |

---

### Constructor

```pascal
constructor Create(
  const AFolder: string;
  AWatchSubtree: Boolean;
  AOnChange: TPlOnFolderChange;
  AStartPaused: Boolean = True
);
```

Creates a directory watcher thread.

* `AFolder`
  The directory to monitor.

* `AWatchSubtree`
  If `True`, subdirectories are monitored recursively.

* `AOnChange`
  Callback invoked for each detected change.

* `AStartPaused`
  If `True`, the watcher starts in paused state.

The thread is created suspended and automatically started in
`AfterConstruction`.

---

### Destructor

```pascal
destructor Destroy; override;
```

The destructor:

* Terminates the thread
* Cancels pending I/O operations
* Closes directory handles
* Frees synchronization primitives

This guarantees **safe destruction at any time**, even during active
monitoring.

---

## Properties

### Active

```pascal
property Active: Boolean;
```

Indicates whether the watcher is currently active.

* `True` -> monitoring enabled
* `False` -> monitoring paused

Changing this property internally calls `PauseWatching` or
`ResumeWatching`.

---

## Public Methods

### ChangeFolder

```pascal
procedure ChangeFolder(const ANewFolder: string);
```

Requests a **runtime change of the monitored folder**.

* The request is stored atomically
* The actual switch is applied inside the worker thread
* The directory handle is safely reopened

This allows dynamic scenarios such as switching language folders.

---

### PauseWatching

```pascal
procedure PauseWatching;
```

Pauses monitoring without terminating the thread.

* The thread remains alive
* No file system events are processed

---

### ResumeWatching

```pascal
procedure ResumeWatching;
```

Resumes monitoring after a pause.

---

### IsDirectory

```pascal
function IsDirectory(const APath: string): Boolean;
```

Utility method that checks whether a given path refers to a directory.

---

## Threading Model

* Monitoring runs entirely inside a **dedicated worker thread**
* Shared state is protected by a critical section
* Notifications are delivered using `TThread.Queue`
* The main thread is never blocked

This makes the component safe for use in VCL and FMX applications.

---

## Debounce Logic

To avoid duplicate notifications caused by rapid file system activity:

* Each event is compared with the previous one
* If the same file and action occur within **250 ms**, the event is ignored

This significantly improves signal quality and avoids unnecessary UI refreshes.

---

## Runtime Folder Switching

The watcher supports changing the monitored directory at runtime:

* The request is queued safely
* Applied inside the execution loop
* No race conditions with ongoing I/O

This behavior is intentional and defensive.

---

## Intentional Design Limits

The following limitations are **by design**:

1. **Single directory per watcher**
2. **Windows-only implementation** (uses Win32 API)
3. No file content inspection
4. No persistence or historical tracking
5. No automatic error recovery strategy
6. Folder rename events are not fully tracked (only file rename)  

Higher-level behavior must be implemented by the application.

---

## Best Practices

* Use one watcher per logical directory
* Always destroy the watcher explicitly on application shutdown
* Keep event handlers lightweight
* Avoid blocking operations inside callbacks

---

## Typical Usage

```pascal
Watcher := TDirectoryWatcherThread.Create(
  'C:\\Languages',
  True,
  OnFolderChanged,
  False
);
```

---

## Contributing

Contributions are welcome. You can help improve:
* Handling of complex rename scenarios  
* Cross-platform support (e.g., Linux inotify)  
* Configurable debounce and filtering options  

Please open issues or submit pull requests on GitHub.

---

Released under the **MIT License**. See the LICENSE file for details.

---