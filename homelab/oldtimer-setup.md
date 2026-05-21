# 🖥️ Oldtimer (Acer) — Homelab Setup

> **Host:** `oldtimer` | **IP:** 192.168.0.104 (WiFi, DHCP)  
> **OS:** Linux Mint (Ubuntu 24.04 base) | **Kernel:** 6.8.0-111-generic  
> **RAM:** 4 GB | **Conectividad:** WiFi (wlp7s0) + Ethernet (enp9s0, no conectado)  
> **Acceso:** `ssh admin@192.168.0.104` (llave pública configurada, sin password)  
> **Fecha de setup:** Miércoles 20 de Mayo, 2026

---

## ✅ Configuración completada

### 1. Desktop Environment — XFCE (ligero)
- **Display Manager:** LightDM (`/usr/sbin/lightdm`)
- **Sesión:** XFCE (`~/.dmrc` → `Session=xfce`)
- **Cinnamon:** Purgado completamente (`apt purge cinnamon* nemo*`)
- **Compositor:** Desactivado (`use_compositing = false`) para mejor rendimiento

### 2. SSH — Acceso remoto sin password
- `ssh.service` → **enabled** (arranca con el sistema)
- Llave pública de WSL copiada:
  ```bash
  # Desde WSL (una sola vez, ya hecho)
  ssh-copy-id admin@192.168.0.104
  ```
- Llave usada: `~/.ssh/id_rsa.pub` (RSA)
- Acceso: `ssh admin@192.168.0.104` (directo, sin password)

### 3. GRUB — Boot automático
- `GRUB_TIMEOUT=3` (arranca Linux solo en 3 seg)
- `GRUB_TIMEOUT_STYLE=countdown` (muestra cuenta regresiva, no espera input)
- Dual boot detectado (Windows presente) pero Linux es default
- **Kernels:** Solo 6.8.0-111 (activo) + 6.8.0-110 (fallback)

#### Troubleshooting GRUB (22 Mayo 2026)

**Problema:** Después de limpiar kernels, GRUB se quedaba esperando indefinidamente.

**Causa raíz:** Linux Mint tiene un override en `/etc/default/grub.d/98_mintsysadm.cfg` que se carga **después** de `/etc/default/grub`. Este archivo sobreescribía con:
```
GRUB_TIMEOUT_STYLE=hidden
GRUB_TIMEOUT=-1          # -1 = esperar para siempre
```

**Fix aplicado:**
```bash
# 1. Cambiar "hidden" por "countdown" en el override de Mint
#    sed -i = editar archivo in-place
#    's/viejo/nuevo/' = sustituir primera ocurrencia de "viejo" por "nuevo"
sudo sed -i 's/GRUB_TIMEOUT_STYLE=hidden/GRUB_TIMEOUT_STYLE=countdown/' /etc/default/grub.d/98_mintsysadm.cfg

# 2. Cambiar timeout de -1 (infinito) a 3 segundos en el override
sudo sed -i 's/GRUB_TIMEOUT=-1/GRUB_TIMEOUT=3/' /etc/default/grub.d/98_mintsysadm.cfg

# 3. Eliminar TODAS las líneas que contengan GRUB_TIMEOUT_STYLE en /etc/default/grub
#    '/patrón/d' = borrar cualquier línea que matchee el patrón
sudo sed -i '/GRUB_TIMEOUT_STYLE/d' /etc/default/grub

# 4. Agregar una sola línea limpia al final
echo 'GRUB_TIMEOUT_STYLE=countdown' | sudo tee -a /etc/default/grub

# 5. Regenerar la config de GRUB
sudo update-grub
```

**Lección:** En Linux Mint, los archivos en `/etc/default/grub.d/` se cargan en orden numérico y sobreescriben lo anterior. Siempre verificar esos overrides.

**Estado final:**
```
/etc/default/grub:                    TIMEOUT=3, TIMEOUT_STYLE=countdown
/etc/default/grub.d/98_mintsysadm.cfg: TIMEOUT=3, TIMEOUT_STYLE=countdown
```

### 4. WiFi — Auto-connect (system-wide)
- Red: `Auto IZZI-AADA-5G-5G`
- `autoconnect: yes` (conecta sin necesidad de login gráfico)
- `connection.permissions: ""` (system-wide, no requiere usuario)
- Interfaz: `wlp7s0`
- `wifi-unblock.service` creado para desbloquear rfkill al boot

