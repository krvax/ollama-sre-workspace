# ============================================================
# analizar_disco.ps1
# Analiza archivos en discos locales y los ordena por tamanio
# ============================================================

param(
    [string]$Disco = "C:\",
    [int]$Top = 50,
    [switch]$TodosLosDiscos,
    [switch]$ExportarCSV,
    [string[]]$Excluir = @(),
    [switch]$PassThru
)

# Inicializar patrones de exclusión en ámbito de script
$script:ExcluirPatrones = $Excluir

function Test-Excluido {
    param(
        [string]$RutaCompleta,
        [bool]$EsCarpeta = $false
    )
    if (-not $script:ExcluirPatrones) { return $false }
    
    foreach ($patron in $script:ExcluirPatrones) {
        if ([string]::IsNullOrWhiteSpace($patron)) { continue }
        
        $patronNormal = $patron.Replace("/", "\")
        $rutaNormal = $RutaCompleta.Replace("/", "\")
        
        # Coincidencia directa o por comodín del nombre base
        if ($rutaNormal -like $patronNormal -or (Split-Path $rutaNormal -Leaf) -like $patronNormal) {
            return $true
        }
        # Si es una carpeta, verificar si coincide con un patrón tipo "C:\Windows\*"
        if ($EsCarpeta -and ($rutaNormal + "\*") -like $patronNormal) {
            return $true
        }
        # Si el patrón representa una carpeta absoluta (ej: "C:\Windows"), verificar si la ruta empieza por ella
        if ($patronNormal -match "^[A-Za-z]:\\" -and $rutaNormal.StartsWith($patronNormal.TrimEnd('\'), [System.StringComparison]::OrdinalIgnoreCase)) {
            return $true
        }
    }
    return $false
}

function Write-Progreso {
    param([string]$Mensaje, [string]$Color = "Cyan")
    $hora = Get-Date -Format "HH:mm:ss"
    Write-Host "[$hora] $Mensaje" -ForegroundColor $Color
}

function Get-ArchivosOrdenados {
    param([string]$Ruta, [int]$Cantidad)

    $inicio = Get-Date
    Write-Progreso "Iniciando escaneo en: $Ruta" "Yellow"
    Write-Progreso "Recopilando lista de carpetas..." "Cyan"

    $carpetas = @(Get-ChildItem -Path $Ruta -Directory -ErrorAction SilentlyContinue)
    $totalCarpetas = $carpetas.Count
    Write-Progreso "Carpetas raiz encontradas: $totalCarpetas" "Cyan"

    $archivos     = [System.Collections.Generic.List[object]]::new()
    $contArchivos = 0
    $contCarpetas = 0
    $ultimoReport = Get-Date

    # Archivos en la raiz
    Get-ChildItem -Path $Ruta -File -ErrorAction SilentlyContinue | ForEach-Object {
        if (-not (Test-Excluido -RutaCompleta $_.FullName -EsCarpeta $false)) {
            $archivos.Add($_)
            $contArchivos++
        }
    }

    # Subcarpetas con progreso
    foreach ($carpeta in $carpetas) {
        $contCarpetas++

        # Saltar carpetas excluidas de inmediato para ahorrar tiempo de escaneo
        if (Test-Excluido -RutaCompleta $carpeta.FullName -EsCarpeta $true) {
            continue
        }

        Get-ChildItem -Path $carpeta.FullName -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object {
            if (-not (Test-Excluido -RutaCompleta $_.FullName -EsCarpeta $false)) {
                $archivos.Add($_)
                $contArchivos++
            }
        }

        $ahora = Get-Date
        if (($ahora - $ultimoReport).TotalSeconds -ge 3) {
            $transcurrido = ($ahora - $inicio).TotalSeconds
            $pct          = [math]::Round(($contCarpetas / [math]::Max($totalCarpetas, 1)) * 100, 1)
            $vel          = [math]::Round($contArchivos / [math]::Max($transcurrido, 1), 0)

            if ($pct -gt 0) {
                $totalEst = $transcurrido * 100 / $pct
                $rest     = [math]::Round($totalEst - $transcurrido, 0)
                $eta      = if ($rest -gt 60) { "$([math]::Round($rest/60,1)) min" } else { "$rest seg" }
            } else {
                $eta = "calculando..."
            }

            $nArchivos = $contArchivos.ToString('N0')
            Write-Progreso "Progreso $pct pct - carpeta $contCarpetas de $totalCarpetas - archivos $nArchivos - vel $vel por seg - ETA $eta" "Cyan"
            $ultimoReport = $ahora
        }
    }

    $duracion  = [math]::Round(((Get-Date) - $inicio).TotalSeconds, 1)
    $nFinal    = $contArchivos.ToString('N0')
    Write-Progreso "Escaneo completo en $duracion seg - $nFinal archivos encontrados" "Green"
    Write-Progreso "Ordenando por tamanio..." "Cyan"

    $resultado = $archivos |
        Sort-Object Length -Descending |
        Select-Object -First $Cantidad `
            FullName,
            @{Name="SizeMB"; Expression={[math]::Round($_.Length / 1MB, 2)}},
            @{Name="SizeGB"; Expression={[math]::Round($_.Length / 1GB, 4)}},
            LastWriteTime

    Write-Progreso "Listo." "Green"
    return $resultado
}

# ── Seleccion de discos ──────────────────────────────────────
if ($TodosLosDiscos) {
    $discos = Get-PSDrive -PSProvider FileSystem |
              Where-Object { $_.Root -match "^[A-Z]:\\" } |
              Select-Object -ExpandProperty Root
} else {
    $discos = @($Disco)
}

$tiempoTotal = Get-Date
$todos = @()

foreach ($d in $discos) {
    $todos += Get-ArchivosOrdenados -Ruta $d -Cantidad $Top
}

$todos = $todos | Sort-Object SizeMB -Descending | Select-Object -First $Top

$duracionTotal = [math]::Round(((Get-Date) - $tiempoTotal).TotalSeconds, 1)

if ($PassThru) {
    return $todos
} else {
    Write-Host ""
    Write-Host "===== TOP $Top ARCHIVOS MAS PESADOS (tiempo total: $duracionTotal seg) =====" -ForegroundColor Yellow
    $todos | Format-Table -AutoSize -Wrap SizeMB, SizeGB, LastWriteTime, FullName
}

# ── Exportar CSV ─────────────────────────────────────────────
if ($ExportarCSV) {
    # Buscar escritorio real (funciona con y sin OneDrive)
    $escritorio = [Environment]::GetFolderPath("Desktop")
    if (-not $escritorio -or -not (Test-Path $escritorio)) {
        $escritorio = "$env:USERPROFILE\Desktop"
    }
    $salida = "$escritorio\archivos_pesados_$(Get-Date -Format 'yyyyMMdd_HHmm').csv"
    $todos | Export-Csv -Path $salida -NoTypeInformation -Encoding UTF8
    Write-Progreso "CSV exportado en: $salida" "Green"
}
