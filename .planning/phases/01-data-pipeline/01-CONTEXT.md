# Phase 1: Data Pipeline - Context

**Gathered:** 2026-04-21
**Status:** Ready for planning

<domain>
## Phase Boundary

Automated data pipeline that downloads the Indonesia E-Commerce dataset from Kaggle API, loads it into a local PostgreSQL database, and enriches customer records with realistic Indonesian names and addresses using Faker id_ID.

</domain>

<decisions>
## Implementation Decisions

### Pipeline Structure
- **D-01:** Modular scripts — separate `download.py`, `ingest.py`, `enrich.py` files in `scripts/`. Each can run independently for easier debugging and testing.
- **D-02:** Configuration via `.env` file — database credentials, Kaggle dataset name stored in `.env`. Include `.env.example` in repo for setup instructions.
- **D-03:** Single entry point via `run_pipeline.py` — thin wrapper that calls download → ingest → enrich in sequence. Portfolio reviewers run one command.
- **D-04:** Simple print statements for progress — no logging framework. Output like "Downloading dataset...", "Loaded 50,000 rows".
- **D-05:** No CLI arguments — scripts read from `.env` only. Simpler code, cleaner README.

### Schema Design
- **D-06:** Mirror CSV structure exactly — same table and column names as Kaggle CSV files. Easy data lineage for portfolio transparency.
- **D-07:** PostgreSQL-specific types — use TIMESTAMP, NUMERIC(12,2), TEXT. Shows database knowledge, proper precision for money columns.
- **D-08:** Primary keys only — add PKs for each table. Skip foreign keys (CSV may have inconsistencies). Minimal but correct.
- **D-09:** Schema in SQL files — CREATE TABLE statements in `sql/schema/*.sql`. Can run directly in psql.

### Enrichment Strategy
- **D-10:** Enrich customer fields only — customer names, addresses, phone numbers get Faker data. Sellers keep original values.
- **D-11:** Replace original values — overwrite name, address, phone with Faker data. Simpler schema, cleaner for dashboards.
- **D-12:** Fixed seed for reproducibility — `Faker.seed(42)` produces same fake names each run. Good for reproducible demos.

### Idempotency & Error Handling
- **D-13:** Drop and recreate on each run — each pipeline execution drops tables and recreates from scratch. Always clean state.
- **D-14:** Log and continue on errors — skip bad rows, log warnings, continue processing. Allows partial success.
- **D-15:** Row counts summary at end — print "Loaded: orders=X, customers=Y, skipped=Z rows". Clear success metric.

### Claude's Discretion
None — all areas were explicitly discussed.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Project Context
- `.planning/PROJECT.md` — Core value statement, constraints, key decisions
- `.planning/REQUIREMENTS.md` — PIPE-01 through PIPE-04 requirements for this phase
- `.planning/ROADMAP.md` — Phase goal and success criteria

### External Resources
- Kaggle dataset: `dikisahkan/indonesia-ecommerce-sales-2023-2025` (referenced in PROJECT.md)

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `requirements.txt` already includes: kaggle, psycopg2-binary, SQLAlchemy, Faker, pandas, tqdm
- Python 3.12 venv is set up and ready

### Established Patterns
- Folder structure exists: `data/raw/`, `data/processed/`, `data/exports/`, `sql/schema/`, `scripts/`
- No existing code patterns yet — this is the first implementation phase

### Integration Points
- Scripts go in `scripts/` folder
- Schema SQL goes in `sql/schema/` folder
- Downloaded data lands in `data/raw/`
- Processed/enriched tracking can use `data/processed/`

</code_context>

<specifics>
## Specific Ideas

No specific requirements — open to standard approaches.

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>

---

*Phase: 01-data-pipeline*
*Context gathered: 2026-04-21*
