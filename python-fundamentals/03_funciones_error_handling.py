# Ejercicio 03: Funciones + Error Handling para SRE
# Tema: def, parámetros, return, try/except/finally
#
# Contexto SRE: Tienes un health checker que verifica servicios.
# Algunos servicios pueden estar caídos, tener timeouts, o responder con errores.
# Tu código debe manejar esos fallos sin crashear.

# --- Datos de ejemplo (simula respuestas de servicios) ---
servicios = [
    {"nombre": "api-gateway", "url": "https://api.internal/health", "status": 200},
    {"nombre": "auth-service", "url": "https://auth.internal/health", "status": 500},
    {"nombre": "db-primary", "url": None, "status": None},  # URL no configurada
    {"nombre": "cache-redis", "url": "https://cache.internal/health", "status": 200},
    {"nombre": "payment-svc", "url": "https://pay.internal/health", "status": 503},
]

# --- Tu código aquí ---

# 1. Crea una función llamada "verificar_servicio" que reciba un diccionario de servicio.
#    - Si el servicio no tiene URL (es None), debe lanzar un ValueError con un mensaje descriptivo
#    - Si el status es 200, retorna un string: "✅ {nombre} — OK"
#    - Si el status es 500 o 503, retorna: "🚨 {nombre} — ERROR {status}"
#    - Si el status es cualquier otra cosa, retorna: "⚠️ {nombre} — UNKNOWN {status}"
def verificar_servicio(servicio):
    if servicio['url'] is None:
        raise ValueError("No hay URL configurada")
    if servicio['status'] == 200:
        return f"{servicio['nombre']} - OK"
    elif servicio['status'] in [500,503]:
        return f"{servicio['nombre']} - ERROR - {servicio['status']}"
    else:
        return f"Nombre: {servicio['nombre']} - UNKNOWN - {servicio['status']}"
          
# 2. Crea una función llamada "health_check" que reciba la lista de servicios.
#    - Itera sobre cada servicio
#    - Llama a "verificar_servicio" dentro de un try/except
#    - Si atrapa un ValueError, imprime: "❌ {nombre} — NO CONFIGURADO: {mensaje del error}"
#    - Si atrapa cualquier otra excepción, imprime: "💀 {nombre} — ERROR INESPERADO: {error}"
#    - En el bloque finally, imprime: "   → Verificación de {nombre} completada"
#    - Si no hubo error, imprime el resultado de verificar_servicio
def health_check(servicios, verbose):
    for servicio in servicios:
        try:
            resultado = verificar_servicio(servicio)
            print(resultado)
        except ValueError as e:
            print(f"{servicio['nombre']}: NO CONFIGURADO: {e}")
        except Exception as e:
            print(f"{servicio['nombre']}: ERROR INESPERADO: {e}")
        finally:
            if verbose:
                print(f"Verificación de {servicio['nombre']} completada")

# 3. Llama a health_check(servicios) y observa la salida.
#    Deberías ver algo como:
#    ✅ api-gateway — OK
#       → Verificación de api-gateway completada
#    🚨 auth-service — ERROR 500
#       → Verificación de auth-service completada
#    ❌ db-primary — NO CONFIGURADO: ...
#       → Verificación de db-primary completada
#    ...
input("Verificar servicios, presiona enter...")
health_check(servicios,True)

# 4. BONUS: Agrega un parámetro opcional "verbose" a health_check (default False).
#    Si verbose=True, imprime los mensajes de "finally".
#    Si verbose=False, solo imprime los resultados y errores.


# --- ¿Por qué esto importa en SRE? ---
# En producción, tu health checker NO puede crashear porque un servicio está mal configurado.
# try/except te permite:
# - Detectar el problema
# - Loggearlo
# - Continuar verificando los demás servicios
# - Reportar un resumen al final
#
# En Bridgewater podrían pedirte: "Escribe un script que verifique N servicios
# y reporte cuáles están healthy y cuáles no, sin detenerse si uno falla."
