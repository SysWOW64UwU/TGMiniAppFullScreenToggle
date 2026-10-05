# Telegram Mini App Fullscreen Toggle (`TDesktop`)
An AutoHotkey (AHK v2) script that brings the native Windows **F11 Fullscreen experience** to Telegram Mini Apps running on Telegram Desktop.

## 📺 Preview
https://github.com/user-attachments/assets/e23609c1-17da-4e04-b9a1-11e2c4df7aaa


---
## ⚡ Quick Start Guide

### Prerequisites
*   **Operating System:** Windows
*   **AutoHotkey:** [AHK v2.0+](https://autohotkey.com) installed.
*   **Telegram Desktop Configuration:** **Experimental WebView inspection** must be enabled:
    1. Open Telegram `Settings` (or navigate via `tg://settings`).
    2. Go to `Advanced` > `Experimental Settings`.
    3. Toggle **WebView inspection** to **ON**.

### Installation
1. Download the main script file: [TDMiniAppFullScreen.ahk](https://github.com/SysWOW64UwU/TGMiniAppFullScreenToggle/raw/refs/heads/main/TDMiniAppFullScreen.ahk).
2. Launch it manually by double-clicking the file.
3. *(Optional)* To run it automatically when Windows starts, press `Win + R`, type `shell:startup`, hit enter, and place a shortcut to the script in that directory.

### How to Make Telegram Mini Apps Fullscreen on Desktop
1. Open any Telegram Mini App.
2. Click inside the Mini App window to make sure it is active.
3. Press **`F11`** to toggle fullscreen mode.
4. Press **`F11`** again to exit fullscreen.

---

## 🛠️ Troubleshooting Guide

If you see an error box saying **"WebView inspection must be enabled..."** even though you have already turned the setting on in Telegram, your computer might just need a tiny bit more time to load the background developer tools. 

You can easily fix this by making the script run slightly slower to match your PC's speed. Here is how to adjust it:

### 1. Fix the False "WebView Inspection" Error
If your computer takes longer than 3 seconds to generate the window, the script stops and throws an error.
1. Right-click `TDMiniAppFullScreen.ahk` and open it with **Notepad** (or any text editor).
2. Look for this line (around line 30):
   ```autohotkey
   devtoolsHWND := WinWait("DevTools - ", , 3)
   ```
3. Change the number `3` to a higher value like `5` or `7`. This gives your PC more seconds to load the system before giving up.
4. Save the file and restart the script.

### 2. Fix Fullscreen Failing to Trigger (Command Injected Too Fast)
If the error box does not appear, but pressing `F11` still does nothing, the script might be typing the fullscreen command before the background window is ready to receive it.
1. Open the script with **Notepad**.
2. Locate this block of code (around line 36):
   ```autohotkey
   WinSetTransparent(0, "ahk_id " devtoolsHWND)
   ControlSend("{Text}" jsCommand, , "ahk_id " devtoolsHWND)
   Sleep(50)
   ControlSend("{Enter}", , "ahk_id " devtoolsHWND)
   Sleep(100)
   ```
3. Increase the `Sleep` values. Try changing `Sleep(50)` to `Sleep(150)` and `Sleep(100)` to `Sleep(200)`. *(Note: These numbers are measured in milliseconds, so 1000 = 1 second).*
4. Save the file and restart the script.

---

## 📜 How It Works

The main script (`TDMiniAppFullScreen.ahk`) injects JavaScript directly into the Mini App's rendering instance using Chromium DevTools hooks. It interacts natively with the official Telegram WebApp API wrappers:

*   **Enter Fullscreen:** 
    ```javascript
    window.Telegram.WebApp.expand(); 
    window.Telegram.WebApp.requestFullscreen();
    ```
*   **Exit Fullscreen:** 
    ```javascript
    window.Telegram.WebApp.exitFullscreen();
    ```

---

## 🔀 Legacy Alternative (`TDMiniAppFullScreen_AHKCore.ahk`)

Before building the JavaScript injection engine, a fully AHK-native prototype was created. While it does **not** require WebView inspection to be enabled, it is highly experimental and comes with distinct caveats.

> 💡 **Note:** This version is not recommended for normal usage.

### Known Limitations
*   **Focus Drop:** Certain internal UI updates within a Mini App can kick it back out to windowed mode, requiring you to hit `F11` again.
*   **Hidden UI Elements:** The native Windows framing hides header components. You may need to exit fullscreen just to navigate backward or quit the app cleanly.

---

## 📝 License

This project is licensed under the **WTFPL (Do What The Fuck You Want To Public License)**. 

```text
            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
                    Version 2, December 2004

 Copyright (C) 2004 Sam Hocevar <sam@hocevar.net>

 Everyone is permitted to copy and distribute verbatim or modified
 copies of this license document, and changing it is allowed as long
 as the name is changed.

            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION

  0. You just DO WHAT THE FUCK YOU WANT TO.
```
