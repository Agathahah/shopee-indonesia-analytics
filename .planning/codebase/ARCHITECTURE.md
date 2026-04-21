# Architecture

**Analysis Date:** 2026-04-21

## Pattern Overview

**Overall:** Data Analytics Pipeline (ETL + Visualization)

**Key Characteristics:**
- SQL-centric analytics with PostgreSQL as the data warehouse
- Python for data generation, transformation, and ETL orchestration
- Dual dashboard approach: Tableau Public (executive) + Looker Studio (operational)
- Jupyter notebooks for exploratory analysis and ad-hoc queries
- Local development with external BI tool publication

## Layers

**Data Ingestion (raw):**
- Purpose: Store raw source data before transformation
- Location: `data/raw/`
- Contains: CSV/Excel files from external sources (Kaggle, APIs)
- Depends on: External data sources
- Used by: Python ETL scripts

**Data Processing (processed):**
- Purpose: Store cleaned and transformed data
- Location: `data/processed/`
- Contains: Transformed datasets ready for analysis
- Depends on: Raw data layer
- Used by: SQL queries, notebooks, dashboard exports

**Data Export (exports):**
- Purpose: Store data formatted for dashboard consumption
- Location: `data/exports/`
- Contains: Aggregated data for Tableau/Looker
- Depends on: Processed data, SQL views
- Used by: External BI tools

**SQL Layer:**
- Purpose: Data modeling, transformations, and reusable query logic
- Location: `sql/`
- Contains: Schema definitions, views, and analytical queries
- Depends on: PostgreSQL database
- Used by: Python scripts, notebooks, dashboards

**Visualization Layer:**
- Purpose: Dashboard definitions and configurations
- Location: `dashboard/`
- Contains: Looker and Tableau configuration files
- Depends on: SQL views, exported data
- Used by: End users (stakeholders)

**Scripts Layer:**
- Purpose: Automation and ETL orchestration
- Location: `scripts/`
- Contains: Python scripts for data generation, loading, transformation
- Depends on: pandas, SQLAlchemy, Faker, psycopg2
- Used by: Manual execution or scheduled jobs

**Notebooks Layer:**
- Purpose: Exploratory data analysis and prototyping
- Location: `notebooks/`
- Contains: Jupyter notebooks for ad-hoc analysis
- Depends on: Python environment, database connection
- Used by: Data analysts

## Data Flow

**Data Ingestion Flow:**

1. Raw data acquired from Kaggle or generated via Faker (`scripts/`)
2. Data loaded into `data/raw/` as CSV/Excel files
3. Python scripts read raw files and clean/transform data
4. Processed data written to `data/processed/`

**Database Loading Flow:**

1. Schema created in PostgreSQL (`sql/schema/`)
2. Processed data loaded via SQLAlchemy/psycopg2
3. Views created for common aggregations (`sql/views/`)
4. Queries stored for reusable analytics (`sql/queries/`)

**Dashboard Publishing Flow:**

1. SQL views or Python scripts export aggregated data
2. Exports saved to `data/exports/`
3. Tableau/Looker connected to exports or direct database
4. Dashboards published to Tableau Public / Looker Studio

**State Management:**
- No application state - batch processing model
- Database serves as single source of truth
- File-based intermediate storage for reproducibility

## Key Abstractions

**Data Storage:**
- Purpose: Multi-stage data lake pattern (raw -> processed -> exports)
- Examples: `data/raw/`, `data/processed/`, `data/exports/`
- Pattern: Medallion-lite (bronze/silver/gold simplified)

**SQL Organization:**
- Purpose: Separate DDL, views, and ad-hoc queries
- Examples: `sql/schema/`, `sql/views/`, `sql/queries/`
- Pattern: Organized SQL with clear separation of concerns

**Dashboard Platform Separation:**
- Purpose: Different dashboards for different audiences
- Examples: `dashboard/looker/`, `dashboard/tableau/`
- Pattern: Executive vs operational dashboard split

## Entry Points

**Python Scripts:**
- Location: `scripts/` (currently empty)
- Triggers: Manual execution, potential cron/scheduler
- Responsibilities: Data generation, ETL, exports

**Jupyter Notebooks:**
- Location: `notebooks/` (currently empty)
- Triggers: Interactive analysis sessions
- Responsibilities: Exploration, prototyping, ad-hoc reports

**SQL Queries:**
- Location: `sql/queries/`
- Triggers: Database client or Python execution
- Responsibilities: Business logic, aggregations, KPI calculations

## Error Handling

**Strategy:** Not yet implemented (early-stage project)

**Expected Patterns:**
- Python try/except for ETL scripts
- Database transaction management via SQLAlchemy
- Logging for script execution tracking

## Cross-Cutting Concerns

**Logging:** Not yet implemented - recommend Python logging module

**Validation:** Not yet implemented - recommend pandas data validation or Great Expectations

**Authentication:** 
- Database: PostgreSQL credentials (via `.env`, gitignored)
- Google Sheets: OAuth via `gspread` library
- Kaggle: API credentials for data downloads

---

*Architecture analysis: 2026-04-21*
