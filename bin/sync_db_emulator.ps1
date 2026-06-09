# Sincroniza data/following_practices.db con el emulador Android (modo debug).
# Uso:
#   .\bin\sync_db_emulator.ps1 push
#   .\bin\sync_db_emulator.ps1 pull
#   .\bin\sync_db_emulator.ps1 push -Device emulator-5556

param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("push", "pull")]
    [string]$Action,
    [string]$Device = ""
)

$ErrorActionPreference = "Stop"

$adb = Join-Path $env:LOCALAPPDATA "Android\Sdk\platform-tools\adb.exe"
$root = Resolve-Path (Join-Path $PSScriptRoot "..")
$localDb = Join-Path $root "data\following_practices.db"
$localDbTmp = "$localDb.tmp"
$localDbErr = "$localDb.err"

$package = "com.example.following_practices"
$tmpDb = "/data/local/tmp/following_practices.db"
$appDb = "app_flutter/data/following_practices.db"

if (-not (Test-Path $adb)) {
    throw "No se encontró adb en: $adb"
}

$adbTarget = @()
if ($Device) {
    $adbTarget = @("-s", $Device)
}

$dataDir = Split-Path $localDb -Parent
if (-not (Test-Path $dataDir)) {
    New-Item -ItemType Directory -Path $dataDir | Out-Null
}

function Invoke-Adb {
    param([Parameter(ValueFromRemainingArguments = $true)][string[]]$Args)
    & $adb @adbTarget @Args
}

function Copy-ToAppDir {
    $inner = "mkdir -p app_flutter/data && cp $tmpDb $appDb"
    & $adb @adbTarget shell "run-as $package sh -c '$inner'" 2>$null | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "App aún no instalada: se copiará al arrancar desde $tmpDb"
    }
}

function Test-DbFile {
    param([string]$Path)
    return (Test-Path $Path) -and ((Get-Item $Path).Length -gt 512)
}

function Pull-FromApp {
    Remove-Item $localDbTmp, $localDbErr -Force -ErrorAction SilentlyContinue

    $args = @()
    if ($Device) { $args += "-s", $Device }
    $args += "exec-out", "run-as", $package, "cat", $appDb

    $proc = Start-Process -FilePath $adb -ArgumentList $args `
        -RedirectStandardOutput $localDbTmp `
        -RedirectStandardError $localDbErr `
        -Wait -NoNewWindow -PassThru

    return ($proc.ExitCode -eq 0) -and (Test-DbFile $localDbTmp)
}

function Pull-FromTmp {
    Remove-Item $localDbTmp -Force -ErrorAction SilentlyContinue
    Invoke-Adb pull $tmpDb $localDbTmp 2>$null | Out-Null
    return (Test-DbFile $localDbTmp)
}

function Save-PulledDb {
    Copy-Item -Force $localDbTmp $localDb
    Remove-Item $localDbTmp -Force -ErrorAction SilentlyContinue
    Write-Host "BD guardada en: $localDb"
}

switch ($Action) {
    "push" {
        if (-not (Test-Path $localDb)) {
            Write-Host "No existe $localDb. Ejecute primero: dart run bin/migrate.dart"
            exit 1
        }
        Invoke-Adb push $localDb $tmpDb
        Copy-ToAppDir
        $label = if ($Device) { $Device } else { "emulador por defecto" }
        Write-Host "BD enviada al $label (tmp + app si está instalada)."
    }
    "pull" {
        $pulled = $false
        $maxAttempts = 5

        for ($i = 1; $i -le $maxAttempts; $i++) {
            Write-Host "Intento $i/$maxAttempts..."
            Invoke-Adb wait-for-device 2>$null | Out-Null
            Start-Sleep -Seconds 2

            if (Pull-FromApp) {
                $pulled = $true
                break
            }
            if (Pull-FromTmp) {
                $pulled = $true
                break
            }
        }

        if ($pulled) {
            Save-PulledDb
            exit 0
        }

        Write-Warning "No se pudo obtener la BD (emulador offline o app sin datos)."
        Write-Warning "Espere 5 s y ejecute: .\bin\sync_db_emulator.ps1 pull -Device $Device"
        exit 1
    }
}
