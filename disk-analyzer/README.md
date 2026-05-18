# 🗂️ Disk Analyzer

Herramientas para encontrar los archivos más pesados en tus discos locales.  
Disponible en **PowerShell** y **Python**, ambas con las mismas funciones.

---

## 📁 Archivos

| Archivo | Descripción |
|---|---|
| `analizar_disco.ps1` | Script PowerShell (sin dependencias) |
| `analizar_disco.py` | Script Python 3 (sin dependencias externas) |

---

## ⚡ PowerShell

### Uso básico — top 50 archivos en C:\
```powershell
.\analizar_disco.ps1
```

### Cambiar disco, cantidad y exclusiones rápidas
```powershell
# Encuentra el top 20, excluyendo archivos zip y vhdx
.\analizar_disco.ps1 -Disco "D:\" -Top 20 -Excluir "*.zip", "*.vhdx"
```

### Analizar TODOS los discos locales
```powershell
.\analizar_disco.ps1 -TodosLosDiscos -Top 100
```

### Exportar a CSV en el Escritorio
```powershell
.\analizar_disco.ps1 -ExportarCSV
```

---

## 🚚 Mudanza Segura de Archivos (`mover_archivos.ps1`)

El script de mudanza ahora soporta **pipelining interactivo** y posee **capas de seguridad inteligentes** para proteger la estabilidad de tu sistema operativo:

### 1. Escaneo y Mudanza Interactiva en un solo Paso
Busca los archivos más pesados en el disco especificado y activa el menú interactivo para excluir por número los archivos que decidas conservar:
```powershell
.\mover_archivos.ps1 -Disco "C:\" -Top 15 -Destino "E:\Movidos"
```

### 2. Pipeline Nativo (PowerShell Way)
Analiza y canaliza los objetos directamente al script de mudanza usando la bandera `-PassThru`:
```powershell
.\analizar_disco.ps1 -Disco "C:\" -Top 10 -PassThru | .\mover_archivos.ps1 -Destino "E:\Movidos"
```

### 3. Exclusiones Personalizadas y Simulación (Súper Seguro)
Simula el movimiento sin tocar ningún archivo real, aplicando exclusiones adicionales:
```powershell
.\mover_archivos.ps1 -Disco "C:\" -Top 10 -Destino "E:\Movidos" -Excluir "*.mp4", "*.iso" -Simular
```

### 🔒 Capas de Seguridad Incorporadas:
*   **Exclusión Automática de Sistema**: El script ignorará siempre de forma automática archivos críticos (`*.sys`, `*.dll`, carpetas de `Windows`, carpetas de `AppData` y carpetas de `Program Files`) para evitar cualquier tipo de corrupción o inestabilidad en el SO.
*   **Control de Espacio**: Verifica de forma previa si el disco destino tiene suficiente espacio libre (con un margen de seguridad) antes de iniciar la reubicación de cada bloque.
*   **Menú Interactivo**: Te permite ingresar de manera visual los números de los archivos a omitir (ej: `1, 3`), o abortar completamente escribiendo `todas`. Si deseas automatizar de forma desatendida en un script cron, añade la bandera `-Force` para omitir la confirmación manual.

---

> **Nota:** Si PowerShell bloquea la ejecución, corre esto primero una sola vez:
> ```powershell
> Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
> ```

---

## 🐍 Python

Requiere Python 3.9+. Sin librerías externas.

### Uso básico — top 50 archivos en C:\
```bash
python analizar_disco.py
```

### Cambiar disco y cantidad
```bash
python analizar_disco.py --disco "D:\" --top 20
```

### Analizar TODOS los discos locales
```bash
python analizar_disco.py --todos --top 100
```

### Exportar a CSV en el Escritorio
```bash
python analizar_disco.py --csv
```

### Todo junto
```bash
python analizar_disco.py --todos --top 100 --csv
```

---

## 📊 Ejemplo de salida

```
===== TOP 50 ARCHIVOS MÁS PESADOS =====

    SizeMB    SizeGB  Última modif.       Ruta
----------------------------------------------------------------------------------------------------
  45231.50   44.1714  2024-11-03 10:22  C:\Users\...\backup.vhdx
  12048.20   11.7658  2025-01-15 08:00  C:\Users\...\video_raw.mp4
   8192.00    8.0000  2024-09-20 14:30  C:\pagefile.sys
   ...
```

---

## 💡 Tips

- Ambos scripts **saltan automáticamente** archivos sin permiso (sistema, protegidos).
- El CSV se guarda en el **Escritorio** con fecha y hora en el nombre.
- Para analizar una carpeta específica en vez de un disco entero:
  ```powershell
  .\analizar_disco.ps1 -Disco "C:\Users\TuNombre\Downloads"
  ```
  ```bash
  python analizar_disco.py --disco "C:\Users\TuNombre\Downloads"
  ```
