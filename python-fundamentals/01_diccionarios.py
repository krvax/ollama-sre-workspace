# Ejercicio 01: Diccionarios
# Tema: Crear, acceder, modificar, iterar diccionarios

# --- Tu código aquí ---

# 1. Crea 3 diccionarios, uno por servidor. Cada uno con: nombre, ip, estado
# Ejemplo:
# servidor1 = {"nombre": "web-01", "ip": "10.0.1.5", "estado": "running"}
servidor1 = {"nombre": "web-01", "ip": "10.0.1.5", "estado": "running"}
servidor2 = {"nombre": "db-01", "ip": "10.0.0.5", "estado": "running"}
servidor3 = {"nombre": "app-01", "ip": "10.0.2.5", "estado": "running"}


# 2. Ponlos en una lista llamada "servidores"
servidores = []
servidores.append(servidor1)
servidores.append(servidor2)
servidores.append(servidor3)


# 3. Imprime el nombre del segundo servidor
print(servidores[1].get("nombre"))

# 4. Cambia el estado del primero a "down"
servidores[0]["estado"] = "down"
# print(servidores[0])

# 5. Crea un cuarto servidor y agrégalo a la lista
servidor4 = {"nombre": "proxy-01", "ip": "10.0.3.5", "estado": "running"}
servidores.append(servidor4)

# 6. Imprime todos los servidores con un for loop
# Tip: for servidor in servidores:
#          print(servidor)
for servidor in servidores:
    print(servidor)
