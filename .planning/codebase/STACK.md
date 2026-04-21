# Technology Stack

**Analysis Date:** 2026-04-21

## Languages

**Primary:**
- Python 3.12.2 - Data processing, ETL scripts, data generation

**Secondary:**
- SQL (PostgreSQL dialect) - Database schema, queries, views

## Runtime

**Environment:**
- Python 3.12.2

**Package Manager:**
- pip (via venv)
- Lockfile: `requirements.txt` (present, fully pinned versions)

## Frameworks

**Core:**
- pandas 3.0.2 - Data manipulation and analysis
- SQLAlchemy 2.0.49 - Database ORM and connection management
- Faker 40.15.0 - Synthetic data generation

**Notebook/Interactive:**
- Jupyter 1.1.1 - Interactive development
- JupyterLab 4.5.6 - Notebook interface
- ipywidgets 8.1.8 - Interactive widgets

**Build/Dev:**
- Not applicable (no build tooling configured)

## Key Dependencies

**Critical:**
- `pandas==3.0.2` - Core data manipulation library
- `SQLAlchemy==2.0.49` - Database abstraction layer
- `psycopg2-binary==2.9.12` - PostgreSQL database driver

**Data Sources:**
- `kaggle==2.0.1` - Kaggle API client for dataset downloads
- `kagglesdk==0.1.19` - Kaggle SDK

**Google Integration:**
- `gspread==6.2.1` - Google Sheets API client
- `google-auth==2.49.2` - Google authentication
- `google-auth-oauthlib==1.3.1` - Google OAuth

**Data Generation:**
- `Faker==40.15.0` - Synthetic data generation
- `python-slugify==8.0.4` - Slug generation utilities

**HTTP/Networking:**
- `requests==2.33.1` - HTTP client
- `httpx==0.28.1` - Async HTTP client

**Utilities:**
- `numpy==2.4.4` - Numerical computing
- `beautifulsoup4==4.14.3` - HTML parsing
- `tqdm==4.67.3` - Progress bars
- `PyYAML==6.0.3` - YAML parsing

## Configuration

**Environment:**
- `.env` file expected (listed in `.gitignore`)
- No `.env.example` template exists yet

**Build:**
- No build configuration (pure Python project)
- Virtual environment in `venv/` directory

## Platform Requirements

**Development:**
- Python 3.12+
- PostgreSQL database (local or remote)
- Virtual environment activation: `source venv/bin/activate`

**Production:**
- Not configured yet
- Expected: PostgreSQL database, Tableau Public, Looker Studio for dashboards

## Project State

**Current Status:** Early setup phase
- Directory structure created with `.gitkeep` placeholders
- Dependencies installed in venv
- No source code files written yet
- Directories ready: `scripts/`, `notebooks/`, `sql/schema/`, `sql/queries/`, `sql/views/`

---

*Stack analysis: 2026-04-21*
