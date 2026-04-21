# Coding Conventions

**Analysis Date:** 2026-04-21

## Project Status

This is an early-stage project with initial scaffolding only. No source code exists yet. The conventions below are **recommendations** based on the declared stack (Python, PostgreSQL, pandas, SQLAlchemy) and standard practices.

## Naming Patterns

**Files:**
- Python scripts: `snake_case.py` (e.g., `generate_data.py`, `load_to_db.py`)
- SQL files: `snake_case.sql` (e.g., `create_tables.sql`, `monthly_sales.sql`)
- Jupyter notebooks: `NN_descriptive_name.ipynb` (e.g., `01_data_exploration.ipynb`)

**Functions:**
- Use `snake_case` for all function names
- Prefix private functions with underscore: `_helper_function`
- Use verb-noun pattern: `calculate_revenue`, `fetch_orders`, `generate_fake_data`

**Variables:**
- Use `snake_case` for variables
- Use `UPPER_SNAKE_CASE` for constants
- DataFrames: descriptive names like `orders_df`, `customers_df`

**Types:**
- Classes: `PascalCase` (e.g., `SalesReport`, `DataGenerator`)
- Type hints: Use standard Python typing conventions

## Code Style

**Formatting:**
- Not configured - recommend adding `black` or `ruff` formatter
- Suggested config: `pyproject.toml` with line-length of 88 (black default)

**Linting:**
- Not configured - recommend adding `ruff` or `flake8`
- Suggested config: `pyproject.toml` with ruff settings

**Recommended `pyproject.toml` additions:**
```toml
[tool.black]
line-length = 88
target-version = ['py312']

[tool.ruff]
line-length = 88
select = ["E", "F", "I", "W"]

[tool.isort]
profile = "black"
```

## Import Organization

**Order:**
1. Standard library imports
2. Third-party imports (pandas, numpy, sqlalchemy, faker)
3. Local application imports

**Recommended pattern:**
```python
# Standard library
import os
from datetime import datetime
from typing import Optional

# Third-party
import pandas as pd
import numpy as np
from sqlalchemy import create_engine
from faker import Faker

# Local
from scripts.config import DATABASE_URL
```

**Path Aliases:**
- None configured
- Keep imports simple given project scope

## Error Handling

**Patterns:**
- Use specific exception types, not bare `except:`
- Log errors before re-raising when appropriate
- For database operations, use context managers and transactions

**Database operations:**
```python
from sqlalchemy import create_engine
from sqlalchemy.exc import SQLAlchemyError

engine = create_engine(DATABASE_URL)

try:
    with engine.begin() as conn:
        conn.execute(statement)
except SQLAlchemyError as e:
    logger.error(f"Database error: {e}")
    raise
```

**File operations:**
```python
try:
    df = pd.read_csv(filepath)
except FileNotFoundError:
    logger.error(f"Data file not found: {filepath}")
    raise
except pd.errors.ParserError as e:
    logger.error(f"Failed to parse CSV: {e}")
    raise
```

## Logging

**Framework:** Python standard `logging` module

**Recommended setup:**
```python
import logging

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)
```

**Patterns:**
- Log at INFO level for normal operations
- Log at WARNING for recoverable issues
- Log at ERROR for failures
- Include context in log messages

## Comments

**When to Comment:**
- Complex SQL queries: explain business logic
- Data transformations: describe what each step achieves
- Non-obvious pandas operations: explain the transformation

**Docstrings:**
- Use Google-style docstrings for functions
```python
def calculate_monthly_revenue(orders_df: pd.DataFrame, month: int) -> float:
    """Calculate total revenue for a specific month.
    
    Args:
        orders_df: DataFrame containing order data with 'total' and 'order_date' columns.
        month: Month number (1-12).
    
    Returns:
        Total revenue for the specified month.
    
    Raises:
        ValueError: If month is not between 1 and 12.
    """
```

## Function Design

**Size:**
- Keep functions under 50 lines
- Extract helper functions for complex operations

**Parameters:**
- Use type hints for all parameters and return values
- Use Optional[] for nullable parameters
- Provide sensible defaults where appropriate

**Return Values:**
- Return DataFrames for data transformations
- Return dicts for multiple values
- Use None for functions that only produce side effects

## Module Design

**Exports:**
- Define `__all__` in modules with public APIs
- Keep module responsibilities focused

**File Organization:**
- `scripts/`: Executable Python scripts
- `notebooks/`: Jupyter notebooks for exploration
- `sql/schema/`: DDL statements
- `sql/queries/`: Reusable analytical queries
- `sql/views/`: SQL view definitions

## SQL Conventions

**File naming:**
- Schema files: `create_[table_name].sql`
- Query files: `[metric]_by_[dimension].sql` (e.g., `revenue_by_category.sql`)
- Views: `vw_[view_name].sql`

**Style:**
- Keywords: UPPERCASE (SELECT, FROM, WHERE, JOIN)
- Identifiers: lowercase_snake_case
- Aliases: short but meaningful (o for orders, c for customers)
- Indent joins and conditions for readability

**Example:**
```sql
SELECT
    c.customer_id,
    c.name,
    COUNT(o.order_id) AS order_count,
    SUM(o.total_amount) AS total_spent
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_date >= '2023-01-01'
GROUP BY c.customer_id, c.name
ORDER BY total_spent DESC;
```

## Environment Configuration

**Pattern:**
- Use `.env` file for local development (gitignored)
- Access via `os.getenv()` or `python-dotenv`

**Required variables:**
- `DATABASE_URL`: PostgreSQL connection string
- `GOOGLE_SHEETS_CREDENTIALS`: Path to service account JSON (if using gspread)

---

*Convention analysis: 2026-04-21*
*Note: This project is at scaffolding stage. Apply these conventions as code is added.*