### 5. Optimización de RAM
| Antes (setup inicial) | Después (optimizado) |
|---|---|
| ~1.1 GB usado | ~601 MB usado |
| ~2.6 GB disponible | ~3.1 GB disponible |

### 6. Swappiness
```bash
# /etc/sysctl.d/99-swappiness.conf
vm.swappiness=10
```
Usa RAM al máximo antes de tocar swap.

### 7. Servicios desactivados
| Servicio | Razón | Método |
|---|---|---|
| `bluetooth` | No se usan dispositivos BT | systemctl disable |
| `cups` | No se imprime desde esta máquina | systemctl disable |
| `ModemManager` | No hay módem 4G/USB | systemctl disable |
| `libvirtd` | No se corren VMs (KVM/QEMU) | systemctl disable |
| `mintreport-tray` | Notificaciones innecesarias (72 MB) | autostart Hidden=true |
| `evolution-alarm-notify` | Calendario no usado (62 MB) | autostart Hidden=true |
| `ibus` | Input method innecesario (34 MB) | im-config -n none |
| `NetworkManager-wait-online` | Espera red innecesaria (1 min) | systemctl disable |
| `lvm2-monitor` | No se usa LVM | systemctl disable |
| `blueman-mechanism` | GUI bluetooth innecesaria | systemctl disable |
| `virtlogd` | Logging de VMs no usadas | systemctl disable |
| `postgresql` | No se necesita DB local | apt purge |

### 8. Lid Switch — Operar con tapa cerrada
```ini
# /etc/systemd/logind.conf
HandleLidSwitch=ignore
HandleLidSwitchExternalPower=ignore
```
Cerrar la tapa no suspende la máquina.

### 9. GPU — Intel integrada (sin cambios necesarios)
- **GPU:** Intel Mobile 4 Series (GM45 Express)
- **Driver kernel:** `i915` (correcto, cargado)
- **Driver Xorg:** `modesetting`
- **OpenGL:** 4.5 (Mesa/crocus)
- **Resolución:** 1366x768
- No hay GPU dedicada, no requiere drivers adicionales

### 10. WSL Interop (en la máquina principal, no en oldtimer)
```ini
# /etc/wsl.conf (WSL Ubuntu principal)
[boot]
systemd=true
command=sh -c 'echo :WSLInterop:M::MZ::/init:PF > /proc/sys/fs/binfmt_misc/register 2>/dev/null; true'

[interop]
enabled=true
appendWindowsPath=true
```
Fix para que `kiro` y otros `.exe` de Windows funcionen desde WSL con systemd habilitado.

---

## 📊 Estado final (22 Mayo 2026)

```
Boot total: ~1 min 11 seg (32s kernel/BIOS + 38s userspace)
RAM:        ~500-600 MB en idle (sin Firefox)
Swap:       0 B / 2 GB
Servicios:  ~28 running
Kernel:     6.8.0-111-generic (fallback: 110)
Desktop:    XFCE (sin compositor)
SSD:        Kingston SV300S37A 240GB (SATA)
```

---

## 🔮 Pendientes / Ideas futuras

- [ ] Reservar IP fija en el router (DHCP reservation por MAC: `00:22:fa:16:87:58`)
- [ ] Instalar Tailscale para acceso remoto desde cualquier red
- [ ] Evaluar Docker para homelab services (OpenClaw, health checks)
- [ ] Considerar operar headless (sin Xorg) para liberar ~107 MB más
- [ ] Reducir procesos de Firefox: `about:config` → `dom.ipc.processCount` = 2
- [ ] Desactivar udisks2 o blacklist Multi-Card reader (podría reducir boot ~16 seg más)
- [ ] Configurar auto-login en LightDM (evitar pantalla de login)

---

## 🛠️ Comandos útiles

```bash
# Conectar
ssh admin@192.168.0.104

# Ver RAM
free -h

# Ver servicios activos
systemctl list-units --type=service --state=running

# Ver kernel actual
uname -r

# Reiniciar (arranca solo en 3 seg)
sudo reboot
```

---

## 📖 Sysctl — Qué significa cada parámetro

Cuando corrimos `sudo sysctl --system`, el kernel cargó estos parámetros. Aquí la explicación de cada uno:

### Seguridad y aislamiento

