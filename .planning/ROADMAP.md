# Roadmap: NusaCommerce Analytics

## Overview

Three-phase journey: first automate the data pipeline from Kaggle to PostgreSQL with realistic enrichment, then write the SQL analytics layer that demonstrates advanced query patterns, then build the dashboards and documentation that make this portfolio-ready for hiring managers.

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [ ] **Phase 1: Data Pipeline** - Automated ingestion from Kaggle API to PostgreSQL with Indonesian data enrichment
- [ ] **Phase 2: SQL Analytics** - Four production-quality SQL analyses using CTEs and window functions
- [ ] **Phase 3: Dashboards & Documentation** - Tableau and Looker dashboards plus portfolio-ready repo documentation

## Phase Details

### Phase 1: Data Pipeline
**Goal**: Raw Kaggle data flows automatically into a structured PostgreSQL database enriched with realistic Indonesian data
**Depends on**: Nothing (first phase)
**Requirements**: PIPE-01, PIPE-02, PIPE-03, PIPE-04
**Success Criteria** (what must be TRUE):
  1. Running the pipeline script downloads the dataset to `data/raw/` with zero manual file handling
  2. A `nusacommerce` PostgreSQL database exists locally with properly typed schema tables
  3. All CSV data is queryable from PostgreSQL with correct row counts and data types
  4. Customer records contain realistic Indonesian names, addresses, and phone numbers via Faker id_ID
**Plans**: TBD

### Phase 2: SQL Analytics
**Goal**: Four analytical SQL queries demonstrate advanced patterns and produce meaningful business insights from the ecommerce data
**Depends on**: Phase 1
**Requirements**: SQL-01, SQL-02, SQL-03, SQL-04
**Success Criteria** (what must be TRUE):
  1. A CTE-based query produces daily/weekly/monthly revenue trend results that can be exported or visualized
  2. Customers are scored and segmented by Recency, Frequency, and Monetary value using window functions
  3. Sellers are ranked by performance metrics using ROW_NUMBER, RANK, and percentile window functions
  4. Delivery time analysis query returns average delivery time, on-time percentage, and breakdowns by region
**Plans**: TBD

### Phase 3: Dashboards & Documentation
**Goal**: Portfolio is complete — two interactive dashboards are published and the repository communicates full-stack DA capability to hiring managers
**Depends on**: Phase 2
**Requirements**: DASH-01, DASH-02, DOC-01, DOC-02, DOC-03
**Success Criteria** (what must be TRUE):
  1. Tableau Public dashboard is live and publicly accessible with Z-pattern layout showing KPIs, trends, and segments
  2. Looker Studio dashboard is accessible via link, connected through Google Sheets export, showing operational metrics
  3. README enables a new user to set up PostgreSQL, Python venv, and Kaggle API and run the pipeline end-to-end
  4. A 7-slide PDF insight deck in Bahasa Indonesia exists summarizing findings in McKinsey presentation style
  5. Repository has clean folder structure, dashboard screenshots, and badges that signal portfolio quality at a glance
**Plans**: TBD
**UI hint**: yes

## Progress

**Execution Order:**
Phases execute in numeric order: 1 → 2 → 3

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Data Pipeline | 0/TBD | Not started | - |
| 2. SQL Analytics | 0/TBD | Not started | - |
| 3. Dashboards & Documentation | 0/TBD | Not started | - |
