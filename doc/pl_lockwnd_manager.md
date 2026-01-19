# PlLockWndManager

## Overview

`TPlLockWndManager` is a Delphi component that manages redraw locking on a target window using the Windows message `WM_SETREDRAW`.  
Locking is reference‑counted, meaning multiple calls to `AddLock` can be balanced with corresponding calls to `RemoveLock`.  
This is useful when performing batch updates on controls or forms, preventing flicker and unnecessary redraws until the operation is complete.

---

## Features

- Lock and unlock window redraw using `WM_SETREDRAW`  
- Reference‑counted locking: multiple locks must be released before redraw resumes  
- Automatic unlock on destruction if still active  
- Optional targeting of a specific window handle (`HWND`)  
- Events fired before applying a lock and after removing a lock  

---

## Public Members

| **Member**               | **Category**  | **Type**                  | **Description**                                                                 |
|---------------------------|---------------|---------------------------|---------------------------------------------------------------------------------|
| **Create(AOwner: TComponent)** | Public | Constructor override | Initializes the manager using the owner’s window handle if available, otherwise the main form. |
| **Create(AOwner: TComponent; ATarget: HWND)** | Public | Constructor | Initializes the manager targeting a specific window handle.                      |
| **Destroy**               | Public        | Destructor override       | Ensures any active lock is released before destruction.                         |
| **AddLock**               | Public        | Method                    | Increases the lock counter and applies `WM_SETREDRAW(False)` when transitioning to locked state. |
| **RemoveLock**            | Public        | Method                    | Decreases the lock counter and releases `WM_SETREDRAW(True)` when the counter reaches zero. |
| **ResetCounter**          | Public        | Method                    | Forces immediate unlock regardless of counter by resetting it safely.           |
| **Count**                 | Published     | Property (Integer)        | Current lock counter.                                                           |
| **AfterRemoveLock**       | Published     | Event (TNotifyEvent)      | Fired after the lock is removed and redraw is re‑enabled.                       |
| **BeforeAddLock**         | Published     | Event (TNotifyEvent)      | Fired before the lock is applied.                                               |

---

## Internal Behavior

- **Locking:** When the counter transitions from 0 to 1, `WM_SETREDRAW(False)` is sent to the target window.  
- **Unlocking:** When the counter returns to 0, `WM_SETREDRAW(True)` is sent, followed by a full redraw (`RedrawWindow`).  
- **Thread Safety:** Operations on the counter are protected with `TMonitor.Enter/Exit`.  
- **Target Window:** Determined from the owner’s handle, the main form, or explicitly provided via constructor.  

---

## Example Usage

```delphi
var
  LockManager: TPlLockWndManager;
begin
  // Create lock manager for the main form
  LockManager := TPlLockWndManager.Create(Form1);

  // Batch update without flicker
  LockManager.AddLock;
  try
    // Perform multiple UI changes here
    Edit1.Text := 'Updated';
    Edit2.Text := 'Updated';
  finally
    LockManager.RemoveLock;
  end;
end;
```

---

## Limitations

- Works only on Windows (depends on `WM_SETREDRAW` and WinAPI).  
- Requires a valid `HWND` to operate.  
- Locking is reference‑counted; forgetting to call `RemoveLock` will keep the window locked.  

---

## Contributing

Contributions are welcome. Possible improvements include:  
- Adding support for multiple target windows  
- Extending functionality to FireMonkey (FMX) applications  
- Providing optional automatic scope‑based locking (RAII style)  

---

## License

Released under the MIT License. See the LICENSE file for details.