| Parámetro | Valor | Qué hace |
|---|---|---|
| `kernel.apparmor_restrict_unprivileged_userns` | 0 | Permite que usuarios sin privilegios creen user namespaces (necesario para containers sin root, sandboxes como Flatpak/Snap) |
| `kernel.yama.ptrace_scope` | 1 | Solo el proceso padre puede "espiar" a sus hijos con ptrace. Evita que malware se enganche a otros procesos |
| `kernel.kptr_restrict` | 1 | Oculta las direcciones de memoria del kernel en `/proc/kallsyms`. Dificulta exploits de kernel |
| `vm.mmap_min_addr` | 65536 | Prohíbe mapear memoria en las direcciones más bajas (0-64KB). Previene ataques de NULL pointer dereference |
| `kernel.dmesg_restrict` | 0 | Cualquier usuario puede leer `dmesg` (logs del kernel). En un server multi-usuario pondrías 1 |
| `fs.protected_hardlinks` | 1 | Evita que un usuario cree hardlinks a archivos que no le pertenecen (previene escalamiento de privilegios) |
| `fs.protected_symlinks` | 1 | Igual pero para symlinks en directorios sticky (como `/tmp`) |
| `fs.protected_fifos` | 1 | Protege FIFOs (named pipes) en directorios world-writable |
| `fs.protected_regular` | 2 | Protege archivos regulares de ser creados en directorios sticky por otros usuarios |
| `fs.suid_dumpable` | 2 | Permite generar core dumps de programas SUID, pero solo legibles por root (para debugging) |

### Red

| Parámetro | Valor | Qué hace |
|---|---|---|
| `net.core.default_qdisc` | fq_codel | Algoritmo de cola de red. FQ-CoDel reduce bufferbloat (lag en conexiones saturadas). Excelente para WiFi |
| `net.ipv4.conf.default.rp_filter` | 2 | Reverse Path Filter en modo "loose". Verifica que los paquetes vengan por una ruta válida (anti-spoofing) |
| `net.ipv6.conf.all.use_tempaddr` | 2 | Usa direcciones IPv6 temporales (privacy extensions). Tu IP pública IPv6 cambia periódicamente |

### Kernel y procesos

| Parámetro | Valor | Qué hace |
|---|---|---|
| `kernel.printk` | 4 4 1 7 | Niveles de log del kernel a consola. Solo muestra warnings y errores, no spam informativo |
| `kernel.sysrq` | 176 | Magic SysRq: combinación de teclas de emergencia. 176 habilita solo las funciones seguras (sync, reboot) sin las destructivas |
| `kernel.pid_max` | 4194304 | Máximo número de PIDs (procesos). 4M es suficiente para cualquier workload |
| `vm.max_map_count` | 1048576 | Máximo de regiones de memoria mapeadas por proceso. Elasticsearch y algunas JVMs necesitan este valor alto |
| `vm.swappiness` | 10 | **Lo que configuramos.** Qué tan agresivamente el kernel mueve cosas de RAM a swap. 10 = casi nunca (prefiere RAM) |
| `kernel.unprivileged_userns_clone` | 1 | Permite crear user namespaces sin ser root. Necesario para containers rootless y sandboxes |

### Core dumps

| Parámetro | Valor | Qué hace |
|---|---|---|
| `kernel.core_pattern` | `\|/usr/lib/systemd/systemd-coredump %P %u %g %s %t ...` | Cuando un programa crashea, en vez de escribir un archivo `core` en el disco, le pasa el dump a `systemd-coredump` que lo comprime, cataloga y guarda en `/var/lib/systemd/coredump/`. Los `%P %u %g %s %t` son: PID, UID, GID, señal que lo mató, timestamp |
| `kernel.core_pipe_limit` | 16 | Máximo de core dumps procesándose simultáneamente (evita saturar el disco si muchos procesos crashean a la vez) |

---

### 💡 ¿Por qué importa esto para SRE?

En una entrevista de SRE (como Bridgewater), podrían preguntarte:
- "¿Cómo investigas un crash en producción?" → `coredumpctl list`, `coredumpctl info PID`
- "¿Cómo reduces latencia de red?" → `fq_codel`, bufferbloat
- "¿Cómo hardenas un Linux server?" → `ptrace_scope`, `kptr_restrict`, `protected_*`
- "¿Cómo evitas OOM en 4GB de RAM?" → `swappiness=10`, monitorear con `free -h`
