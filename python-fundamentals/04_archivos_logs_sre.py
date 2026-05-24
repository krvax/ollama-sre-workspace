# Ejercicio 04: Archivos + Logs para SRE
# Tema: open(), read, write, with, try/except, listas, diccionarios
#
# Contexto SRE: Tienes un archivo de log de un servicio. Necesitas:
# - Leerlo
# - Parsear cada línea
# - Clasificar por severidad (ERROR, WARN, INFO)
# - Generar un reporte resumen
# - Manejar el caso de que el archivo no exista

# --- Paso 0: Crear el archivo de log de ejemplo ---
# Ejecuta esta sección una vez para generar el archivo de prueba.
# Después comenta estas líneas y trabaja solo con la lectura.

log_lines = [
    "2026-05-23 08:01:12 INFO api-gateway: Request received /health",
    "2026-05-23 08:01:13 INFO auth-service: Token validated",
    "2026-05-23 08:01:15 ERROR db-primary: Connection timeout after 30s",
    "2026-05-23 08:01:16 WARN cache-redis: Memory usage at 85%",
    "2026-05-23 08:01:18 ERROR payment-svc: Transaction failed - insufficient funds",
    "2026-05-23 08:01:20 INFO api-gateway: Request received /users",
    "2026-05-23 08:01:22 WARN db-primary: Slow query detected (2.3s)",
    "2026-05-23 08:01:25 ERROR auth-service: Invalid token - expired",
    "2026-05-23 08:01:27 INFO cache-redis: Cache hit ratio 94%",
    "2026-05-23 08:01:30 ERROR db-primary: Connection timeout after 30s",
    "2026-05-23 08:01:32 WARN payment-svc: Retry attempt 2/3",
    "2026-05-23 08:01:35 INFO api-gateway: Health check OK",
]

with open("service.log", "w") as f:
    for line in log_lines:
        f.write(line + "\n")

print("Archivo service.log creado.")


# --- Tu código aquí ---

# 1. Crea una función "leer_log" que reciba un nombre de archivo (string).
#    - Usa "with open(...) as f" para abrir el archivo
#    - Lee todas las líneas y retorna una lista de strings
#    - Si el archivo no existe, atrapa FileNotFoundError y retorna una lista vacía
#      (imprime un mensaje de error antes de retornar)
def leer_log(file_name):
    try:
        with open(file_name,"r") as f:
            return f.readlines()
    except FileNotFoundError:
        print(f"Error: El archivo {file_name} no existe.")
        return []
'''
lineas = leer_log("service.log")
print(len(lineas))  # debería dar 12

lineas2 = leer_log("no_existe.log")
print(len(lineas2))  # debería dar 0 + mensaje de error
'''

# 2. Crea una función "parsear_linea" que reciba una línea de log (string).
#    - Separa la línea en partes: fecha, hora, severidad, servicio, mensaje
#      (pista: .split() separa por espacios)
#    - Retorna un diccionario con las claves: "timestamp", "severity", "service", "message"
#    - Si la línea no tiene el formato esperado, lanza un ValueError
def parsear_lineas(log_string):
    log = log_string.split()


# 3. Crea una función "generar_reporte" que reciba la lista de líneas.
#    - Usa un diccionario para contar: {"ERROR": 0, "WARN": 0, "INFO": 0}
#    - Itera sobre cada línea, llama a "parsear_linea" dentro de un try/except
#    - Si parsear_linea falla, imprime el error y continúa con la siguiente línea
#    - Al final, imprime el reporte:
#      "=== REPORTE DE LOG ==="
#      "Total líneas: X"
#      "ERROR: X | WARN: X | INFO: X"
#    - BONUS: también imprime los servicios que tuvieron ERROR (sin repetir)


# 4. Llama a las funciones:
#    lineas = leer_log("service.log")
#    generar_reporte(lineas)


# 5. Prueba con un archivo que no existe:
#    lineas = leer_log("no_existe.log")
#    generar_reporte(lineas)


# --- ¿Por qué esto importa en SRE? ---
# En producción, parsear logs es el pan de cada día:
# - Identificar patrones de error
# - Contar frecuencia de problemas
# - Generar reportes para post-mortems
# - Automatizar alertas basadas en severidad
#
# Este ejercicio simula lo que harías con un script rápido cuando
# no tienes acceso a Splunk/Datadog y necesitas analizar un log manualmente.
