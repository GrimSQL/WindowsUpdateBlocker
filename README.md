# Windows Update Blocker

A simple, elegant dark-mode utility to pause or resume Windows Updates.

## Features

-  **Dark Mode UI** - Beautiful dark theme with custom title bar
-  **Pause Updates** - Block Windows Updates indefinitely (until 2099)
-  **Resume Updates** - Restore normal Windows Update behavior
-  **Status Indicator** - Clear visual feedback on current state
- ? **About Tab** - Information about how the tool works

## Download

Two versions are available in the `dist` folder:

| File | Size | Requirements |
|------|------|--------------|
| `WindowsUpdateBlocker-Standalone.exe` | ~154 MB | None (works on any Windows) |
| `WindowsUpdateBlocker-Small.exe` | ~148 KB | .NET 8 Runtime installed |

## Usage

1. **Run as Administrator** - Required for registry modifications
2. Click **PAUSE UPDATES** to block Windows Updates
3. Click **RESUME UPDATES** to allow Windows Updates again

## How It Works

The tool modifies Windows Update registry settings:

**Location:** `HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings`

**Pause (blocks updates):**
- Sets `PauseUpdatesExpiryTime` to 2099-11-11
- Sets `PauseFeatureUpdatesEndTime` to 2099-11-11
- Sets `PauseQualityUpdatesEndTime` to 2099-11-11

**Resume (allows updates):**
- Removes all pause-related registry values

## Building from Source

Requirements: .NET 8 SDK

```powershell
# Build self-contained EXE
dotnet publish -c Release -r win-x64 --self-contained true /p:PublishSingleFile=true

# Build smaller EXE (requires .NET runtime)
dotnet publish -c Release --self-contained false
```

## Screenshots

The application features a clean, modern dark interface with:
- Custom dark title bar
- Status card showing current update state
- Color-coded buttons (red for pause, green for resume)
- About tab with usage information

## License

Use at your own risk. This tool modifies Windows registry settings.

---

 2026
