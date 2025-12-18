# RabbitMQ Environment Setup Script for Windows
# This script helps configure ERLANG_HOME for RabbitMQ

Write-Host "RabbitMQ Environment Setup" -ForegroundColor Cyan
Write-Host "==========================" -ForegroundColor Cyan
Write-Host ""

# Common Erlang installation locations
$possiblePaths = @(
    "C:\Program Files\Erlang OTP",
    "C:\Program Files (x86)\Erlang OTP",
    "$env:LOCALAPPDATA\Programs\Erlang OTP",
    "C:\erl*",
    "$env:ProgramFiles\erl*"
)

$erlPath = $null

# Check if erl.exe exists in PATH
$erlExe = Get-Command erl -ErrorAction SilentlyContinue
if ($erlExe) {
    $erlDir = Split-Path (Split-Path $erlExe.Source)
    if (Test-Path (Join-Path $erlDir "bin\erl.exe")) {
        $erlPath = $erlDir
        Write-Host "Found Erlang in PATH: $erlPath" -ForegroundColor Green
    }
}

# Search common installation locations
if (-not $erlPath) {
    Write-Host "Searching for Erlang installation..." -ForegroundColor Yellow
    foreach ($path in $possiblePaths) {
        $resolvedPath = $path
        if ($path -like "*\erl*") {
            $dirs = Get-ChildItem (Split-Path $path) -Filter "erl*" -Directory -ErrorAction SilentlyContinue
            if ($dirs) {
                $resolvedPath = $dirs[0].FullName
            } else {
                continue
            }
        }
        
        if (Test-Path $resolvedPath) {
            $erlExePath = Join-Path $resolvedPath "bin\erl.exe"
            if (Test-Path $erlExePath) {
                $erlPath = $resolvedPath
                Write-Host "Found Erlang at: $erlPath" -ForegroundColor Green
                break
            }
        }
    }
}

# If still not found, provide installation instructions
if (-not $erlPath) {
    Write-Host ""
    Write-Host "Erlang not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install Erlang/OTP from one of these sources:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "OPTION 1 - Chocolatey (Recommended if installed):" -ForegroundColor Cyan
    Write-Host "  choco install erlang" -ForegroundColor White
    Write-Host ""
    Write-Host "OPTION 2 - Scoop (Recommended if installed):" -ForegroundColor Cyan
    Write-Host "  scoop install erlang" -ForegroundColor White
    Write-Host ""
    Write-Host "OPTION 3 - Official Installer:" -ForegroundColor Cyan
    Write-Host "  Download from: https://www.erlang.org/downloads" -ForegroundColor White
    Write-Host "  Install and note the path (usually C:\Program Files\Erlang OTP)" -ForegroundColor White
    Write-Host ""
    Write-Host "After installation, run this script again or set ERLANG_HOME manually:" -ForegroundColor Yellow
    Write-Host '  [System.Environment]::SetEnvironmentVariable("ERLANG_HOME", "C:\Program Files\Erlang OTP", "User")' -ForegroundColor Cyan
    Write-Host ""
    Write-Host "To set ERLANG_HOME manually (replace with your actual path):" -ForegroundColor Yellow
    Write-Host '  $env:ERLANG_HOME = "C:\Program Files\Erlang OTP"  # Temporary for current session' -ForegroundColor Cyan
    Write-Host '  [System.Environment]::SetEnvironmentVariable("ERLANG_HOME", "C:\Program Files\Erlang OTP", "User")  # Permanent' -ForegroundColor Cyan
    Write-Host ""
    
    # Check if Chocolatey is available
    $chocoAvailable = Get-Command choco -ErrorAction SilentlyContinue
    if ($chocoAvailable) {
        Write-Host "Chocolatey is available. You can install Erlang by running:" -ForegroundColor Green
        Write-Host "  choco install erlang" -ForegroundColor White
        Write-Host ""
    }
    
    exit 1
}

