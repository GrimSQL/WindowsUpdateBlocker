# Windows Update Blocker

A lightweight (42 KB) dark-mode utility to pause or resume Windows Updates.

![Dark Mode UI](https://img.shields.io/badge/UI-Dark%20Mode-181716) ![Size](https://img.shields.io/badge/Size-42%20KB-green) ![Windows](https://img.shields.io/badge/Windows-10%2F11-blue)

## Features

- **Dark Mode UI** - Beautiful dark theme with dark title bar
- **Pause Updates** - Block Windows Updates indefinitely (until 2099)
- **Resume Updates** - Restore normal Windows Update behavior  
- **Status Indicator** - Clear visual feedback on current state
- **About Tab** - Information about how the tool works
- **Tiny Size** - Only 42 KB!

## Download

**[Download WindowsUpdateBlocker.exe](WindowsUpdateBlocker.exe)** (42 KB)

Just download and run - no installation required!

## Files

| File | Description |
|------|-------------|
| `WindowsUpdateBlocker.exe` | The compiled program - **this is all you need** |
| `WindowsUpdateBlocker.ps1` | Source code (PowerShell + WPF) |

## Usage

1. **Right-click** `WindowsUpdateBlocker.exe` and select **Run as administrator**
2. Click **PAUSE UPDATES** to block Windows Updates
3. Click **RESUME UPDATES** to allow Windows Updates again

The status indicator shows:
-  **Green** = Updates are active (normal)
-  **Red** = Updates are paused (blocked)

## How It Works

The tool modifies Windows Update registry settings at:
```
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings
```

**Pause (blocks updates):**
- Sets `PauseUpdatesExpiryTime` to `2099-11-11`
- Sets `PauseFeatureUpdatesEndTime` to `2099-11-11`
- Sets `PauseQualityUpdatesEndTime` to `2099-11-11`
- Sets corresponding start times to `1990-11-22`

**Resume (allows updates):**
- Removes all the pause-related registry values

## Technical Details

### Why is it only 42 KB?

This tool is built using **PowerShell + WPF** and compiled to an EXE using **[PS2EXE](https://github.com/MScholtes/PS2EXE)**.

Instead of bundling the entire .NET runtime (which would be ~150 MB), it uses:
- Windows built-in **PowerShell 5.1** (pre-installed on Windows 10/11)
- Windows built-in **WPF framework** (pre-installed on Windows)

This results in a tiny 42 KB executable that works on any Windows 10/11 system without additional dependencies.

### Building from Source

If you want to modify the tool and rebuild it:

1. **Install PS2EXE module:**
   ```powershell
   Install-Module -Name ps2exe -Scope CurrentUser
   ```

2. **Edit the source code:**
   - Open `WindowsUpdateBlocker.ps1` in any text editor
   - Make your changes

3. **Compile to EXE:**
   ```powershell
   Invoke-PS2EXE -InputFile ".\WindowsUpdateBlocker.ps1" -OutputFile ".\WindowsUpdateBlocker.exe" -NoConsole -RequireAdmin
   ```

### Requirements

- Windows 10 or Windows 11
- PowerShell 5.1 (pre-installed on Windows 10/11)
- Administrator privileges (to modify registry)

## Screenshots

The application features:
- Custom dark title bar (#181716)
- Dark background (#181716 and #1f1e1c)
- Status card with color-coded indicator
- Red Pause button / Green Resume button
- About tab with usage information

## License

Use at your own risk. This tool modifies Windows registry settings.

---

Made by [GrimSQL](https://github.com/GrimSQL)
