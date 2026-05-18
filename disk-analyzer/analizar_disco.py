"""
analizar_disco.py
Analiza archivos en discos locales y los ordena por tamaño.

Uso:
    python analizar_disco.py
    python analizar_disco.py --disco D:\\ --top 30
    python analizar_disco.py --todos --top 100 --csv
"""

import os
import sys
import csv
import argparse
from datetime import datetime
from pathlib import Path


def obtener_discos_locales():
    """Detecta automáticamente los discos locales en Windows."""
    import string
    discos = []
    for letra in string.ascii_uppercase:
        disco = f"{letra}:\\"
        if os.path.exists(disco):
            discos.append(disco)
    return discos


def analizar(raiz: str, top: int = 50) -> list[dict]:
    """Recorre el disco y devuelve los archivos más pesados."""
    print(f"\nAnalizando: {raiz}  (puede tardar unos minutos...)")
    archivos = []

    for dirpath, _, filenames in os.walk(raiz):
        for nombre in filenames:
            ruta_completa = os.path.join(dirpath, nombre)
            try:
                size = os.path.getsize(ruta_completa)
                mtime = os.path.getmtime(ruta_completa)
                archivos.append({
                    "ruta":          ruta_completa,
                    "size_bytes":    size,
                    "size_mb":       round(size / 1_048_576, 2),
                    "size_gb":       round(size / 1_073_741_824, 4),
                    "ultima_modif":  datetime.fromtimestamp(mtime).strftime("%Y-%m-%d %H:%M"),
                })
            except (PermissionError, OSError):
                pass  # Saltar archivos sin permiso

    archivos.sort(key=lambda x: x["size_bytes"], reverse=True)
    return archivos[:top]


def mostrar_tabla(archivos: list[dict]):
    """Imprime los resultados en consola con formato de tabla."""
    print(f"\n{'SizeMB':>10}  {'SizeGB':>8}  {'Última modif.':<18}  Ruta")
    print("-" * 100)
    for a in archivos:
        print(f"{a['size_mb']:>10.2f}  {a['size_gb']:>8.4f}  {a['ultima_modif']:<18}  {a['ruta']}")


def exportar_csv(archivos: list[dict]):
    """Exporta los resultados a un CSV en el Escritorio."""
    escritorio = Path.home() / "Desktop"
    nombre = f"archivos_pesados_{datetime.now().strftime('%Y%m%d_%H%M')}.csv"
    salida = escritorio / nombre

    with open(salida, "w", newline="", encoding="utf-8") as f:
        campos = ["size_mb", "size_gb", "ultima_modif", "ruta"]
        writer = csv.DictWriter(f, fieldnames=campos, extrasaction="ignore")
        writer.writeheader()
        writer.writerows(archivos)

    print(f"\nCSV exportado en: {salida}")


def main():
    parser = argparse.ArgumentParser(description="Analiza archivos por tamaño en discos locales.")
    parser.add_argument("--disco",  default="C:\\",  help="Disco o carpeta a analizar (default: C:\\)")
    parser.add_argument("--top",    type=int, default=50, help="Cuántos archivos mostrar (default: 50)")
    parser.add_argument("--todos",  action="store_true",  help="Analizar todos los discos locales")
    parser.add_argument("--csv",    action="store_true",  help="Exportar resultados a CSV en el Escritorio")
    args = parser.parse_args()

    discos = obtener_discos_locales() if args.todos else [args.disco]

    todos = []
    for disco in discos:
        todos.extend(analizar(disco, top=args.top))

    # Reordenar y recortar si se combinaron varios discos
    todos.sort(key=lambda x: x["size_bytes"], reverse=True)
    todos = todos[:args.top]

    print(f"\n===== TOP {args.top} ARCHIVOS MÁS PESADOS =====")
    mostrar_tabla(todos)

    if args.csv:
        exportar_csv(todos)


if __name__ == "__main__":
    main()
