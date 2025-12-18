# RabbitMQ Setup Guide for Windows

## Problem
When starting RabbitMQ, you may see this error:
```
ERLANG_HOME not set correctly.
```

## Solution

### Option 1: Automatic Setup (Recommended)
Run the PowerShell setup script:
```powershell
.\setup-rabbitmq-env.ps1
```

### Option 2: Manual Setup

#### Step 1: Install Erlang/OTP
RabbitMQ requires Erlang to run. Install it using one of these methods:

**Using Chocolatey:**
```powershell
choco install erlang
```

**Using Scoop:**
```powershell
scoop install erlang
```

**Manual Installation:**
1. Download from: https://www.erlang.org/downloads
2. Run the installer
3. Note the installation path (usually `C:\Program Files\Erlang OTP`)

#### Step 2: Set ERLANG_HOME Environment Variable

**Temporary (Current Session Only):**
```powershell
$env:ERLANG_HOME = "C:\Program Files\Erlang OTP"
```

**Permanent (User):**
```powershell
[System.Environment]::SetEnvironmentVariable("ERLANG_HOME", "C:\Program Files\Erlang OTP", "User")
```

**Permanent (System - Requires Admin):**
```powershell
[System.Environment]::SetEnvironmentVariable("ERLANG_HOME", "C:\Program Files\Erlang OTP", "Machine")
```

Replace `"C:\Program Files\Erlang OTP"` with your actual Erlang installation path.

#### Step 3: Verify Setup
```powershell
# Check if ERLANG_HOME is set
$env:ERLANG_HOME

# Verify Erlang is accessible
erl -version
```

#### Step 4: Restart Terminal
After setting the environment variable permanently, close and reopen your terminal/PowerShell window.

### Common Erlang Installation Paths
- `C:\Program Files\Erlang OTP`
- `C:\Program Files (x86)\Erlang OTP`
- `%LOCALAPPDATA%\Programs\Erlang OTP`

### Troubleshooting

**If ERLANG_HOME is set but RabbitMQ still fails:**
1. Verify the path exists: `Test-Path $env:ERLANG_HOME`
2. Verify erl.exe exists: `Test-Path "$env:ERLANG_HOME\bin\erl.exe"`
3. Check for typos in the path
4. Ensure you've restarted your terminal after setting it permanently

**Quick Test:**
```powershell
if ($env:ERLANG_HOME -and (Test-Path "$env:ERLANG_HOME\bin\erl.exe")) {
    Write-Host "ERLANG_HOME is correctly set!" -ForegroundColor Green
} else {
    Write-Host "ERLANG_HOME is not set correctly" -ForegroundColor Red
}
```
