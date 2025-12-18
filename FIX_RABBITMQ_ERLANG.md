# Fix RabbitMQ ERLANG_HOME Error - Quick Guide

## The Problem
```
ERLANG_HOME not set correctly.
```

RabbitMQ requires Erlang/OTP to run, and the `ERLANG_HOME` environment variable must be set to point to your Erlang installation.

## Solution Steps

### Step 1: Install Erlang (if not already installed)

**Option A: Using Chocolatey (Requires Admin PowerShell)**
1. Open PowerShell **as Administrator**
2. Run: `choco install erlang -y`
3. Note the installation path (usually `C:\Program Files\Erlang OTP`)

**Option B: Manual Download**
1. Go to: https://www.erlang.org/downloads
2. Download and run the Windows installer
3. Note the installation path (usually `C:\Program Files\Erlang OTP`)

**Option C: Using Scoop (if installed)**
1. Run: `scoop install erlang`

### Step 2: Set ERLANG_HOME Environment Variable

**Temporary Fix (Current Session Only):**
```powershell
$env:ERLANG_HOME = "C:\Program Files\Erlang OTP"
```
Replace `"C:\Program Files\Erlang OTP"` with your actual Erlang installation path.

**Permanent Fix (Recommended):**

For your user account:
```powershell
[System.Environment]::SetEnvironmentVariable("ERLANG_HOME", "C:\Program Files\Erlang OTP", "User")
```

For all users (requires Admin):
```powershell
[System.Environment]::SetEnvironmentVariable("ERLANG_HOME", "C:\Program Files\Erlang OTP", "Machine")
```

### Step 3: Verify Setup

```powershell
# Check if ERLANG_HOME is set
$env:ERLANG_HOME

# Verify Erlang is accessible
erl -version
```

### Step 4: Restart Terminal

After setting the environment variable permanently, **close and reopen** your terminal/PowerShell window for changes to take effect.

## Quick Setup Script

If Erlang is already installed, you can use the helper script:

```powershell
.\set-erlang-home.ps1 "C:\Program Files\Erlang OTP"
```

Or run the auto-detect script:
```powershell
.\setup-rabbitmq-env.ps1
```

## Common Erlang Installation Paths

- `C:\Program Files\Erlang OTP`
- `C:\Program Files (x86)\Erlang OTP`
- `%LOCALAPPDATA%\Programs\Erlang OTP`

## Troubleshooting

**If ERLANG_HOME is set but RabbitMQ still fails:**
```powershell
# Verify the path exists
Test-Path $env:ERLANG_HOME

# Verify erl.exe exists
Test-Path "$env:ERLANG_HOME\bin\erl.exe"
```

**Quick Test Command:**
```powershell
if ($env:ERLANG_HOME -and (Test-Path "$env:ERLANG_HOME\bin\erl.exe")) {
    Write-Host "ERLANG_HOME is correctly set!" -ForegroundColor Green
} else {
    Write-Host "ERLANG_HOME is not set correctly" -ForegroundColor Red
}
```

## Additional Step: ERLANG_SERVICE_MANAGER_PATH

If you see this error after setting ERLANG_HOME:
```
ERLANG_SERVICE_MANAGER_PATH not set correctly.
"\erlsrv.exe" not found
```

**Quick Fix:**
Run the service manager setup script:
```powershell
.\fix-rabbitmq-service-manager.ps1
```

**Manual Fix:**
Set ERLANG_SERVICE_MANAGER_PATH to the directory containing erlsrv.exe (usually in the erts subdirectory):
```powershell
# Find erlsrv.exe location first
Get-ChildItem "$env:ERLANG_HOME" -Filter "erlsrv.exe" -Recurse | Select-Object DirectoryName

# Then set it (replace with actual path)
[System.Environment]::SetEnvironmentVariable("ERLANG_SERVICE_MANAGER_PATH", "$env:ERLANG_HOME\erts-<version>\bin", "User")
```

Common location: `C:\Program Files\Erlang OTP\erts-<version>\bin`

## Next Steps

After setting both ERLANG_HOME and ERLANG_SERVICE_MANAGER_PATH:
1. Restart your terminal
2. Try starting RabbitMQ again
3. If issues persist, check RabbitMQ service logs
