# Codebase Concerns

**Analysis Date:** 2026-04-21

## Tech Debt

**Empty Project Structure:**
- Issue: Project is scaffolded but contains no implementation code
- Files: `scripts/` (empty), `notebooks/` (empty), `sql/queries/` (empty), `sql/schema/` (empty), `sql/views/` (empty)
- Impact: Cannot demonstrate any analytics functionality; project is non-functional
- Fix approach: Implement core data pipeline scripts, SQL schemas, and analysis notebooks

**Dashboard Placeholders:**
- Issue: Dashboard directories contain only `.gitkeep` files with no actual dashboard configurations
- Files: `dashboard/looker/`, `dashboard/tableau/`
- Impact: No visualization layer exists despite README claiming Tableau Public and Looker Studio dashboards
- Fix approach: Create actual Tableau workbooks (.twb/.twbx) and Looker LookML files after data pipeline is built

## Known Bugs

**Not Applicable:**
- No implementation code exists to contain bugs

## Security Considerations

**Missing Environment Configuration:**
- Risk: No `.env` file or `.env.example` exists despite `psycopg2-binary` and database dependencies in `requirements.txt`
- Files: Project root (missing `.env.example`)
- Current mitigation: `.gitignore` excludes `.env` files
- Recommendations: Create `.env.example` with required variables (DB_HOST, DB_USER, DB_PASSWORD, etc.) before implementation begins

**Google Sheets Integration Credentials:**
- Risk: `gspread` and `google-auth-oauthlib` in requirements suggest Google API integration; no guidance on credential management
- Files: `requirements.txt` lines 24-26
- Current mitigation: None documented
- Recommendations: Document credential setup process; add credential paths to `.gitignore`; consider using service accounts with minimal permissions

**Kaggle API Credentials:**
- Risk: `kaggle` package in requirements requires API credentials; no setup documentation
- Files: `requirements.txt` lines 54-55
- Current mitigation: None documented
- Recommendations: Document Kaggle API token setup; ensure `~/.kaggle/kaggle.json` is properly secured

## Performance Bottlenecks

**Not Applicable:**
- No implementation code exists to analyze for performance issues

**Potential Future Concerns:**
- Large CSV handling: `.gitignore` excludes `*.csv` and `*.xlsx`, suggesting data files may be large
- Files: `data/raw/`, `data/processed/`
- Cause: Unknown data volume expectations
- Improvement path: Consider chunked pandas operations, database staging, or Dask for large datasets when implementing

## Fragile Areas

**Dependency Version Pinning:**
- Files: `requirements.txt`
- Why fragile: All dependencies are fully version-pinned; while reproducible, may cause issues when security updates are needed
- Safe modification: Use `pip-compile` or similar tools to manage dependency updates systematically
- Test coverage: No tests exist

**Data Pipeline Dependencies:**
- Files: Project structure assumes `data/raw/` -> `data/processed/` -> `data/exports/` flow
- Why fragile: No validation exists between pipeline stages; raw data directory is git-ignored
- Safe modification: Implement data validation/schema checks at each pipeline stage
- Test coverage: No tests exist

## Scaling Limits

**Not Applicable:**
- No implementation exists to assess scaling limits

**Design Considerations:**
- Current architecture assumes local file-based data flow
- Files: `data/` directory structure
- Limit: Local disk space and memory for pandas operations
- Scaling path: Consider cloud storage (S3/GCS) and distributed processing if data volume grows

## Dependencies at Risk

**psycopg2-binary:**
- Risk: Binary package not recommended for production by maintainers
- Impact: May have subtle issues in production deployments
- Migration plan: Switch to `psycopg2` with proper libpq development headers for production

**Large Dependency Surface:**
- Risk: 117 dependencies in `requirements.txt` for a project with no implementation; many are transitive Jupyter dependencies
- Impact: Increased attack surface, slower environment setup
- Migration plan: Consider splitting into `requirements-dev.txt` (Jupyter, etc.) and `requirements.txt` (core dependencies only)

## Missing Critical Features

**Data Generation Scripts:**
- Problem: README mentions Faker for synthetic data generation but no scripts exist
- Blocks: Cannot create sample e-commerce dataset

**Database Schema:**
- Problem: No SQL schema files despite `sql/schema/` directory existing
- Blocks: Cannot set up PostgreSQL database structure

**ETL/Data Pipeline:**
- Problem: No extraction, transformation, or loading scripts exist
- Blocks: Cannot process raw data into analytics-ready format

**Analysis Queries:**
- Problem: No SQL queries in `sql/queries/` despite project goal of "SQL kompleks"
- Blocks: Cannot demonstrate complex SQL analytics capabilities

**Notebooks:**
- Problem: No Jupyter notebooks despite `notebooks/` directory and full Jupyter stack in requirements
- Blocks: Cannot demonstrate data exploration or analysis

**Documentation:**
- Problem: `docs/` directory is empty; README is minimal
- Blocks: No onboarding documentation for contributors; no data dictionary

## Test Coverage Gaps

**Complete Absence of Tests:**
- What's not tested: Everything (no tests exist)
- Files: No `tests/` directory, no test files anywhere
- Risk: Any implementation will have zero automated verification
- Priority: High - establish testing patterns before implementing features

**No CI/CD Configuration:**
- What's not tested: No GitHub Actions, no pre-commit hooks, no linting configuration
- Files: No `.github/workflows/`, no `.pre-commit-config.yaml`, no `pyproject.toml` with tool configs
- Risk: Code quality and correctness cannot be automatically verified
- Priority: High - set up basic CI pipeline with linting and tests

---

*Concerns audit: 2026-04-21*
