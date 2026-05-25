# Reporte rápido — repositorios de `krvax`

Generado desde `/tmp/krvax_repos.json`.

## Resumen

- Total repositorios: 192
- Forks: 168
- Repos personales (no fork): 24
- Forks con última actualización antes de 2018: 105

## Padres más frecuentes (fork sources)

- python-openai-demos: 1
- API: 1
- serverless-chat-langchainjs: 1
- todo-csharp-sql: 1
- complete-devops-project: 1
- curso-apache-kafka: 1
- serverless-patterns: 1
- distroless: 1
- crossplane: 1
- wsl-vpnkit: 1

(La mayoría de forks son uno-a-uno; no hay un único origen masivo.)

## Repos más antiguos (10)

- learnGitBranching — fork — 2013-02-27
- cron4j — fork — 2013-06-06
- coffee-box — fork — 2013-10-17
- rainyday.js — fork — 2013-10-22
- xjst — fork — 2013-11-02
- sticky-kit — fork — 2013-11-05
- sticky — fork — 2013-11-06
- restangular — fork — 2013-11-11
- drywall — fork — 2013-11-11
- angular.js — fork — 2013-11-12

## Tus repos personales más recientes (10)

- `epam-aws-devops-prep` — 2026-05-25 — Python
- `AI-Club-Condesa-Workshops` — 2026-05-25 — CSS
- `cloud-platform-labs` — 2026-05-25 — Python
- `ollama-sre-workspace` — 2026-05-25 — PowerShell
- `GDG-Mexico-Python-Study-Group` — 2026-05-23 — Jupyter Notebook
- `Coatl-RAG-Assistant-Web` — 2026-05-10 — TypeScript
- `rust-devops-lab` — 2026-04-04
- `minikube-lab` — 2026-03-09 — Shell
- `infra-notes` — 2025-12-28
- `railway-test-app` — 2025-10-24 — Python

## Archivar / eliminar forks antiguos — opciones y comandos sugeridos

1) Generar lista de forks antiguos (ej. antes de 2018):

```bash
jq -r '.[] | select(.isFork and (.updatedAt < "2018-01-01")) | .name' /tmp/krvax_repos.json > /tmp/krvax_old_forks.txt
```

2) Revisar cada repo en el navegador antes de borrar:

```bash
while read repo; do gh repo view krvax/$repo --web; read -p "Press Enter to continue..."; done < /tmp/krvax_old_forks.txt
```

3) Eliminar en lote (irrevocable):

```bash
while read repo; do gh repo delete krvax/$repo --confirm; done < /tmp/krvax_old_forks.txt
```

4) Alternativa: marcar como archivado (no borrado) vía API:

```bash
while read repo; do gh api -X PATCH /repos/krvax/$repo -f archived=true; done < /tmp/krvax_old_forks.txt
```

Nota: ejecutar los pasos 3/4 es destructivo/irreversible (3) o cambia visibilidad (4). Revisa antes.

## Archivos generados

- `/tmp/krvax_repos.json` — listado JSON completo
- `/tmp/krvax_summary.json` — resumen JSON breve
- Reporte: this file (`/home/mcarvaj/src/krvax-repos-report.md`)

---

¿Quieres que:

- A) Genere la lista `/tmp/krvax_old_forks.txt` ahora y te muestre un pre-listado de nombres (seguro, no borro nada),
- B) Archive automáticamente los forks antiguos (usar opción API, más seguro),
- C) Elimine automáticamente los forks antiguos (irrevocable),
- D) Nada por ahora, sólo quería el reporte?

Responde con la letra deseada y procederé.