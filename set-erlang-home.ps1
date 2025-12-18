# Quick script to set ERLANG_HOME if you know the installation path
# Usage: .\set-erlang-home.ps1 "C:\Program Files\Erlang OTP"

param(
    [Parameter(Mandatory=$true)]
    [string]$ErlangPath
)

if (-not (Test-Path $ErlangPath)) {
    Write-Host "Error: Path does not exist: $ErlangPath" -ForegroundColor Red
    exit 1
}

$erlExePath = Join-Path $ErlangPath "bin\erl.exe"
if (-not (Test-Path $erlExePath)) {
    Write-Host "Error: erl.exe not found at $erlExePath" -ForegroundColor Red
    Write-Host "Please verify this is the correct Erlang installation path." -ForegroundColor Yellow
    exit 1
}

Write-Host "Setting ERLANG_HOME to: $ErlangPath" -ForegroundColor Cyan

# Set for current session
$env:ERLANG_HOME = $ErlangPath
Write-Host "Set for current session: OK" -ForegroundColor Green

# Set permanently for user
try {
    [System.Environment]::SetEnvironmentVariable("ERLANG_HOME", $ErlangPath, "User")
    Write-Host "Set permanently for user: OK" -ForegroundColor Green
    Write-Host ""
    Write-Host "Restart your terminal for the changes to take effect." -ForegroundColor Yellow
} catch {
    Write-Host "Could not set permanently: $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Verification:" -ForegroundColor Cyan
Write-Host "  ERLANG_HOME = $env:ERLANG_HOME" -ForegroundColor White
