# Phase 1: Data Pipeline - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-04-21
**Phase:** 01-data-pipeline
**Areas discussed:** Pipeline structure, Schema design, Enrichment strategy, Idempotency & errors

---

## Pipeline Structure

### How should the pipeline be organized?

| Option | Description | Selected |
|--------|-------------|----------|
| Modular scripts (Recommended) | Separate scripts: download.py, ingest.py, enrich.py. Each can run independently. Easier to debug and extend. | ✓ |
| Single orchestrator | One main.py that calls internal functions. Simpler to run but harder to debug individual steps. | |
| Make-based | Makefile targets (make download, make ingest). Good for portfolio demos but adds a layer. | |

**User's choice:** Modular scripts (Recommended)

### Where should configuration live?

| Option | Description | Selected |
|--------|-------------|----------|
| .env file (Recommended) | Standard approach. python-dotenv loads it. .env.example in repo for setup instructions. | ✓ |
| config.yaml | More structured, good for complex config. Overkill for this project's needs. | |
| Environment variables only | No file needed. User exports vars manually. Cleanest but less discoverable. | |

**User's choice:** .env file (Recommended)

### How should someone run the full pipeline?

| Option | Description | Selected |
|--------|-------------|----------|
| run_pipeline.py (Recommended) | A thin wrapper that calls download → ingest → enrich in sequence. Single entry point for demos. | ✓ |
| Makefile | 'make all' runs the sequence. 'make download' runs just download. Familiar to devs. | |
| README instructions | User runs each script manually in order. Simplest but more friction for reviewers. | |

**User's choice:** run_pipeline.py (Recommended)

### How much logging and progress feedback?

| Option | Description | Selected |
|--------|-------------|----------|
| Print statements (Recommended) | Simple print() for progress. 'Downloading dataset...', 'Loaded 50,000 rows'. Good for portfolio. | ✓ |
| Python logging module | Configurable log levels (DEBUG, INFO). More professional but adds complexity. | |
| tqdm progress bars | Visual progress bars for long operations. Already in requirements.txt. Nice for demos. | |

**User's choice:** Print statements (Recommended)

### Should scripts accept command-line arguments?

| Option | Description | Selected |
|--------|-------------|----------|
| No CLI args (Recommended) | Scripts read from .env only. Simpler code, cleaner README instructions. | ✓ |
| Optional overrides | Can pass --db-name or --force via argparse. More flexible but adds code. | |
| You decide | Claude picks the simplest approach that works | |

**User's choice:** No CLI args (Recommended)

---

## Schema Design

### How closely should PostgreSQL schema match the Kaggle CSV structure?

| Option | Description | Selected |
|--------|-------------|----------|
| Mirror CSV exactly (Recommended) | Same table/column names as CSV files. Easy to trace data lineage. Good for portfolio transparency. | ✓ |
| Normalize tables | Split into proper 3NF (products, categories separate). Shows DB design skills but adds complexity. | |
| Hybrid approach | Keep main structure, add some normalization where obvious. Middle ground. | |

**User's choice:** Mirror CSV exactly (Recommended)

### Should we use PostgreSQL-specific data types or keep it generic?

| Option | Description | Selected |
|--------|-------------|----------|
| PostgreSQL types (Recommended) | TIMESTAMP, NUMERIC(12,2), TEXT. Shows you know the database. Proper precision for money. | ✓ |
| Generic types | VARCHAR, FLOAT, INTEGER. More portable but less precise. Misses portfolio opportunity. | |
| You decide | Claude picks appropriate types based on the actual CSV data | |

**User's choice:** PostgreSQL types (Recommended)

### How much schema enforcement — constraints and indexes?

| Option | Description | Selected |
|--------|-------------|----------|
| Primary keys only (Recommended) | Add PKs for each table. Skip foreign keys (CSV may have inconsistencies). Minimal but correct. | ✓ |
| Full constraints | PKs, FKs, NOT NULLs, CHECKs. Shows DB design skills but may fail on messy Kaggle data. | |
| Indexes for analytics | PKs plus indexes on columns used in Phase 2 queries (date, customer_id). Performance-aware. | |