# Verify the path contains erl.exe
$erlExePath = Join-Path $erlPath "bin\erl.exe"
if (-not (Test-Path $erlExePath)) {
    Write-Host "Error: erl.exe not found at $erlExePath" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Setting ERLANG_HOME environment variable..." -ForegroundColor Yellow
Write-Host "Path: $erlPath" -ForegroundColor White

# Set for current session
$env:ERLANG_HOME = $erlPath
Write-Host "Set for current session: OK" -ForegroundColor Green

# Set permanently for user
try {
    [System.Environment]::SetEnvironmentVariable("ERLANG_HOME", $erlPath, "User")
    Write-Host "Set permanently for user: OK" -ForegroundColor Green
} catch {
    Write-Host "Could not set permanently for user (requires admin): $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host "To set permanently, run as Administrator:" -ForegroundColor Yellow
    Write-Host "  [System.Environment]::SetEnvironmentVariable(`"ERLANG_HOME`", `"$erlPath`", `"Machine`")" -ForegroundColor Cyan
}

# Also set ERLANG_SERVICE_MANAGER_PATH (for erlsrv.exe)
Write-Host ""
Write-Host "Setting ERLANG_SERVICE_MANAGER_PATH..." -ForegroundColor Yellow

$erlsrvPath = $null
$erlsrvDir = $null

# Check direct bin path first
if (Test-Path (Join-Path $erlPath "bin\erlsrv.exe")) {
    $erlsrvDir = Join-Path $erlPath "bin"
    $erlsrvPath = Join-Path $erlsrvDir "erlsrv.exe"
} else {
    # Search in erts subdirectories
    $ertsDirs = Get-ChildItem $erlPath -Directory -Filter "erts-*" -ErrorAction SilentlyContinue
    foreach ($ertsDir in $ertsDirs) {
        $testPath = Join-Path $ertsDir.FullName "bin\erlsrv.exe"
        if (Test-Path $testPath) {
            $erlsrvDir = Join-Path $ertsDir.FullName "bin"
            $erlsrvPath = $testPath
            break
        }
    }
    
    # If still not found, search more broadly
    if (-not $erlsrvPath) {
        $found = Get-ChildItem $erlPath -Filter "erlsrv.exe" -Recurse -ErrorAction SilentlyContinue -Depth 5 | Select-Object -First 1
        if ($found) {
            $erlsrvDir = $found.DirectoryName
            $erlsrvPath = $found.FullName
        }
    }
}

if ($erlsrvPath) {
    Write-Host "Found erlsrv.exe at: $erlsrvPath" -ForegroundColor Green
    Write-Host "Setting ERLANG_SERVICE_MANAGER_PATH to: $erlsrvDir" -ForegroundColor White
    
    # Set for current session
    $env:ERLANG_SERVICE_MANAGER_PATH = $erlsrvDir
    Write-Host "Set for current session: OK" -ForegroundColor Green
    
    # Set permanently for user
    try {
        [System.Environment]::SetEnvironmentVariable("ERLANG_SERVICE_MANAGER_PATH", $erlsrvDir, "User")
        Write-Host "Set permanently for user: OK" -ForegroundColor Green
    } catch {
        Write-Host "Could not set permanently: $($_.Exception.Message)" -ForegroundColor Yellow
    }
} else {
    Write-Host "Warning: erlsrv.exe not found. RabbitMQ may still work, but service management might fail." -ForegroundColor Yellow
    Write-Host "If you get ERLANG_SERVICE_MANAGER_PATH errors, run: .\fix-rabbitmq-service-manager.ps1" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "You can now start RabbitMQ. If you set variables for user, you may need to restart your terminal." -ForegroundColor Cyan
Write-Host "To verify, run:" -ForegroundColor Cyan
Write-Host "  `$env:ERLANG_HOME" -ForegroundColor White
Write-Host "  `$env:ERLANG_SERVICE_MANAGER_PATH" -ForegroundColor White
