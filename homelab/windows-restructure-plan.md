# Operación: Reestructura de carpetas en Windows

> Estado: PENDIENTE — Abrir nueva sesión de Kiro desde PowerShell apuntando a `C:\src\learning`  
> Fecha: 20 Mayo 2026  
> Contexto: Replicar la misma estructura que se hizo en WSL (`~/src/learning/`) ahora en Windows

---

## Estado actual de `C:\src\learning\`

```
C:\src\learning\
├── AI-Club-Condesa/           → courses/ai-club-condesa/
├── assessments/               → ¿? (EXPLORAR primero)
├── aws/                       → aws/ (ya encaja)
├── bigData/                   → data-engineering/big-data/
├── Build-with-AI/             → ¿? (EXPLORAR primero)
├── c-sharp/                   → systems/c-sharp/
├── EPAM/                      → interview-prep/epam-aws-devops/
├── gcp/                       → ¿? (EXPLORAR primero)
├── java/                      → java-projects/
├── latent-view-data-eng/      → data-engineering/latent-view/
├── microsoftReactor/          → courses/ms-reactor-vectors/
├── ollama/                    → sre-observability/ollama-sre-workspace/
├── santander-open-academy/    → courses/santander-open-academy/
└── fastapi-react-poc.zip      → web-apps/ o eliminar
```

---

## Estructura objetivo

```
C:\src\learning\
├── interview-prep/
│   └── epam-aws-devops/       (ex EPAM/)
├── web-apps/
│   └── (fastapi-react-poc si se descomprime)
├── aws/                       (ya existe, mantener)
├── sre-observability/
│   └── ollama-sre-workspace/  (ex ollama/)
├── java-projects/             (ex java/)
├── data-engineering/
│   ├── latent-view/           (ex latent-view-data-eng/)
│   └── big-data/              (ex bigData/)
├── systems/
│   └── c-sharp/               (ex c-sharp/)
├── courses/
│   ├── ai-club-condesa/       (ex AI-Club-Condesa/)
│   ├── ms-reactor-vectors/    (ex microsoftReactor/)
│   └── santander-open-academy/ (ex santander-open-academy/)
├── assessments/               (EXPLORAR — puede ir a interview-prep/ o courses/)
├── Build-with-AI/             (EXPLORAR — puede ir a courses/ o web-apps/)
├── gcp/                       (EXPLORAR — puede ir a aws/ renombrado a cloud/ o propio)
└── README.md
```

---

## Pasos para la nueva sesión

1. [ ] Abrir Kiro desde PowerShell: `kiro C:\src\learning`
2. [ ] Explorar carpetas desconocidas: `assessments/`, `Build-with-AI/`, `gcp/`
3. [ ] Decidir destino de cada una
4. [ ] Crear nueva estructura de carpetas
5. [ ] Mover proyectos
6. [ ] Eliminar carpetas vacías y `fastapi-react-poc.zip` si no sirve
7. [ ] Verificar `.git` internos
8. [ ] Crear README.md índice
9. [ ] Considerar si algunos repos son duplicados de WSL (y si vale la pena mantener ambos)

---

## Pregunta clave para Miguel

Algunos repos existen tanto en WSL como en Windows (EPAM, ollama, AI-Club-Condesa).
¿Quieres mantener ambas copias o consolidar en un solo lugar (WSL) y acceder desde Windows vía `\\wsl.localhost\`?