**User's choice:** Primary keys only (Recommended)

### Where should schema definitions live?

| Option | Description | Selected |
|--------|-------------|----------|
| sql/schema/*.sql files (Recommended) | CREATE TABLE statements in SQL files. Can run directly in psql. Clear and portable. | ✓ |
| SQLAlchemy models | Python ORM classes in models.py. Schema created via Base.metadata.create_all(). Pythonic. | |
| Both | SQL files as source of truth, SQLAlchemy reflects them. More work but comprehensive. | |

**User's choice:** sql/schema/*.sql files (Recommended)

---

## Enrichment Strategy

### Which fields should be enriched with Faker id_ID data?

| Option | Description | Selected |
|--------|-------------|----------|
| Customer fields only (Recommended) | Customer names, addresses, phone numbers. Sellers keep original data. Focused and meaningful. | ✓ |
| Customers + sellers | Both customer and seller data get Indonesian names/addresses. More realistic but more work. | |
| All text fields | Any name, address, description field. Comprehensive but may over-enrich product descriptions. | |

**User's choice:** Customer fields only (Recommended)

### Replace original values or add new columns?

| Option | Description | Selected |
|--------|-------------|----------|
| Replace originals (Recommended) | Overwrite name, address, phone with Faker data. Simpler schema, cleaner for dashboards. | ✓ |
| Add new columns | Keep original_name, add fake_name. Preserves audit trail but clutters schema. | |
| Separate enriched table | customers_raw and customers_enriched tables. Most flexible but adds complexity. | |

**User's choice:** Replace originals (Recommended)

### Should Faker data be reproducible (same fake names each run)?

| Option | Description | Selected |
|--------|-------------|----------|
| Fixed seed (Recommended) | Faker.seed(42) produces same names each time. Good for reproducible demos and testing. | ✓ |
| Random each time | Different names on each pipeline run. More realistic but harder to verify results. | |
| Customer ID as seed | Each customer gets consistent fake name based on their ID. Best of both worlds. | |

**User's choice:** Fixed seed (Recommended)

---

## Idempotency & Errors

### What happens if you run the pipeline twice?

| Option | Description | Selected |
|--------|-------------|----------|
| Drop and recreate (Recommended) | Each run drops tables and recreates from scratch. Simple, always clean state. Good for portfolio. | ✓ |
| Skip if exists | Check if data exists, skip steps already done. Faster re-runs but more complex logic. | |
| Upsert/merge | Update existing rows, insert new ones. Most robust but overkill for batch pipeline. | |

**User's choice:** Drop and recreate (Recommended)

### How should the pipeline handle errors?

| Option | Description | Selected |
|--------|-------------|----------|
| Fail fast (Recommended) | Stop immediately on error with clear message. User fixes issue and re-runs. Simple and honest. | |
| Log and continue | Skip bad rows, log warnings, continue processing. Partial success possible but messy. | ✓ |
| Retry with backoff | Retry transient failures (network, DB). More robust but adds complexity for portfolio project. | |

**User's choice:** Log and continue
**Notes:** User chose non-recommended option — prefers partial success over strict failure.

### How should the pipeline report success/failure at the end?

| Option | Description | Selected |
|--------|-------------|----------|
| Row counts summary (Recommended) | Print 'Loaded: orders=50000, customers=10000, skipped=5 rows'. Clear success metric. | ✓ |
| Exit codes only | Exit 0 on success, exit 1 on failure. Minimal output, good for automation. | |
| Detailed log file | Write pipeline_run.log with timestamps, counts, errors. Professional but adds file management. | |

**User's choice:** Row counts summary (Recommended)

---

## Claude's Discretion

None — all areas were explicitly discussed with user choices.

## Deferred Ideas

None — discussion stayed within phase scope.
