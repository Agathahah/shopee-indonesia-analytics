# Codebase Structure

**Analysis Date:** 2026-04-21

## Directory Layout

```
nusacommerce-analytics/
├── .claude/             # Claude Code configuration and GSD workflows
├── .planning/           # Planning documents and codebase analysis
│   └── codebase/        # Codebase mapping documents
├── dashboard/           # BI dashboard configurations
│   ├── looker/          # Looker Studio dashboard files
│   └── tableau/         # Tableau Public workbook files
├── data/                # Data storage (multi-stage)
│   ├── raw/             # Raw source data (gitignored except .gitkeep)
│   ├── processed/       # Cleaned and transformed data
│   └── exports/         # Dashboard-ready exports
├── docs/                # Project documentation
├── notebooks/           # Jupyter notebooks for analysis
├── scripts/             # Python ETL and automation scripts
├── sql/                 # SQL code organized by purpose
│   ├── schema/          # DDL - table definitions
│   ├── views/           # Reusable SQL views
│   └── queries/         # Ad-hoc and analytical queries
├── venv/                # Python virtual environment (gitignored)
├── .gitignore           # Git ignore rules
├── LICENSE              # MIT License
├── README.md            # Project overview
└── requirements.txt     # Python dependencies
```

## Directory Purposes

**dashboard/:**
- Purpose: Store dashboard configuration and definition files
- Contains: Looker Studio JSON/YAML configs, Tableau .twb/.twbx workbooks
- Key files: To be created

**dashboard/looker/:**
- Purpose: Operational dashboards for day-to-day monitoring
- Contains: Looker Studio configuration files
- Key files: `.gitkeep` (placeholder only)

**dashboard/tableau/:**
- Purpose: Executive dashboards for high-level KPIs
- Contains: Tableau workbook files
- Key files: `.gitkeep` (placeholder only)

**data/:**
- Purpose: Local data lake with staged processing
- Contains: CSV, Excel, and processed data files
- Key files: Subdirectory `.gitkeep` files

**data/raw/:**
- Purpose: Immutable source data (not modified after ingestion)
- Contains: Original CSV/Excel from Kaggle or generated data
- Key files: Data files are gitignored

**data/processed/:**
- Purpose: Cleaned, validated, and transformed data
- Contains: Processed CSV files ready for database loading
- Key files: `.gitkeep`

**data/exports/:**
- Purpose: Aggregated data formatted for BI tool consumption
- Contains: Summary tables, KPI exports
- Key files: `.gitkeep`

**docs/:**
- Purpose: Project documentation and data dictionaries
- Contains: Documentation files (currently empty)
- Key files: To be created

**notebooks/:**
- Purpose: Interactive data exploration and prototyping
- Contains: Jupyter notebook files (.ipynb)
- Key files: To be created

**scripts/:**
- Purpose: Automated data processing and ETL
- Contains: Python scripts for data pipeline operations
- Key files: To be created

**sql/:**
- Purpose: All SQL code organized by type
- Contains: DDL, views, and queries

**sql/schema/:**
- Purpose: Database schema definitions
- Contains: CREATE TABLE statements, constraints, indexes
- Key files: `.gitkeep`

**sql/views/:**
- Purpose: Reusable SQL views for common aggregations
- Contains: CREATE VIEW statements
- Key files: `.gitkeep`

**sql/queries/:**
- Purpose: Analytical queries and KPI calculations
- Contains: SELECT queries for specific analyses
- Key files: `.gitkeep`

## Key File Locations

**Entry Points:**
- `scripts/*.py`: ETL and data processing scripts (to be created)
- `notebooks/*.ipynb`: Interactive analysis notebooks (to be created)

**Configuration:**
- `requirements.txt`: Python package dependencies
- `.gitignore`: Git exclusion rules
- `.env`: Environment variables for credentials (gitignored, not committed)

**Core Logic:**
- `sql/schema/*.sql`: Database table definitions
- `sql/views/*.sql`: Reusable aggregation views
- `scripts/*.py`: Python ETL logic

**Testing:**
- Not yet implemented - recommend `tests/` directory

**Documentation:**
- `README.md`: Project overview
- `docs/`: Extended documentation

## Naming Conventions

**Files:**
- Python scripts: `snake_case.py` (e.g., `generate_data.py`, `load_orders.py`)
- SQL files: `snake_case.sql` (e.g., `create_orders.sql`, `daily_sales_view.sql`)
- Notebooks: `##_description.ipynb` (e.g., `01_data_exploration.ipynb`)
- Data files: `snake_case.csv` (gitignored)

**Directories:**
- All lowercase, singular or descriptive (e.g., `data`, `scripts`, `sql`)
- Subdirectories describe content type (e.g., `raw`, `processed`, `schema`)

**SQL Objects (recommended):**
- Tables: `snake_case` (e.g., `orders`, `order_items`, `customers`)
- Views: `v_` prefix or `_view` suffix (e.g., `v_daily_sales` or `daily_sales_view`)
- Indexes: `idx_table_column` (e.g., `idx_orders_created_at`)

## Where to Add New Code

**New ETL Script:**
- Primary code: `scripts/your_script.py`
- Tests: `tests/test_your_script.py` (create `tests/` directory)

**New Database Table:**
- Schema: `sql/schema/create_tablename.sql`
- Related views: `sql/views/tablename_views.sql`

**New Analysis:**
- Exploratory: `notebooks/##_analysis_name.ipynb`
- Production query: `sql/queries/analysis_name.sql`

**New Dashboard:**
- Looker: `dashboard/looker/dashboard_name.json`
- Tableau: `dashboard/tableau/dashboard_name.twb`

**Utilities/Helpers:**
- Shared helpers: `scripts/utils.py` or `scripts/helpers/`

**New Data Source:**
- Raw data: `data/raw/source_name/` (gitignored)
- Processing script: `scripts/process_source_name.py`

## Special Directories

**venv/:**
- Purpose: Python virtual environment with installed packages
- Generated: Yes (via `python -m venv venv`)
- Committed: No (gitignored)

**data/raw/:**
- Purpose: Source data storage
- Generated: Via download or data generation scripts
- Committed: No (contents gitignored, directory kept via .gitkeep)

**.planning/:**
- Purpose: GSD workflow planning documents
- Generated: Via Claude Code GSD commands
- Committed: May be committed for project tracking

**.claude/:**
- Purpose: Claude Code configuration and workflows
- Generated: Via Claude Code setup
- Committed: Yes (configuration should be version controlled)

**__pycache__/:**
- Purpose: Python bytecode cache
- Generated: Automatically by Python
- Committed: No (gitignored)

---

*Structure analysis: 2026-04-21*
