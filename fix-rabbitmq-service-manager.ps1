# Fix ERLANG_SERVICE_MANAGER_PATH for RabbitMQ
# This script locates erlsrv.exe and sets ERLANG_SERVICE_MANAGER_PATH

Write-Host "RabbitMQ Service Manager Path Setup" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""

$erlsrvPath = $null
$erlsrvDir = $null

# Check if ERLANG_HOME is set
if (-not $env:ERLANG_HOME) {
    Write-Host "ERLANG_HOME is not set!" -ForegroundColor Red
    Write-Host "Please set ERLANG_HOME first, then run this script again." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To set ERLANG_HOME:" -ForegroundColor Cyan
    Write-Host '  [System.Environment]::SetEnvironmentVariable("ERLANG_HOME", "D:\Program Files\ErlangOTP\Erlang OTP", "User")' -ForegroundColor White
    exit 1
}

Write-Host "ERLANG_HOME is set to: $env:ERLANG_HOME" -ForegroundColor Green
Write-Host ""

# Common locations for erlsrv.exe within Erlang installation
$searchPaths = @(
    "$env:ERLANG_HOME\bin\erlsrv.exe",
    "$env:ERLANG_HOME\erts-*\bin\erlsrv.exe",
    "$env:ERLANG_HOME\lib\erlsrv-*\priv\bin\erlsrv.exe"
)

Write-Host "Searching for erlsrv.exe..." -ForegroundColor Yellow

# Check direct bin path
if (Test-Path "$env:ERLANG_HOME\bin\erlsrv.exe") {
    $erlsrvPath = "$env:ERLANG_HOME\bin\erlsrv.exe"
    $erlsrvDir = "$env:ERLANG_HOME\bin"
    Write-Host "Found at: $erlsrvPath" -ForegroundColor Green
} else {
    # Search in erts subdirectories
    $ertsDirs = Get-ChildItem "$env:ERLANG_HOME" -Directory -Filter "erts-*" -ErrorAction SilentlyContinue
    foreach ($ertsDir in $ertsDirs) {
        $testPath = Join-Path $ertsDir.FullName "bin\erlsrv.exe"
        if (Test-Path $testPath) {
            $erlsrvPath = $testPath
            $erlsrvDir = Join-Path $ertsDir.FullName "bin"
            Write-Host "Found at: $erlsrvPath" -ForegroundColor Green
            break
        }
    }
    
    # If still not found, search more broadly
    if (-not $erlsrvPath) {
        $found = Get-ChildItem "$env:ERLANG_HOME" -Filter "erlsrv.exe" -Recurse -ErrorAction SilentlyContinue -Depth 5 | Select-Object -First 1
        if ($found) {
            $erlsrvPath = $found.FullName
            $erlsrvDir = $found.DirectoryName
            Write-Host "Found at: $erlsrvPath" -ForegroundColor Green
        }
    }
}

# If still not found, provide guidance
if (-not $erlsrvPath) {
    Write-Host ""
    Write-Host "erlsrv.exe not found in ERLANG_HOME!" -ForegroundColor Red
    Write-Host ""
    Write-Host "This usually means:" -ForegroundColor Yellow
    Write-Host "1. The Erlang installation is incomplete" -ForegroundColor White
    Write-Host "2. erlsrv.exe was not included in your Erlang distribution" -ForegroundColor White
    Write-Host ""
    Write-Host "SOLUTION OPTIONS:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Option 1: Reinstall Erlang with full installation" -ForegroundColor Yellow
    Write-Host "  - Download from: https://www.erlang.org/downloads" -ForegroundColor White
    Write-Host "  - Make sure to install the complete package" -ForegroundColor White
    Write-Host ""
    Write-Host "Option 2: Install via Chocolatey (includes all components)" -ForegroundColor Yellow
    Write-Host "  choco install erlang -y" -ForegroundColor White
    Write-Host ""
    Write-Host "Option 3: If erlsrv.exe exists elsewhere, set ERLANG_SERVICE_MANAGER_PATH manually:" -ForegroundColor Yellow
    Write-Host '  $env:ERLANG_SERVICE_MANAGER_PATH = "C:\path\to\directory\containing\erlsrv.exe"' -ForegroundColor White
    Write-Host '  [System.Environment]::SetEnvironmentVariable("ERLANG_SERVICE_MANAGER_PATH", "C:\path\to\directory", "User")' -ForegroundColor White
    Write-Host ""
    
    # Ask if user wants to search system-wide (might be slow)
    Write-Host "Would you like to search the entire system for erlsrv.exe? (This may take a while)" -ForegroundColor Cyan
    Write-Host "Note: This script is running in non-interactive mode, so performing limited search..." -ForegroundColor Yellow
    
    # Do a limited search in common locations
    $commonSystemPaths = @(
        "C:\Program Files\Erlang OTP",
        "C:\Program Files (x86)\Erlang OTP",
        "$env:ProgramFiles\Erlang OTP"
    )
    
    foreach ($sysPath in $commonSystemPaths) {
        if (Test-Path $sysPath) {
            $found = Get-ChildItem $sysPath -Filter "erlsrv.exe" -Recurse -ErrorAction SilentlyContinue -Depth 3 | Select-Object -First 1
            if ($found) {
                $erlsrvPath = $found.FullName
                $erlsrvDir = $found.DirectoryName
                Write-Host "Found erlsrv.exe in alternative location: $erlsrvPath" -ForegroundColor Green
                Write-Host "Consider updating ERLANG_HOME to: $(Split-Path (Split-Path $found.DirectoryName))" -ForegroundColor Yellow
                break
            }
        }
    }
    
    if (-not $erlsrvPath) {
        exit 1
    }
}

# Set the environment variable
Write-Host ""
Write-Host "Setting ERLANG_SERVICE_MANAGER_PATH..." -ForegroundColor Yellow
Write-Host "Path: $erlsrvDir" -ForegroundColor White

# Set for current session
$env:ERLANG_SERVICE_MANAGER_PATH = $erlsrvDir
Write-Host "Set for current session: OK" -ForegroundColor Green

# Set permanently for user
try {
    [System.Environment]::SetEnvironmentVariable("ERLANG_SERVICE_MANAGER_PATH", $erlsrvDir, "User")
    Write-Host "Set permanently for user: OK" -ForegroundColor Green
    Write-Host ""
    Write-Host "Restart your terminal for the changes to take effect." -ForegroundColor Yellow
} catch {
    Write-Host "Could not set permanently: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host "To set permanently, run as Administrator:" -ForegroundColor Yellow
    Write-Host "  [System.Environment]::SetEnvironmentVariable(`"ERLANG_SERVICE_MANAGER_PATH`", `"$erlsrvDir`", `"Machine`")" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "Setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Verification:" -ForegroundColor Cyan
Write-Host "  ERLANG_SERVICE_MANAGER_PATH = $env:ERLANG_SERVICE_MANAGER_PATH" -ForegroundColor White
Write-Host "  erlsrv.exe location = $erlsrvPath" -ForegroundColor White
Write-Host ""
Write-Host "You can now try starting RabbitMQ again." -ForegroundColor Cyan
