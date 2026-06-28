# Ejecuta la app en el emulador con sincronización automática de la BD.
#
# 1. push  → envía data/following_practices.db al emulador
# 2. flutter run
# 3. pull  → al terminar (Ctrl+C), trae la BD al PC
#
# Uso:
#   .\bin\run_emulator.ps1
#   .\bin\run_emulator.ps1 -Device emulator-5556
#
# Ver emuladores disponibles:
#   flutter devices

param(
    [string]$Device = ""
)

$ErrorActionPreference = "Stop"

$root = Resolve-Path (Join-Path $PSScriptRoot "..")
Set-Location $root

$adb = Join-Path $env:LOCALAPPDATA "Android\Sdk\platform-tools\adb.exe"

if (-not $Device) {
    $emulators = @()

    if (Test-Path $adb) {
        $emulators = @(
            & $adb devices |
                ForEach-Object {
                    if ($_ -match '^(emulator-\d+)\s+device\b') {
                        $matches[1]
                    }
                } |
                Where-Object { $_ }
        )
    }

    if ($emulators.Count -eq 1) {
        $Device = $emulators | Select-Object -First 1
        Write-Host ">> Emulador detectado: $Device"
    }
    elseif ($emulators.Count -gt 1) {
        Write-Host "Hay varios emuladores conectados:"
        $emulators | ForEach-Object {
            Write-Host "  - $_"
        }

        throw "Indique cuál usar: .\bin\run_emulator.ps1 -Device emulator-5554"
    }
    else {
        $Device = "emulator-5554"
        Write-Host ">> Usando dispositivo por defecto: $Device"
    }
}

$localDb = Join-Path $root "data\following_practices.db"

if (-not (Test-Path $localDb)) {
    Write-Host "Creando BD local..."
    dart run bin/migrate.dart
}

Write-Host ">> Enviando BD al emulador ($Device)..."

& (Join-Path $PSScriptRoot "sync_db_emulator.ps1") `
    push `
    -Device $Device

Write-Host ">> Iniciando app en $Device (Ctrl+C para salir y sincronizar)..."

try {
    flutter run -d $Device
}
finally {
    Write-Host ""
    Write-Host ">> Esperando emulador antes de guardar BD..."

    Start-Sleep -Seconds 3

    Write-Host ">> Guardando BD en el PC..."

    $pullOk = $false

    try {
        & (Join-Path $PSScriptRoot "sync_db_emulator.ps1") `
            pull `
            -Device $Device

        if ($LASTEXITCODE -eq 0) {
            $pullOk = $true
        }
    }
    catch {
        # pull puede fallar si el emulador se desconectó;
        # ver mensaje manual abajo
    }

    if ($pullOk) {
        Write-Host "Listo: data/following_practices.db actualizado."
    }
    else {
        Write-Warning "Pull automático falló. Con el emulador encendido ejecute:"
        Write-Warning "  .\bin\sync_db_emulator.ps1 pull -Device $Device"
    }
}