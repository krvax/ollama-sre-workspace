# Ejercicio 02: Generadores (yield) para SRE
# Tema: yield, generadores, filtrar datos sin cargar todo en memoria
#
# Contexto SRE: Tienes una flota de servidores. Quieres un "health checker"
# que vaya reportando uno por uno los servidores con problemas,
# sin cargar toda la lista en memoria (imagina 10,000 servidores).

# --- Datos de ejemplo (simula una flota) ---
flota = [
    {"nombre": "web-01", "ip": "10.0.1.5", "estado": "running", "cpu": 23},
    {"nombre": "web-02", "ip": "10.0.1.6", "estado": "running", "cpu": 87},
    {"nombre": "db-01", "ip": "10.0.0.5", "estado": "down", "cpu": 0},
    {"nombre": "app-01", "ip": "10.0.2.5", "estado": "running", "cpu": 95},
    {"nombre": "cache-01", "ip": "10.0.3.5", "estado": "running", "cpu": 12},
    {"nombre": "db-02", "ip": "10.0.0.6", "estado": "down", "cpu": 0},
    {"nombre": "app-02", "ip": "10.0.2.6", "estado": "running", "cpu": 72},
    {"nombre": "proxy-01", "ip": "10.0.4.5", "estado": "maintenance", "cpu": 0},
]

# --- Tu código aquí ---

# 1. Crea una función generadora llamada "alertas" que reciba la lista de servidores
#    y haga yield de cada servidor que esté "down" o tenga cpu > 90
#
#    def alertas(servidores):
#        for servidor in servidores:
#            if <condición>:
#                yield servidor


# 2. Usa el generador con un for loop para imprimir las alertas:
#    for alerta in alertas(flota):
#        print(f"🚨 ALERTA: {alerta['nombre']} - estado: {alerta['estado']}, cpu: {alerta['cpu']}%")


# 3. BONUS: Crea otro generador "alto_cpu" que solo haga yield de servidores
#    con cpu > 80 (sin importar estado). Imprime con:
#    for srv in alto_cpu(flota):
#        print(f"⚠️  CPU ALTA: {srv['nombre']} al {srv['cpu']}%")


# --- ¿Por qué yield y no una lista normal? ---
# Con return: cargas TODOS los resultados en memoria de golpe
# Con yield: procesas UNO a la vez (lazy evaluation)
#
# En SRE real con 10,000 servidores o millones de líneas de log,
# yield te salva de quedarte sin RAM.
#
# Analogía: yield es como un stream de Netflix (un frame a la vez)
#           return es como descargar toda la película antes de verla.
