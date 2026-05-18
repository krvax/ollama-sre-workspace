# ============================================================
# mover_archivos.ps1
# Mueve archivos pesados a otro disco con verificacion
# ============================================================

param(
    [string]$Destino = "E:\Movidos",
    [switch]$Simular
)

function Write-Log {
    param([string]$Msg, [string]$Color = "Cyan")
    $hora = Get-Date -Format "HH:mm:ss"
    Write-Host "[$hora] $Msg" -ForegroundColor $Color
}

function Get-EspacioLibreGB {
    param([string]$Letra)
    $vol = Get-Volume -DriveLetter $Letra -ErrorAction SilentlyContinue
    if ($vol) { return [math]::Round($vol.SizeRemaining / 1GB, 2) }
    return 0
}

# ── Buscar ruta real de Google Takeout (tiene caracter invisible) ──
$carpetaGoogle = Get-ChildItem "C:\Users\just_\OneDrive\Aplicaciones\" |
    Where-Object { $_.Name -like "*Google*" } |
    Select-Object -First 1 -ExpandProperty FullName

if ($carpetaGoogle) {
    Write-Log "Carpeta Google encontrada: $carpetaGoogle" "Gray"
} else {
    Write-Log "No se encontro carpeta Google en OneDrive\Aplicaciones" "Red"
    $carpetaGoogle = ""
}

# ── Archivos fijos ───────────────────────────────────────────
$archivos = @(
    "C:\Users\just_\iCloudDrive\Downloads\Samsung\SM-T380_1_20210624023610_os95wna9nf_fac_T380DXS4CUF1_T380UVS4CUF1_T380DXS4CUF1_T380DXS4CUF1_MXO.zip.enc4",
    "C:\Users\just_\iCloudDrive\Downloads\Samsung\SM-T380_1_20210624023610_os95wna9nf_fac_T380DXS4CUF1_T380UVS4CUF1_T380DXS4CUF1_T380DXS4CUF1_MXO.zip",
    "C:\Users\just_\Music\Filemail.com - MGPCK_KIKE.zip",
    "C:\Users\just_\Dropbox\MiNenaConNalita.mov"
)

# ── Agregar takeouts de Google si se encontro la carpeta ─────
if ($carpetaGoogle) {
    $takeouts = Get-ChildItem -Path $carpetaGoogle -Filter "takeout-*.zip" -ErrorAction SilentlyContinue
    foreach ($t in $takeouts) {
        $archivos += $t.FullName
    }
    Write-Log "Takeouts encontrados: $($takeouts.Count)" "Gray"
}

# ── Calcular peso total ──────────────────────────────────────
Write-Log "Calculando peso total..." "Yellow"
$pesoTotal  = 0
$existentes = @()

foreach ($f in $archivos) {
    if (Test-Path $f) {
        $size = (Get-Item $f).Length
        $pesoTotal += $size
        $existentes += $f
        Write-Log "  OK  $([math]::Round($size/1GB,2)) GB  $(Split-Path $f -Leaf)" "Gray"
    } else {
        Write-Log "  NO ENCONTRADO: $f" "Red"
    }
}

$pesoGB = [math]::Round($pesoTotal / 1GB, 2)
Write-Log "Total a mover: $pesoGB GB en $($existentes.Count) archivos" "Yellow"

# ── Verificar espacio en destino ─────────────────────────────
$letraDestino = (Split-Path -Qualifier $Destino).Replace(":\","")
$libreGB      = Get-EspacioLibreGB -Letra $letraDestino
Write-Log "Espacio libre en $letraDestino`: $libreGB GB" "Cyan"

if ($libreGB -lt ($pesoGB + 1)) {
    Write-Log "ESPACIO INSUFICIENTE. Necesitas $pesoGB GB, hay $libreGB GB libres." "Red"
    exit 1
}

if ($Simular) {
    Write-Log "MODO SIMULACION - todo OK, quita -Simular para mover de verdad." "Magenta"
    exit 0
}

# ── Mover archivos ───────────────────────────────────────────
Write-Log "Iniciando movimiento a: $Destino" "Yellow"
$ok          = 0
$errorCount  = 0
$i           = 0

foreach ($origen in $existentes) {
    $i++
    $nombre = Split-Path $origen -Leaf
    $sizeGB = [math]::Round((Get-Item $origen).Length / 1GB, 2)
    $pct    = [math]::Round($i / $existentes.Count * 100, 0)

    Write-Log "[$i/$($existentes.Count)] $pct pct - $sizeGB GB - $nombre" "Cyan"

    if (-not (Test-Path $Destino)) {
        New-Item -ItemType Directory -Path $Destino -Force | Out-Null
    }

    $destFile = Join-Path $Destino $nombre

    try {
        Move-Item -Path $origen -Destination $destFile -Force
        if (Test-Path $destFile) {
            $sizeOk = (Get-Item $destFile).Length
            if ($sizeOk -gt 0) {
                Write-Log "  Verificado OK - $([math]::Round($sizeOk/1GB,2)) GB" "Green"
                $ok++
            } else {
                Write-Log "  ADVERTENCIA: archivo destino tiene 0 bytes" "Red"
                $errorCount++
            }
        } else {
            Write-Log "  ERROR: no se encontro en destino" "Red"
            $errorCount++
        }
    } catch {
        Write-Log "  ERROR: $_" "Red"
        $errorCount++
    }
}

Write-Host ""
Write-Log "===== RESUMEN =====" "Yellow"
Write-Log "Movidos correctamente: $ok" "Green"
if ($errorCount -gt 0) {
    Write-Log "Con errores: $errorCount" "Red"
}
Write-Log "Destino: $Destino" "Cyan"
