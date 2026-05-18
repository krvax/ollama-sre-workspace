# ============================================================
# mover_archivos.ps1
# Mueve archivos pesados a otro disco con verificación y exclusión interactiva
# ============================================================

param(
    [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [object]$ArchivosInput,

    [string]$Disco = 'C:\',
    [int]$Top = 15,
    [string]$Destino = 'E:\Movidos',
    
    [string[]]$Excluir = @(),
    [switch]$Force,
    [switch]$Simular
)

begin {
    $horaInicio = Get-Date -Format 'HH:mm:ss'
    
    function Write-Log {
        param([string]$Msg, [string]$Color = 'Cyan')
        $hora = Get-Date -Format 'HH:mm:ss'
        Write-Host ("[{0}] {1}" -f $hora, $Msg) -ForegroundColor $Color
    }

    function Get-EspacioLibreGB {
        param([string]$Letra)
        $vol = Get-Volume -DriveLetter $Letra -ErrorAction SilentlyContinue
        if ($vol) { return [math]::Round($vol.SizeRemaining / 1GB, 2) }
        return 0
    }

    # Normalizador de objetos de archivo recibidos por el pipeline
    function Get-NormalizedFileObject {
        param([object]$InputObj)
        if ($null -eq $InputObj) { return $null }
        
        $path = ''
        $sizeBytes = [long]0
        $mtime = Get-Date

        if ($InputObj -is [string]) {
            $path = $InputObj
            if (Test-Path $path) {
                $item = Get-Item $path
                $sizeBytes = $item.Length
                $mtime = $item.LastWriteTime
            }
        } elseif ($InputObj -is [System.IO.FileInfo]) {
            $path = $InputObj.FullName
            $sizeBytes = $InputObj.Length
            $mtime = $InputObj.LastWriteTime
        } elseif ($InputObj.FullName) {
            $path = $InputObj.FullName
            if ($InputObj.Length) {
                $sizeBytes = $InputObj.Length
            } elseif ($InputObj.SizeMB) {
                # Convertir de MB a bytes si viene de analizar_disco.ps1
                $sizeBytes = [long]($InputObj.SizeMB * 1MB)
            }
            if ($InputObj.LastWriteTime) {
                $mtime = $InputObj.LastWriteTime
            }
        }
        
        if (-not [string]::IsNullOrEmpty($path)) {
            return [PSCustomObject]@{
                FullName      = $path
                SizeMB        = [math]::Round($sizeBytes / 1MB, 2)
                SizeGB        = [math]::Round($sizeBytes / 1GB, 4)
                LastWriteTime = $mtime
            }
        }
        return $null
    }

    # Exclusiones del sistema automáticas (seguridad del SO y estabilidad)
    $script:ExclusionesSistema = @(
        '*.sys',               # pagefile.sys, hiberfil.sys, etc.
        '*.dll',               # DLLs del sistema
        'C:\Windows\*',        # Directorio operativo principal
        '*AppData*',           # Datos de aplicaciones locales y temporales
        'C:\Program Files\*',  # Programas instalados
        'C:\Program Files (x86)\*'
    )

    # Unificación de exclusiones del sistema y del usuario
    $script:ExcluirPatrones = $script:ExclusionesSistema + $Excluir

    function Test-Excluido {
        param([string]$RutaCompleta)
        foreach ($patron in $script:ExcluirPatrones) {
            if ([string]::IsNullOrWhiteSpace($patron)) { continue }
            
            $patronNormal = $patron.Replace('/', '\')
            $rutaNormal = $RutaCompleta.Replace('/', '\')
            
            # Coincidencia por comodín o exacta del nombre de archivo/ruta
            if ($rutaNormal -like $patronNormal -or (Split-Path $rutaNormal -Leaf) -like $patronNormal) {
                return $true
            }
            # Coincidencia si el patrón es un directorio absoluto raíz
            if ($patronNormal -match '^[A-Za-z]:\\' -and $rutaNormal.StartsWith($patronNormal.TrimEnd('\'), [System.StringComparison]::OrdinalIgnoreCase)) {
                return $true
            }
        }
        return $false
    }

    $script:ArchivosRecibidos = [System.Collections.Generic.List[object]]::new()
    Write-Log 'Inicializando script de mudanza...' 'Yellow'
}

process {
    # Acumular archivos recibidos del pipeline o por argumento
    if ($ArchivosInput) {
        foreach ($item in $ArchivosInput) {
            $norm = Get-NormalizedFileObject -InputObj $item
            if ($norm) {
                $script:ArchivosRecibidos.Add($norm)
            }
        }
    }
}

end {
    $existentes = [System.Collections.Generic.List[object]]::new()

    # 1. Si no hay archivos por pipeline, realizar escaneo automático
    if ($script:ArchivosRecibidos.Count -eq 0) {
        Write-Log ("No se recibieron archivos por pipeline. Iniciando escaneo dinámico en: {0}..." -f $Disco) 'Yellow'
        
        $scriptAnalisis = Join-Path $PSScriptRoot 'analizar_disco.ps1'
        if (Test-Path $scriptAnalisis) {
            Write-Log ("Invocando analizar_disco.ps1 -Disco ''{0}'' -Top {1} -PassThru..." -f $Disco, $Top) 'Cyan'
            $resultados = & $scriptAnalisis -Disco $Disco -Top $Top -PassThru -Excluir $Excluir
            foreach ($res in $resultados) {
                $norm = Get-NormalizedFileObject -InputObj $res
                if ($norm) {
                    $script:ArchivosRecibidos.Add($norm)
                }
            }
        } else {
            Write-Log 'No se encontró el script de análisis en la misma carpeta.' 'Red'
        }

        # ── COMPATIBILIDAD RETROACTIVA: Búsqueda heredada de Google Takeouts e iCloud en C:\ ──
        if ($Disco -eq 'C:\' -or $Disco.StartsWith('C:')) {
            Write-Log 'Buscando candidatos heredados de Google Takeout e iCloud...' 'Gray'
            $archivosManuales = @(
                'C:\Users\just_\iCloudDrive\Downloads\Samsung\SM-T380_1_20210624023610_os95wna9nf_fac_T380DXS4CUF1_T380UVS4CUF1_T380DXS4CUF1_T380DXS4CUF1_MXO.zip.enc4',
                'C:\Users\just_\iCloudDrive\Downloads\Samsung\SM-T380_1_20210624023610_os95wna9nf_fac_T380DXS4CUF1_T380UVS4CUF1_T380DXS4CUF1_T380DXS4CUF1_MXO.zip',
                'C:\Users\just_\Music\Filemail.com - MGPCK_KIKE.zip',
                'C:\Users\just_\Dropbox\MiNenaConNalita.mov'
            )
            
            # Buscar carpeta Google en OneDrive
            $carpetaGoogle = Get-ChildItem 'C:\Users\just_\OneDrive\Aplicaciones\' -ErrorAction SilentlyContinue |
                Where-Object { $_.Name -like '*Google*' } |
                Select-Object -First 1 -ExpandProperty FullName
            
            if ($carpetaGoogle) {
                $takeouts = Get-ChildItem -Path $carpetaGoogle -Filter 'takeout-*.zip' -ErrorAction SilentlyContinue
                foreach ($t in $takeouts) {
                    $archivosManuales += $t.FullName
                }
            }

            foreach ($m in $archivosManuales) {
                if (Test-Path $m) {
                    # Si no está ya listado, agregarlo
                    if (-not ($script:ArchivosRecibidos | Where-Object { $_.FullName -eq $m })) {
                        $norm = Get-NormalizedFileObject -InputObj $m
                        if ($norm) {
                            $script:ArchivosRecibidos.Add($norm)
                        }
                    }
                }
            }
        }
    }

    # 2. Filtrar exclusiones críticas (Sistema + Usuario)
    foreach ($fileObj in $script:ArchivosRecibidos) {
        $ruta = $fileObj.FullName
        if (Test-Path $ruta) {
            if (Test-Excluido -RutaCompleta $ruta) {
                Write-Log ("  EXCLUIDO AUTOMÁTICAMENTE: {0}" -f $ruta) 'Magenta'
            } else {
                $existentes.Add($fileObj)
            }
        } else {
            Write-Log ("  NO EXISTE (ignorado): {0}" -f $ruta) 'Red'
        }
    }

    # Re-ordenar candidatos finales por tamaño descendente
    $existentes = $existentes | Sort-Object SizeMB -Descending

    if ($existentes.Count -eq 0) {
        Write-Log 'No quedan archivos candidatos para mover. Saliendo de forma segura.' 'Yellow'
        exit 0
    }

    # 3. Menú Interactivo ("excepto los que yo diga")
    $archivosParaProcesar = @()
    if ($existentes.Count -gt 0 -and -not $Force) {
        Write-Host ''
        Write-Log '===== SELECCIÓN INTERACTIVA DE MUDANZA =====' 'Yellow'
        Write-Log 'Elige qué archivos deseas conservar y cuáles excluir para mudanza:' 'Cyan'
        Write-Host ''

        # Mostrar tabla numerada
        for ($idx = 0; $idx -lt $existentes.Count; $idx++) {
            $fileObj = $existentes[$idx]
            $num = $idx + 1
            $numPad = $num.ToString().PadRight(3)
            $sizeStr = ("{0:N2} MB" -f $fileObj.SizeMB).PadLeft(12)
            $shortPath = $fileObj.FullName
            
            Write-Host ("  [{0}] {1}  -  {2}" -f $numPad, $sizeStr, $shortPath) -ForegroundColor Gray
        }

        Write-Host ''
        Write-Host '-> Escribe los números de los archivos que deseas EXCLUIR (separados por coma, ej: 1, 3).' -ForegroundColor Cyan
        Write-Host '-> Escribe ''todas'' para CANCELAR la mudanza por completo.' -ForegroundColor Red
        Write-Host '-> Simplemente presiona ENTER para continuar y mover TODOS los archivos listados.' -ForegroundColor Green
        Write-Host ''
        
        $userInput = Read-Host '>>> Tu Selección'
        $userInput = $userInput.Trim()

        if ($userInput -eq 'todas' -or $userInput -eq 'todo' -or $userInput -eq 'cancel' -or $userInput -eq 'cancelar') {
            Write-Log 'Operación cancelada por el usuario. No se movió nada.' 'Red'
            exit 0
        }

        $excluidosIndices = @()
        if (-not [string]::IsNullOrEmpty($userInput)) {
            $partes = $userInput -split ','
            foreach ($p in $partes) {
                if ([int]::TryParse($p.Trim(), [ref]$val)) {
                    if ($val -ge 1 -and $val -le $existentes.Count) {
                        $excluidosIndices += ($val - 1)
                    }
                }
            }
        }

        # Construir lista filtrada final tras selección interactiva
        for ($idx = 0; $idx -lt $existentes.Count; $idx++) {
            if ($excluidosIndices -contains $idx) {
                $leaf = Split-Path $existentes[$idx].FullName -Leaf
                Write-Log ("  EXCLUIDO POR USUARIO: {0}" -f $leaf) 'Magenta'
            } else {
                $archivosParaProcesar += $existentes[$idx]
            }
        }
    } else {
        $archivosParaProcesar = $existentes
    }

    if ($archivosParaProcesar.Count -eq 0) {
        Write-Log 'Todos los archivos candidatos fueron excluidos. Saliendo de forma segura.' 'Yellow'
        exit 0
    }

    # 4. Calcular peso total
    $pesoTotalBytes = [long]0
    foreach ($f in $archivosParaProcesar) {
        $pesoTotalBytes += [long]($f.SizeMB * 1MB)
    }
    $pesoGB = [math]::Round($pesoTotalBytes / 1GB, 2)
    Write-Log ("Total a mover: {0} GB en {1} archivos" -f $pesoGB, $archivosParaProcesar.Count) 'Yellow'

    # 5. Verificar espacio libre en el disco destino
    $letraDestino = (Split-Path -Qualifier $Destino).Replace(':\','')
    $libreGB      = Get-EspacioLibreGB -Letra $letraDestino
    Write-Log ("Espacio libre en {0}: {1} GB" -f $letraDestino, $libreGB) 'Cyan'

    if ($libreGB -lt ($pesoGB + 1)) {
        Write-Log ("ESPACIO INSUFICIENTE en destino. Necesitas {0} GB, hay {1} GB libres." -f $pesoGB, $libreGB) 'Red'
        exit 1
    }

    if ($Simular) {
        Write-Log 'MODO SIMULACIÓN - Análisis completado con éxito. Ejecuta sin -Simular para mover de verdad.' 'Magenta'
        exit 0
    }

    # 6. Mover archivos con validación e integridad
    Write-Log ("Iniciando mudanza de archivos a: {0}" -f $Destino) 'Yellow'
    $ok          = 0
    $errorCount  = 0
    $i           = 0

    foreach ($fileObj in $archivosParaProcesar) {
        $i++
        $origen = $fileObj.FullName
        $nombre = Split-Path $origen -Leaf
        $sizeGB = $fileObj.SizeGB
        $pct    = [math]::Round($i / $archivosParaProcesar.Count * 100, 0)

        Write-Log ("[{0}/{1}] {2}% - {3} GB - {4}" -f $i, $archivosParaProcesar.Count, $pct, $sizeGB, $nombre) 'Cyan'

        if (-not (Test-Path $Destino)) {
            New-Item -ItemType Directory -Path $Destino -Force | Out-Null
        }

        $destFile = Join-Path $Destino $nombre

        try {
            Move-Item -Path $origen -Destination $destFile -Force
            if (Test-Path $destFile) {
                $sizeOk = (Get-Item $destFile).Length
                if ($sizeOk -gt 0) {
                    $sizeOkGB = [math]::Round($sizeOk/1GB, 2)
                    Write-Log ("  Verificado OK - {0} GB" -f $sizeOkGB) 'Green'
                    $ok++
                } else {
                    Write-Log '  ADVERTENCIA: archivo destino tiene 0 bytes' 'Red'
                    $errorCount++
                }
            } else {
                Write-Log '  ERROR: no se encontró en destino' 'Red'
                $errorCount++
            }
        } catch {
            Write-Log ("  ERROR: {0}" -f $_) 'Red'
            $errorCount++
        }
    }

    Write-Host ''
    Write-Log '===== RESUMEN DE OPERACIÓN SRE =====' 'Yellow'
    Write-Log ("Movidos correctamente: {0}" -f $ok) 'Green'
    if ($errorCount -gt 0) {
        Write-Log ("Con errores: {0}" -f $errorCount) 'Red'
    }
    Write-Log ("Destino: {0}" -f $Destino) 'Cyan'
}
