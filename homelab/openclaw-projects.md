# OpenClaw — Proyectos Planeados

> Estado: Planeación  
> Fecha: 20 Mayo 2026  
> Infra: oldtimer (192.168.0.104) + WSL + Discord (coatl-bot)

---

## Proyecto 1: Lab de SRE Viviente

**Objetivo:** Correr OpenClaw como servicio monitoreado en oldtimer. Practicar systemd, health checks, alerting, e incident response con un servicio real.

### Tareas

- [ ] Instalar OpenClaw como systemd service en oldtimer
- [ ] Crear unit file (`/etc/systemd/system/openclaw.service`)
- [ ] Configurar restart automático (`Restart=on-failure`)
- [ ] Health check: script Python/Bash que haga curl al gateway cada 60s
- [ ] Si falla 3 veces seguidas → manda alerta a Discord (webhook)
- [ ] Cron job o systemd timer para el health check
- [ ] Dashboard básico: uptime log en archivo o SQLite
- [ ] Documentar runbook: "qué hacer si OpenClaw se cae"

### Conceptos de SRE que practica
- systemd services (unit files, journalctl, restart policies)
- Health checks y probes (liveness, readiness)
- Alerting (Discord webhooks como poor-man's PagerDuty)
- Incident response (runbooks)
- SLI/SLO (uptime target, error budget)
- Change management (documentar cada cambio)

### Stack
- systemd (service management)
- Python o Bash (health check script)
- Discord webhook (alerting)
- cron o systemd timer (scheduling)
- journalctl (logs)

---

## Proyecto 2: Bot de Discord para Job Search

**Objetivo:** Usar OpenClaw vía Discord para analizar JDs, dar fit scores, y sugerir respuestas a recruiters desde el celular.

### Tareas

- [ ] Definir canal privado en Discord para job search
- [ ] Crear prompts/comandos:
  - `analiza [JD]` → Fit score + gaps + recomendación (responder/declinar)
  - `responde [contexto]` → Draft de respuesta al recruiter
  - `status` → Resumen de procesos activos (lee del CRM?)
- [ ] Configurar OpenClaw con el modelo cloud (qwen3-coder o gemma)
- [ ] Prompt engineering: darle contexto de tu perfil/CV como system prompt
- [ ] Test: mandarle el JD de Home Depot y ver si da un análisis útil

### Conceptos que practica
- Prompt engineering
- Bot architecture (command parsing, context management)
- API integration (Discord + Ollama cloud)
- NLP aplicado a casos reales

### Stack
- OpenClaw + coatl-bot (Discord)
- Ollama cloud (qwen3-coder:480b-cloud o gemma)
- System prompt con tu perfil profesional

---

## Prioridad

1. **Proyecto 1 primero** — es infra pura, practica SRE, y te da la base para que el Proyecto 2 corra de forma confiable.
2. **Proyecto 2 después** — una vez que OpenClaw esté estable como servicio, le agregas los comandos de job search.

---

## Notas

- No bloquea la prep de Python ni Bridgewater. Es un side project para weekends o ratos libres.
- Cada paso es documentable como experiencia SRE real para entrevistas.
- "Corro un servicio de AI en mi homelab, monitoreado con health checks y alerting a Discord" es una historia STAR lista.
