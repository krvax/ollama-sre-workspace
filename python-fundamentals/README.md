# Python Fundamentals — Interview Prep

Ejercicios progresivos de Python orientados a SRE. Cada archivo es un ejercicio independiente.

---

## Ejercicios

| # | Archivo | Tema | Conceptos |
|---|---|---|---|
| 01 | `01_diccionarios.py` | Diccionarios + listas | Crear, acceder, modificar, iterar, `.get()`, `[]` |
| 02 | `02_generadores_sre.py` | Generadores (yield) | `yield`, lazy evaluation, filtrar flotas |

---

## Conceptos Clave

### Diccionarios
- Colección de pares `clave: valor`
- Acceso: `d["clave"]` (crashea si no existe) vs `d.get("clave")` (retorna `None`)
- Modificar: `d["clave"] = nuevo_valor`
- Iterar: `for k, v in d.items()`

### Generadores (`yield`)

```python
# Con return (carga todo en memoria):
def get_alertas(servidores):
    resultado = []
    for s in servidores:
        if s["estado"] == "down":
            resultado.append(s)
    return resultado  # toda la lista de golpe

# Con yield (uno a la vez, lazy):
def get_alertas(servidores):
    for s in servidores:
        if s["estado"] == "down":
            yield s  # entrega uno, se pausa, continúa cuando le pides el siguiente
```

**¿Por qué yield?**
- `return` = descargar toda la película antes de verla
- `yield` = stream de Netflix (un frame a la vez)

**En SRE real:** Cuando procesas 10,000 servidores o millones de líneas de log, `yield` te salva de quedarte sin RAM. Procesas uno, actúas, y sigues al siguiente.

**Cuándo usar cada uno:**
| Situación | Usa |
|---|---|
| Lista pequeña y la necesitas completa | `return` |
| Datos grandes o infinitos (logs, streams) | `yield` |
| Solo necesitas filtrar/procesar uno a la vez | `yield` |
| Necesitas `len()`, indexar, o reusar la lista | `return` |

---

## Progresión planeada

1. ~~Listas + diccionarios~~ ✅
2. ~~Generadores (yield)~~ ← actual
3. Funciones + error handling (try/except)
4. Archivos (leer/escribir logs)
5. Módulos estándar (os, sys, json, subprocess)
6. Boto3 básico (AWS SDK)
7. Ejercicios tipo entrevista SRE
