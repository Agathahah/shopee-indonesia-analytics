# Requirements: NusaCommerce Analytics

**Defined:** 2026-04-21
**Core Value:** Complete end-to-end flow — from Kaggle API download through PostgreSQL analytics to Tableau/Looker dashboards

## v1 Requirements

Requirements for portfolio release. Each maps to roadmap phases.

### Data Pipeline

- [ ] **PIPE-01**: Kaggle API downloads dataset directly to `data/raw/` without manual intervention
- [ ] **PIPE-02**: PostgreSQL `nusacommerce` database created and configured on local Mac
- [ ] **PIPE-03**: CSV data loaded into PostgreSQL via SQLAlchemy/psycopg2 with proper schema
- [ ] **PIPE-04**: Data enriched with Faker id_ID for realistic Indonesian names, addresses, phone numbers

### SQL Analytics

- [ ] **SQL-01**: Revenue trend analysis using time-series CTEs (daily/weekly/monthly aggregations)
- [ ] **SQL-02**: RFM customer segmentation using window functions (Recency, Frequency, Monetary scoring)
- [ ] **SQL-03**: Seller performance rankings using window functions (ROW_NUMBER, RANK, percentiles)
- [ ] **SQL-04**: Delivery time analytics with date calculations (avg delivery time, on-time %, by region)

### Dashboards

- [ ] **DASH-01**: Tableau Public executive dashboard with Z-pattern layout (KPIs, trends, segments)
- [ ] **DASH-02**: Looker Studio operational dashboard connected via Google Sheets export

### Documentation

- [ ] **DOC-01**: README with clear setup instructions (PostgreSQL, Python venv, Kaggle API config)
- [ ] **DOC-02**: 7-slide McKinsey-style insight deck in Bahasa Indonesia (PDF export)
- [ ] **DOC-03**: Portfolio-ready repo structure with clean organization, screenshots, badges

## v2 Requirements

Deferred to future iterations. Tracked but not in current scope.

### Advanced Analytics

- **ADV-01**: Cohort analysis for customer retention
- **ADV-02**: Market basket analysis (frequently bought together)
- **ADV-03**: Predictive models for churn or LTV (if ML added later)

### Infrastructure

- **INFRA-01**: Dockerized environment for reproducibility
- **INFRA-02**: CI/CD pipeline for automated testing
- **INFRA-03**: Cloud deployment (AWS/GCP)

## Out of Scope

Explicitly excluded. Documented to prevent scope creep.

| Feature | Reason |
|---------|--------|
| Real-time data streaming | Portfolio focuses on batch analytics; real-time adds complexity without portfolio value |
| ML/predictive models | Pure SQL analytics showcase; ML is different skill set |
| Cloud deployment | Local PostgreSQL sufficient for portfolio demo; cloud adds cost |
| Automated refresh | Manual refresh acceptable for portfolio; automation is v2 |
| Indonesian localization in code | Comments/docs in English for international hiring managers; only insight deck in Bahasa |

## Traceability

Which phases cover which requirements. Updated during roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|
| PIPE-01 | Phase 1 | Pending |
| PIPE-02 | Phase 1 | Pending |
| PIPE-03 | Phase 1 | Pending |
| PIPE-04 | Phase 1 | Pending |
| SQL-01 | Phase 2 | Pending |
| SQL-02 | Phase 2 | Pending |
| SQL-03 | Phase 2 | Pending |
| SQL-04 | Phase 2 | Pending |
| DASH-01 | Phase 3 | Pending |
| DASH-02 | Phase 3 | Pending |
| DOC-01 | Phase 3 | Pending |
| DOC-02 | Phase 3 | Pending |
| DOC-03 | Phase 3 | Pending |

**Coverage:**
- v1 requirements: 13 total
- Mapped to phases: 13
- Unmapped: 0

---
*Requirements defined: 2026-04-21*
*Last updated: 2026-04-21 after roadmap creation*
