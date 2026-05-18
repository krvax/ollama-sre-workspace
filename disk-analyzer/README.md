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

### Cambiar disco y cantidad
```powershell
.\analizar_disco.ps1 -Disco "D:\" -Top 20
```

### Analizar TODOS los discos locales
```powershell
.\analizar_disco.ps1 -TodosLosDiscos -Top 100
```

### Exportar a CSV en el Escritorio
```powershell
.\analizar_disco.ps1 -ExportarCSV
```

### Todo junto
```powershell
.\analizar_disco.ps1 -TodosLosDiscos -Top 100 -ExportarCSV
```

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
