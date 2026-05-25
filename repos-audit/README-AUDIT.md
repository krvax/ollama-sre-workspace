# Repos audit — Cómo ver y qué se hizo

Este directorio contiene los artefactos generados durante la auditoría de repositorios de la cuenta `krvax`.

Archivos generados:

- `krvax-repos-report.md` — Reporte en Markdown (resumen humano).
- `krvax_repos.json` — JSON completo devuelto por `gh repo list krvax --json ...`.
- `krvax_summary.json` — Resumen JSON reducido.
- `krvax_old_forks.txt` — Lista de nombres de forks con última actualización anterior a 2018.
- `krvax_archive_log.txt` — Log de operaciones de archivado (`archived <repo>`).
- `analyze_repos.py` — Script para generar los archivos anteriores a partir del JSON.

Cómo ver repos archivados (opciones):

1) Desde la web (fácil):

   - Ir a la búsqueda avanzada de repositorios de GitHub y usar el filtro `user:krvax archived:true`.
   - URL directa (reemplaza `krvax` si aplica):

     https://github.com/search?q=user%3Akrvax+archived%3Atrue&type=repositories

   - También en cada página de repo verás un banner "Archived" si el repo está archivado.

2) Desde la CLI (`gh`):

   - Listar repos y filtrar por `archived` con `jq`:

     ```bash
     gh repo list krvax --limit 500 --json name,isFork,archived,updatedAt -L 500 \
       | jq -r '.[] | select(.archived==true) | "\(.name) \(.updatedAt)"'
     ```

   - Comprobar un repo en particular:

     ```bash
     gh api repos/krvax/<repo> --jq .archived
     # o
     gh api repos/krvax/<repo> | jq .archived
     ```

3) Usar el script `analyze_repos.py` (local):

   - Preparar JSON con `gh`:

     ```bash
     gh repo list krvax -L 500 --json name,owner,isFork,parent,description,updatedAt,primaryLanguage,stargazerCount > /tmp/krvax_repos.json
     ```

   - Ejecutar el análisis (no archiva):

     ```bash
     python3 repos-audit/analyze_repos.py /tmp/krvax_repos.json
     ```

   - Esto escribirá `/tmp/krvax_summary.json` y `/tmp/krvax_old_forks.txt`.

   - Para intentar archivar los forks (requiere `gh` autenticado y es una acción remota):

     ```bash
     python3 repos-audit/analyze_repos.py /tmp/krvax_repos.json --archive --owner krvax
     ```

     Esto escribirá además `/tmp/krvax_archive_log.txt` con el resultado por repos.

Qué ejecuté yo en esta sesión (registro):

1. Listé los repos y guardé JSON en `/tmp/krvax_repos.json`:

   ```bash
   gh repo list krvax -L 500 --json name,owner,isFork,parent,description,updatedAt,primaryLanguage,stargazerCount > /tmp/krvax_repos.json
   ```

2. Ejecuté `analyze_repos.py` localmente para generar el resumen y la lista de forks antiguos.

3. Archivé los forks con `updatedAt < 2018-01-01` mediante `gh api -X PATCH /repos/krvax/<repo> -f archived=true` en un bucle.

4. Guardé todos los artefactos en este repositorio en `repos-audit/` y creé un issue con el resumen.

Precauciones
- Archivar es reversible (`archived=false`) pero borrar repos es irreversible. Revise la lista antes de borrar.
- Toda acción que modifique repos remotos requiere que `gh` esté autenticado con permisos adecuados.

Si quieres, puedo:

- A) preparar una lista interactiva para que revises cada repo en el navegador antes de borrar,
- B) automatizar el borrado de un subconjunto (confirmación requerida), o
- C) hacer nada más por ahora.
