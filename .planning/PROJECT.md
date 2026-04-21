# NusaCommerce Analytics

## What This Is

End-to-end Data Analyst portfolio project showcasing the complete journey from raw Kaggle data to polished dashboards and insights. Built around Indonesia E-Commerce Sales 2023-2025 dataset, demonstrating production-quality SQL, automated pipelines, and executive-ready visualizations.

## Core Value

**Complete end-to-end flow** — from Kaggle API download through PostgreSQL analytics to Tableau/Looker dashboards. If the pipeline breaks anywhere, the portfolio fails to demonstrate full-stack DA capability.

## Requirements

### Validated

(None yet — ship to validate)

### Active

- [ ] Kaggle API pipeline downloads dataset directly to `data/raw/`
- [ ] PostgreSQL local setup with `nusacommerce` database
- [ ] Data ingestion from CSV to PostgreSQL via SQLAlchemy/psycopg2
- [ ] Data enrichment with Faker id_ID for realistic Indonesian names/addresses
- [ ] SQL analytics: revenue trends with time-series CTEs
- [ ] SQL analytics: RFM customer segmentation with window functions
- [ ] SQL analytics: seller performance rankings
- [ ] SQL analytics: delivery time analysis
- [ ] Tableau Public dashboard: executive view, Z-pattern layout
- [ ] Looker Studio dashboard: operational view via Google Sheets connection
- [ ] Insight deck: 7-slide McKinsey-style PDF in Bahasa Indonesia
- [ ] GitHub repo: portfolio-ready with clear README, structure, documentation

### Out of Scope

- Real-time data streaming — portfolio focuses on batch analytics
- ML/predictive models — pure SQL analytics showcase
- Cloud deployment — local Mac PostgreSQL sufficient for portfolio demo
- Indonesian language localization in code — comments/docs in English, only insight deck in Bahasa

## Context

**Portfolio Purpose:** Demonstrate DA competency to tech hiring managers who will evaluate:
- Code quality and SQL patterns
- Repository structure and documentation
- End-to-end thinking (not just isolated skills)

**Dataset:** Indonesia E-Commerce Sales 2023-2025
- Source: Kaggle (`dikisahkan/indonesia-ecommerce-sales-2023-2025`)
- Download method: Kaggle API (zero manual CSV upload)
- Contains: orders, customers, sellers, products, payments, reviews

**Local Environment:**
- PostgreSQL on Mac (Homebrew or Postgres.app)
- Python 3.12 with venv
- Existing project structure with `sql/`, `data/`, `dashboard/`, `notebooks/` folders

## Constraints

- **Database**: PostgreSQL local Mac — no cloud databases
- **BI Tools**: Tableau Public (free) and Looker Studio (free) — no paid licenses
- **Looker Connection**: Must use Google Sheets as intermediary (Looker Studio can't connect directly to local PostgreSQL)
- **Language**: Insight deck in Bahasa Indonesia; all code/docs in English

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Kaggle API over manual download | Reproducible pipeline, demonstrates automation | — Pending |
| PostgreSQL over SQLite | Industry-standard RDBMS, window functions, CTEs | — Pending |
| Faker id_ID enrichment | Realistic Indonesian data for portfolio credibility | — Pending |
| Google Sheets as Looker bridge | Only free way to connect Looker Studio to local data | — Pending |
| Z-pattern for Tableau exec dashboard | Standard executive dashboard UX pattern | — Pending |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd-transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `/gsd-complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-04-21 after initialization*
