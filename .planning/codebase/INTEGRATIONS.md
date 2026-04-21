# External Integrations

**Analysis Date:** 2026-04-21

## APIs & External Services

**Data Sources:**
- Kaggle - Dataset downloads for Indonesia E-Commerce data
  - SDK/Client: `kaggle==2.0.1`, `kagglesdk==0.1.19`
  - Auth: `KAGGLE_USERNAME`, `KAGGLE_KEY` (via ~/.kaggle/kaggle.json or env vars)

**Google Services:**
- Google Sheets - Spreadsheet data access
  - SDK/Client: `gspread==6.2.1`
  - Auth: `google-auth==2.49.2`, `google-auth-oauthlib==1.3.1`
  - Credentials: Service account JSON or OAuth credentials

## Data Storage

**Databases:**
- PostgreSQL
  - Connection: Environment variable (expected, not yet configured)
  - Client: `psycopg2-binary==2.9.12`
  - ORM: `SQLAlchemy==2.0.49`
  - Schema location: `sql/schema/` (empty, to be populated)
  - Queries location: `sql/queries/` (empty, to be populated)
  - Views location: `sql/views/` (empty, to be populated)

**File Storage:**
- Local filesystem
  - Raw data: `data/raw/` (gitignored except .gitkeep)
  - Processed data: `data/processed/`
  - Exports: `data/exports/`

**Caching:**
- None configured

## Authentication & Identity

**Auth Provider:**
- Not applicable (analytics project, no user auth)

**Service Authentication:**
- Kaggle API: API key-based
- Google Sheets: OAuth 2.0 or service account

## Monitoring & Observability

**Error Tracking:**
- None configured

**Logs:**
- Not configured (standard Python logging expected)

## CI/CD & Deployment

**Hosting:**
- Tableau Public - Executive dashboard (cloud-hosted)
- Looker Studio - Operational dashboard (cloud-hosted)
- Dashboard configs: `dashboard/tableau/`, `dashboard/looker/`

**CI Pipeline:**
- None configured

## Environment Configuration

**Required env vars (expected):**
- PostgreSQL connection string (DATABASE_URL or similar)
- Kaggle credentials (KAGGLE_USERNAME, KAGGLE_KEY) or ~/.kaggle/kaggle.json
- Google service account credentials (for gspread)

**Secrets location:**
- `.env` file (gitignored, not yet created)
- No `.env.example` template exists

## Webhooks & Callbacks

**Incoming:**
- None

**Outgoing:**
- None

## Data Pipeline

**Expected Flow:**
1. Source data from Kaggle (Indonesia E-Commerce dataset)
2. Load into PostgreSQL via SQLAlchemy
3. Generate synthetic data with Faker (for augmentation)
4. Export processed data for dashboard consumption
5. Visualize in Tableau Public and Looker Studio

**Current State:**
- Infrastructure defined but no implementation yet
- All directories contain only `.gitkeep` placeholders

---

*Integration audit: 2026-04-21*
